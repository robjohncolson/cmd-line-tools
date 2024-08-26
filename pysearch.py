import os
import subprocess
import sys
from pathlib import Path

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def get_username():
    username = os.environ.get('USERNAME')
    if not username:
        username = input("USERNAME not set. Please enter your username: ")
    else:
        print(f"Using current username: {username}")
        if input("Is this correct? (Y/N): ").lower() != 'y':
            username = input("Please enter the correct username: ")
    return username

def is_python_in_path():
    try:
        subprocess.run(["python", "--version"], capture_output=True, check=True)
        return True
    except subprocess.CalledProcessError:
        return False

def verify_python(path):
    try:
        subprocess.run([path, "--version"], capture_output=True, check=True)
        return True
    except subprocess.CalledProcessError:
        return False

def search_directories(base_dirs, python_versions, username):
    for base in base_dirs:
        for version in python_versions:
            path = Path(base) / version / "python.exe"
            if path.exists() and verify_python(str(path)):
                return path.parent
    return None

def search_entire_drive():
    for root, _, files in os.walk("C:\\"):
        if "python.exe" in files:
            path = Path(root) / "python.exe"
            if verify_python(str(path)):
                return path.parent
    return None

def add_to_path(path):
    if sys.platform != "win32":
        print("PATH modification is only supported on Windows.")
        return False

    try:
        current_path = os.environ.get('PATH', '')
        new_path = f"{current_path};{path}"
        subprocess.run(["set