#include <iostream>
#include <vector>
#include <string>
#include <filesystem>
#include <algorithm>
#include <iomanip>
#include <cstdlib>
#include <chrono>
#include <thread>

namespace fs = std::filesystem;

// ANSI color codes
const std::string ANSI_RED = "\033[31m";
const std::string ANSI_GREEN = "\033[32m";
const std::string ANSI_YELLOW = "\033[33m";
const std::string ANSI_BLUE = "\033[34m";
const std::string ANSI_RESET = "\033[0m";

class DirectoryManager {
private:
    fs::path current_dir;
    std::vector<std::pair<std::string, std::string>> subdirs_status;

    void clear_screen() {
        #ifdef _WIN32
            std::system("cls");
        #else
            std::system("clear");
        #endif
    }

    void print_directory_table() {
        std::cout << "\nCurrent directory: " << current_dir << "\n\n";
        std::cout << std::setw(30) << std::left << "Subdirectories" << "Status\n";
        std::cout << std::string(50, '-') << "\n";
        for (const auto& [subdir, status] : subdirs_status) {
            std::string color = (status == "preserved") ? ANSI_GREEN : ANSI_RED;
            std::cout << std::setw(30) << std::left << subdir 
                      << color << status << ANSI_RESET << "\n";
        }
        std::cout << "\n";
    }

    bool delete_directory_contents(const fs::path& path) {
        for (const auto& entry : fs::directory_iterator(path)) {
            try {
                if (fs::is_directory(entry)) {
                    delete_directory_contents(entry);
                    fs::remove(entry);
                } else {
                    fs::remove(entry);
                }
            } catch (const fs::filesystem_error& e) {
                std::cerr << "Error deleting " << entry.path() << ": " << e.what() << "\n";
                return false;
            }
        }
        return true;
    }

    void process_subdirectory(const fs::path& subdir) {
        std::cout << "\nContents of " << subdir.filename() << ":\n";
        for (const auto& entry : fs::directory_iterator(subdir)) {
            std::cout << entry.path().filename() << "\n";
        }

        std::string choice;
        std::cout << "Do you want to " << ANSI_BLUE << "p" << ANSI_RESET 
                  << "reserve or " << ANSI_BLUE << "d" << ANSI_RESET 
                  << "elete the contents of " << subdir.filename() << "? (preserve/delete): ";
        std::cin >> choice;

        if (choice == "d") {
            std::cout << "Are you sure you want to delete the contents of " 
                      << subdir.filename() << "? This action is final. ("
                      << ANSI_GREEN << "y" << ANSI_RESET << "es/no): ";
            std::cin >> choice;

            if (choice == "y") {
                if (delete_directory_contents(subdir)) {
                    std::cout << "Contents of " << subdir.filename() << " have been deleted.\n";
                    subdirs_status.push_back({subdir.filename().string(), "deleted"});

                    std::cout << "Do you want to delete the subdirectory '" 
                              << subdir.filename() << "' itself? ("
                              << ANSI_RED << "y" << ANSI_RESET << "es/no): ";
                    std::cin >> choice;
                    if (choice == "y") {
                        try {
                            fs::remove(subdir);
                            std::cout << "Subdirectory '" << subdir.filename() << "' has been deleted.\n";
                        } catch (const fs::filesystem_error& e) {
                            std::cerr << "Failed to delete subdirectory '" << subdir.filename() 
                                      << "': " << e.what() << "\n";
                        }
                    }
                } else {
                    std::cout << "Failed to delete contents of " << subdir.filename() << ".\n";
                    subdirs_status.push_back({subdir.filename().string(), "preserved"});
                }
            } else {
                std::cout << "Deletion cancelled. Contents of " << subdir.filename() << " have been preserved.\n";
                subdirs_status.push_back({subdir.filename().string(), "preserved"});
            }
        } else {
            std::cout << "Contents of " << subdir.filename() << " have been preserved.\n";
            subdirs_status.push_back({subdir.filename().string(), "preserved"});
        }

        std::this_thread::sleep_for(std::chrono::seconds(1));
        clear_screen();
        print_directory_table();
    }

public:
    DirectoryManager() : current_dir(fs::current_path()) {}

    void list_and_process_subdirectories() {
        subdirs_status.clear();
        clear_screen();
        print_directory_table();

        for (const auto& entry : fs::directory_iterator(current_dir)) {
            if (fs::is_directory(entry)) {
                process_subdirectory(entry);
            }
        }

        std::cout << "\nSummary:\n";
        std::cout << "Preserved directories: ";
        for (const auto& [subdir, status] : subdirs_status) {
            if (status == "preserved") std::cout << subdir << " ";
        }
        std::cout << "\nDeleted directories: ";
        for (const auto& [subdir, status] : subdirs_status) {
            if (status == "deleted") std::cout << subdir << " ";
        }
        std::cout << "\n";
    }
};

int main() {
    DirectoryManager manager;
    std::string repeat;

    do {
        manager.list_and_process_subdirectories();
        std::cout << "\nDo you want to repeat the process? (yes/no): ";
        std::cin >> repeat;
    } while (repeat == "yes");

    std::cout << "Script execution completed.\n";
    return 0;
}