import os
import subprocess
import sys
import time
import webbrowser

def check_command(cmd):
    try:
        subprocess.run([cmd, "--version"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def check_io_object_mu(server_dir):
    mu_dir = os.path.join(server_dir, "io_object_mu")
    mu_py = os.path.join(mu_dir, "mu.py")
    
    if os.path.exists(mu_py):
        return
        
    print("\n[+] GPL Dependency 'io_object_mu' not found locally.")
    print("    Fetching from https://github.com/taniwha/io_object_mu to maintain compliance...")
    
    # Try Git clone first
    try:
        print("    Attempting git clone...")
        subprocess.run(["git", "clone", "--depth", "1", "-b", "master", "https://github.com/taniwha/io_object_mu.git", mu_dir], check=True)
        print("[+] io_object_mu cloned successfully via git.")
        return
    except Exception as e:
        print(f"    Git clone failed: {e}. Falling back to zip download...")
        
    # Fallback to downloading zip
    import urllib.request
    import zipfile
    import shutil
    
    zip_url = "https://github.com/taniwha/io_object_mu/archive/refs/heads/master.zip"
    temp_zip = os.path.join(server_dir, "io_object_mu_temp.zip")
    temp_extract = os.path.join(server_dir, "io_object_mu_temp_extract")
    
    try:
        print(f"    Downloading {zip_url}...")
        urllib.request.urlretrieve(zip_url, temp_zip)
        
        print("    Extracting zip archive...")
        with zipfile.ZipFile(temp_zip, 'r') as zip_ref:
            zip_ref.extractall(temp_extract)
            
        extracted_folder = os.path.join(temp_extract, "io_object_mu-master")
        if os.path.exists(extracted_folder):
            if os.path.exists(mu_dir):
                shutil.rmtree(mu_dir)
            shutil.move(extracted_folder, mu_dir)
            print("[+] io_object_mu downloaded and extracted successfully.")
        else:
            print("[!] Error: Could not find extracted folder structure.")
            
    except Exception as download_error:
        print(f"[!] Failed to download io_object_mu: {download_error}")
        print("Please manually clone https://github.com/taniwha/io_object_mu into telemetry_server/io_object_mu.")
        input("Press Enter to exit...")
        sys.exit(1)
        
    finally:
        # Cleanup temp files
        if os.path.exists(temp_zip):
            os.remove(temp_zip)
        if os.path.exists(temp_extract):
            shutil.rmtree(temp_extract)

def main():
    print("=" * 60)
    print(" DASA KSP MISSION CONTROL LAUNCHER")
    print("=" * 60)

    # 1. Print environment info
    print(f"Python Version: {sys.version.split()[0]}")

    # 2. Check Node.js and NPM
    print("Checking Node.js & NPM installation...")
    node_installed = check_command("node")
    npm_installed = check_command("npm")

    if not node_installed or not npm_installed:
        print("\n[!] ERROR: Node.js or NPM is not installed or not added to your system PATH.")
        print("Please follow these steps to install them:")
        print("  1. Download the installer from: https://nodejs.org/")
        print("  2. Run the installer (LTS version is recommended).")
        print("  3. Restart your terminal to apply PATH changes.")
        print("  4. Re-run this Python launcher.")
        print("=" * 60)
        input("Press Enter to exit...")
        sys.exit(1)

    print("[+] Node.js and NPM detected!")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    server_dir = os.path.join(script_dir, "telemetry_server")

    # Check and fetch GPL dependency io_object_mu dynamically to maintain compliance
    check_io_object_mu(server_dir)

    # 3. Install dependencies if node_modules doesn't exist
    node_modules_path = os.path.join(server_dir, "node_modules")
    if not os.path.exists(node_modules_path):
        print("\nInstalling Node.js dependencies (express)... This may take a few seconds.")
        try:
            subprocess.run(["npm", "install"], cwd=server_dir, shell=True, check=True)
            print("[+] Dependencies installed successfully.")
        except subprocess.CalledProcessError as e:
            print(f"[!] Failed to install dependencies: {e}")
            input("Press Enter to exit...")
            sys.exit(1)

    # 4. Launch Node.js server
    print("\nStarting Node.js telemetry server...")
    try:
        process = subprocess.Popen(["npm", "start"], cwd=server_dir, shell=True)
        
        # Give the server a moment to boot
        time.sleep(1.5)
        
        # Open browser
        url = "http://localhost:8080"
        print(f"[+] Opening dashboard at {url}")
        webbrowser.open(url)
        
        print("\nTelemetry server is running.")
        print("Press Ctrl+C in this terminal to stop the web server.")
        
        # Monitor the process
        process.wait()
    except KeyboardInterrupt:
        print("\nShutting down telemetry server...")
        # Clean shutdown on Windows
        subprocess.run(["taskkill", "/f", "/t", "/im", "node.exe"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        sys.exit(0)
    except Exception as e:
        print(f"[!] Error running server: {e}")
        input("Press Enter to exit...")
        sys.exit(1)

if __name__ == "__main__":
    main()
