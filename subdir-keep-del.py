import os
import shutil
import subprocess
from tabulate import tabulate
from colorama import init, Fore, Back, Style
import random

# Initialize colorama
init(autoreset=True)

def print_directory_table(current_dir, status=None):
    subdirs = []
    try:
        for item in os.listdir(current_dir):
            item_path = os.path.join(current_dir, item)
            if os.path.isdir(item_path):
                color = Fore.WHITE
                if status and item in status:
                    color = Fore.GREEN if status[item] == 'preserved' else Fore.RED
                subdirs.append([f"{color}{item}{Style.RESET_ALL}"])
    except PermissionError:
        print(f"{Fore.YELLOW}Permission denied to list contents of {current_dir}.{Style.RESET_ALL}")
    except Exception as e:
        print(f"{Fore.RED}Error listing contents of {current_dir}: {str(e)}{Style.RESET_ALL}")

    if subdirs:
        print(tabulate(subdirs, headers=["Subdirectories"], tablefmt="grid"))
    else:
        print("No subdirectories found.")

def clear_and_print_table(current_dir, status=None):
    os.system('cls' if os.name == 'nt' else 'clear')
    print(f"\nCurrent directory: {current_dir}")
    print_directory_table(current_dir, status)

def list_and_process_subdirectories():
    current_dir = os.getcwd()
    try:
        subdirectories = [d for d in os.listdir(current_dir) if os.path.isdir(os.path.join(current_dir, d))]
    except PermissionError:
        print(f"Permission denied to list contents of {current_dir}. Please run the script with appropriate permissions.")
        return
    except Exception as e:
        print(f"An error occurred while listing the contents of {current_dir}: {str(e)}")
        return

    status = {}
    
    clear_and_print_table(current_dir)
    
    for subdir in subdirectories:
        print(f"\nContents of {subdir}:")
        subdir_path = os.path.join(current_dir, subdir)
        
        try:
            contents = os.listdir(subdir_path)
            for item in contents:
                print(item)
            
            choice = input(f"Do you want to \033[94mp\033[0mreserve or \033[94md\033[0melete the contents of {subdir}? (preserve/delete): ").lower()
            
            if choice == 'd':
                confirm = input(f"Are you sure you want to delete the contents of {subdir}? This action is final. (\033[92my\033[0mes/no): ").lower()
                if confirm == 'y':
                    try:
                        total_items = len(os.listdir(subdir_path))
                        for index, item in enumerate(os.listdir(subdir_path), 1):
                            item_path = os.path.join(subdir_path, item)
                            if os.path.isfile(item_path):
                                os.remove(item_path)
                            elif os.path.isdir(item_path):
                                shutil.rmtree(item_path)
                            progress = int((index / total_items) * 20)
                            print(f"\rDeleting contents: [{'#' * progress}{' ' * (20 - progress)}] {index}/{total_items}", end="", flush=True)
                        print(f"\nContents of {subdir} have been deleted.")
                        status[subdir] = 'deleted'
                        
                        delete_subdir = input(f"Do you want to delete the subdirectory '{subdir}' itself? (\033[91my\033[0mes/no): ").lower()
                        if delete_subdir == 'y':
                            try:
                                os.rmdir(subdir_path)
                                print(f"Subdirectory '{subdir}' has been deleted.")
                            except (OSError, PermissionError, FileNotFoundError) as e:
                                print(f"Failed to delete subdirectory '{subdir}': {str(e)}")
                                force_delete = input("Do you want to try using 'Remove-Item -Recurse -Force' to delete the subdirectory? (\033[91my\033[0mes/no): ").lower()
                                if force_delete == 'y':
                                    try:
                                        subprocess.run(["powershell", "-Command", f"Remove-Item -Recurse -Force '{subdir_path}'"], check=True)
                                        print(f"Subdirectory '{subdir}' has been forcefully deleted.")
                                    except subprocess.CalledProcessError as e:
                                        print(f"Failed to delete subdirectory '{subdir}' even with force option: {str(e)}")
                    except PermissionError:
                        print(f"Permission denied when trying to delete contents of {subdir}.")
                        force_delete = input("Do you want to try using 'Remove-Item -Recurse -Force' to delete the contents? (\033[91my\033[0mes/no): ").lower()
                        if force_delete == 'y':
                            try:
                                subprocess.run(["powershell", "-Command", f"Remove-Item -Recurse -Force '{subdir_path}'"], check=True)
                                print(f"Contents of {subdir} have been forcefully deleted.")
                                status[subdir] = 'deleted'
                            except subprocess.CalledProcessError:
                                print(f"Failed to delete contents of {subdir} even with force option.")
                                status[subdir] = 'preserved'
                        else:
                            print(f"Deletion cancelled. Contents of {subdir} have been preserved.")
                            status[subdir] = 'preserved'
                else:
                    print(f"Deletion cancelled. Contents of {subdir} have been preserved.")
                    status[subdir] = 'preserved'
            else:
                print(f"Contents of {subdir} have been preserved.")
                status[subdir] = 'preserved'
        
        except PermissionError:
            print(f"Access \033[91mdenied\033[0m to {subdir}. \033[93mSkipping this directory.\033[0m")
            status[subdir] = 'preserved'
        except Exception as e:
            print(f"An error occurred while processing {subdir}: {str(e)}. Skipping this directory.")
            status[subdir] = 'preserved'
        
        clear_and_print_table(current_dir, status)

    print("\nSummary:")
    preserved = [d for d, s in status.items() if s == 'preserved']
    deleted = [d for d, s in status.items() if s == 'deleted']
    print("Preserved directories:", ", ".join(preserved) if preserved else "None")
    print("Deleted directories:", ", ".join(deleted) if deleted else "None")

def main():
    while True:
        list_and_process_subdirectories()
        

        color_choice = random.choice(['93', '91', '33', '92', '95', '96', '31', '32', '35', '36', '37', '90'])  # 93: orange, 91: red, 33: yellow, 92: green, 95: magenta, 96: cyan, 31: dark red, 32: dark green, 35: dark magenta, 36: dark cyan, 37: light gray, 90: dark gray
        not_color_choice = str(93 + (int(color_choice) - 93 + 3) % 6)  # Calculate inverse color
        repeat = input(f"\033[{not_color_choice}mDo you want to repeat the process? (\033[{color_choice}my\033[{not_color_choice}mes/no): \033[0m").lower()
        if repeat != 'y':
            break
    
    print("Script execution completed.")

if __name__ == "__main__":
    main()