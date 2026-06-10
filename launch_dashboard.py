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
