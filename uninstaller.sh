#!/bin/bash
set -e

# Define variables
PKG_NAME="ovpnconn"
INSTALL_DIR="/usr/local/bin"
ICON_DIR="/usr/local/share/icons"
DESKTOP_DIR="/usr/share/applications"

welcome() {
    echo "
    ╔═══════════════════════════════════════╗
    ║                                       ║
    ║   ~ OpenVPN-GUI-Connect Uninstaller ~  ║
    ║   Developed with ❤️ by                ║
    ║   Felipe Alfonso González L.          ║
    ║   Computer Science Engineer           ║
    ║   Chile                               ║
    ║                                       ║
    ║   Contact: f.alfonso@res-ear.ch       ║
    ║   Licensed under BSD 3-clause         ║
    ║   GitHub: github.com/felipealfonsog   ║
    ║                                       ║
    ╚═══════════════════════════════════════╝
    "
    echo "Welcome to the OpenVPN-GUI-Connect Uninstaller!"
    echo "----------------------------------------------"
}

uninstall_arch() {
    sudo rm -f "${INSTALL_DIR}/ovpnconn.py"
    sudo rm -f "${INSTALL_DIR}/ovpnconn"
    sudo rm -f "${ICON_DIR}/ovpnconn.png"
    sudo rm -f "${DESKTOP_DIR}/ovpnconn.desktop"
}

uninstall_debian() {
    sudo rm -f "${INSTALL_DIR}/ovpnconn.py"
    sudo rm -f "${INSTALL_DIR}/ovpnconn"
    sudo rm -f "${ICON_DIR}/ovpnconn.png"
    sudo rm -f "${DESKTOP_DIR}/ovpnconn.desktop"
}

uninstall_macos() {
    sudo rm -f "${INSTALL_DIR}/ovpnconn.py"
    sudo rm -f "${INSTALL_DIR}/ovpnconn"
    sudo rm -f "${ICON_DIR}/ovpnconn.png"
    # macOS doesn't use .desktop files, so this part is skipped
}

cleanup() {
    echo "Cleanup completed."
}

goodbye() {
    echo "
    ╔═══════════════════════════════════════╗
    ║                                       ║
    ║   ~ Uninstallation Complete! ~         ║
    ║   OpenVPN-GUI-Connect has been removed ║
    ║                                       ║
    ╚═══════════════════════════════════════╝
    "
    echo "OpenVPN-GUI-Connect has been successfully uninstalled."
}

main() {
    welcome

    case "$(uname)" in
        Linux)
            if command -v pacman &> /dev/null; then
                uninstall_arch
            elif command -v apt-get &> /dev/null; then
                uninstall_debian
            else
                echo "Unsupported Linux distribution."
                exit 1
            fi
            ;;
        Darwin)
            uninstall_macos
            ;;
        *)
            echo "Unsupported OS."
            exit 1
            ;;
    esac

    cleanup
    goodbye
}

main
