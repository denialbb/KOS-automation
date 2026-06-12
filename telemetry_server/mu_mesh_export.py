import os
import sys
import json
import math

# Add io_object_mu to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'io_object_mu'))
import mu

def parse_cfg_for_model(filepath):
    """
    Naively parses a KSP .cfg file looking for 'name = ...' and 'model = ...' or 'mesh = ...'.
    Returns a list of dicts: [{'name': part_name, 'model': model_path, 'dir': directory}, ...]
    """
    parts = []
    current_part = None
    in_model_node = False
    
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                line = line.strip().split('//')[0].strip()
                if not line:
                    continue
                if line.startswith('PART'):
                    current_part = {'dir': os.path.dirname(filepath)}
                    parts.append(current_part)
                elif line.startswith('MODEL'):
                    in_model_node = True
                elif line == '}':
                    in_model_node = False
                elif '=' in line and current_part is not None:
                    k, v = line.split('=', 1)
                    k = k.strip().lower()
                    v = v.strip()
                    if k == 'name' and 'name' not in current_part:
                        current_part['name'] = v.replace('_', '.') # KSP swaps _ and . sometimes
                    elif k == 'mesh':
                        current_part['mesh'] = v
                    elif in_model_node and k == 'model':
                        current_part['model'] = v
    except Exception as e:
        print(f"Error parsing {filepath}: {e}")
        
    return parts

def build_part_database(gamedata_path):
    print("Building part database from GameData...")
    part_db = {}
    for root, dirs, files in os.walk(gamedata_path):
        for file in files:
            if file.endswith('.cfg'):
                parts = parse_cfg_for_model(os.path.join(root, file))
                for p in parts:
                    if 'name' in p:
                        # resolve model path
                        model_path = None
                        if 'model' in p:
                            # model paths are usually GameData relative without .mu
                            model_path = os.path.join(gamedata_path, p['model'].replace('/', os.sep))
                            if not model_path.endswith('.mu'):
                                model_path += '.mu'
                        elif 'mesh' in p:
                            model_path = os.path.join(p['dir'], p['mesh'])
                        else:
                            model_path = os.path.join(p['dir'], 'model.mu')
                        
                        part_db[p['name']] = model_path
                        # Also save unmodified name for fuzzy matching
                        part_db[p['name'].replace('.', '_')] = model_path
    print(f"Found {len(part_db)} parts in GameData.")
    return part_db

def apply_transform(v, pos, rot, scale):
    # Very basic transform application (doesn't handle full hierarchy matrix yet)
    # Scale
    x = v[0] * scale[0]
    y = v[1] * scale[1]
    z = v[2] * scale[2]
    # Quaternion rotation (simplified)
    # ... ignoring rotation for decimation simplified meshes, just bounding boxes or raw points for now
    # We will just return scaled + translated
    return (x + pos[0], y + pos[1], z + pos[2])

def quat_rotate(q, v):
    """Rotate vector v by unit quaternion q = (x, y, z, w)."""
    qx, qy, qz, qw = q
    # t = 2 * cross(q.xyz, v)
    tx = 2*(qy*v[2] - qz*v[1])
    ty = 2*(qz*v[0] - qx*v[2])
    tz = 2*(qx*v[1] - qy*v[0])
    return (
        v[0] + qw*tx + qy*tz - qz*ty,
        v[1] + qw*ty + qz*tx - qx*tz,
        v[2] + qw*tz + qx*ty - qy*tx,
    )

def extract_mu_mesh(filepath):
    """
    Parses a .mu file and extracts simplified vertex/triangle data.
    """
    if not os.path.exists(filepath):
        return None
    try:
        m = mu.Mu()
        m.read(filepath)
        
        all_verts = []
        all_tris = []
        
        def walk_obj(obj, world_pos):
            # accumulate
            pos = (world_pos[0] + obj.transform.localPosition[0],
                   world_pos[1] + obj.transform.localPosition[1],
                   world_pos[2] + obj.transform.localPosition[2])
            
            for comp in obj.components:
                mesh = None
                if hasattr(comp, 'verts'):
                    mesh = comp
                elif hasattr(comp, 'shared_mesh') and comp.shared_mesh:
                    mesh = comp.shared_mesh
                    
                if mesh:
                    v_offset = len(all_verts)
                    for v in mesh.verts:
                        sv = (v[0]*obj.transform.localScale[0],
                              v[1]*obj.transform.localScale[1],
                              v[2]*obj.transform.localScale[2])
                        rv = quat_rotate(obj.transform.localRotation, sv)
                        all_verts.append((rv[0]+pos[0], rv[1]+pos[1], rv[2]+pos[2]))
                    for sm in mesh.submeshes:
                        for tri in sm:
                            all_tris.append((tri[0]+v_offset, tri[1]+v_offset, tri[2]+v_offset))
            
            for child in obj.children:
                walk_obj(child, pos)
                
        walk_obj(m.obj, (0,0,0))
        
        # Simple decimation: just skip some triangles if there are too many
        max_tris = 250
        if len(all_tris) > max_tris:
            step = len(all_tris) // max_tris
            all_tris = all_tris[::step]
            
        # Strip unused vertices to save JSON size
        used_verts = {}
        new_verts = []
        new_tris = []
        
        for t in all_tris:
            new_t = []
            for v_idx in t:
                if v_idx not in used_verts:
                    used_verts[v_idx] = len(new_verts)
                    new_verts.append(all_verts[v_idx])
                new_t.append(used_verts[v_idx])
            new_tris.append(tuple(new_t))
            
        return {'verts': new_verts, 'tris': new_tris}
    except Exception as e:
        print(f"Error parsing {filepath}: {e}")
        return None

def main():
    ksp_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
    gamedata_path = os.path.join(ksp_dir, 'GameData')
    
    struct_path = os.path.join(os.path.dirname(__file__), '..', 'telemetry', 'vessel_structure.json')
    out_path = os.path.join(os.path.dirname(__file__), '..', 'telemetry', 'vessel_mesh.json')
    
    if not os.path.exists(struct_path):
        print(f"Structure file not found: {struct_path}")
        return
        
    with open(struct_path, 'r') as f:
        structure = json.load(f)
        
    part_db = build_part_database(gamedata_path)
    
    mesh_data = {}
    
    for p in structure.get('parts', []):
        name = p['name']
        uid = p['uid']
        
        # Try to match the part name to a .mu file
        # kOS part names often have partname_uid or just partname
        base_name = name.split('_')[0]
        
        model_path = part_db.get(base_name)
        if not model_path:
            model_path = part_db.get(base_name.replace('_', '.'))
            
        if model_path:
            print(f"Parsing mesh for {base_name}: {model_path}")
            mesh = extract_mu_mesh(model_path)
            if mesh:
                mesh_data[uid] = mesh
        else:
            print(f"Could not find model for {base_name}")
            
    with open(out_path, 'w') as f:
        json.dump(mesh_data, f)
    print(f"Saved {len(mesh_data)} meshes to {out_path}")

if __name__ == '__main__':
    main()
