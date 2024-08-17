#!/bin/bash
set -e

# Define variables
PKG_NAME="ovpnconn"
PKG_VER="0.0.1"
REPO_URL="https://github.com/felipealfonsog/OpenVPN-GUI-Connect"
ARCHIVE_URL="${REPO_URL}/archive/refs/tags/v.${PKG_VER}.tar.gz"
SRC_DIR="OpenVPN-GUI-Connect-v.${PKG_VER}"
INSTALL_DIR="/usr/local/bin"
ICON_DIR="/usr/local/share/icons"
DESKTOP_DIR="/usr/share/applications"

welcome() {
    echo "
    ╔═══════════════════════════════════════╗
    ║                                       ║
    ║   ~ OpenVPN-GUI-Connect ~             ║
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
    echo "Welcome to the OpenVPN-GUI-Connect Installer!"
    echo "--------------------------------------------"
}

install_arch() {
    sudo pacman -S --needed python openvpn python-pyqt5 curl
    wget "${ARCHIVE_URL}" -O "${PKG_NAME}-${PKG_VER}.tar.gz"
    tar xf "${PKG_NAME}-${PKG_VER}.tar.gz"
    cd "${SRC_DIR}"

    # Install the Python script
    sudo install -Dm755 "src/main.py" "${INSTALL_DIR}/ovpnconn.py"
    
    # Create a shell script to execute ovpnconn.py and copy it to /usr/local/bin
    echo '#!/bin/bash' | sudo tee "${INSTALL_DIR}/ovpnconn" > /dev/null
    echo 'python3 /usr/local/bin/ovpnconn.py "$@"' | sudo tee -a "${INSTALL_DIR}/ovpnconn" > /dev/null
    sudo chmod +x "${INSTALL_DIR}/ovpnconn"

    # Install the icon
    sudo install -Dm644 "src/ovpnconn-iconlogo.png" "${ICON_DIR}/ovpnconn.png"

    # Install the .desktop file
    sudo install -Dm644 "src/ovpnconn.desktop" "${DESKTOP_DIR}/ovpnconn.desktop"
}

install_debian() {
    sudo apt-get update
    sudo apt-get install -y python3 python3-pyqt5 openvpn curl
    wget "${ARCHIVE_URL}" -O "${PKG_NAME}-${PKG_VER}.tar.gz"
    tar xf "${PKG_NAME}-${PKG_VER}.tar.gz"
    cd "${SRC_DIR}"

    # Install the Python script
    sudo install -Dm755 "src/main.py" "${INSTALL_DIR}/ovpnconn.py"
    
    # Create a shell script to execute ovpnconn.py and copy it to /usr/local/bin
    echo '#!/bin/bash' | sudo tee "${INSTALL_DIR}/ovpnconn" > /dev/null
    echo 'python3 /usr/local/bin/ovpnconn.py "$@"' | sudo tee -a "${INSTALL_DIR}/ovpnconn" > /dev/null
    sudo chmod +x "${INSTALL_DIR}/ovpnconn"

    # Install the icon
    sudo install -Dm644 "src/ovpnconn-iconlogo.png" "${ICON_DIR}/ovpnconn.png"

    # Install the .desktop file
    sudo install -Dm644 "src/ovpnconn.desktop" "${DESKTOP_DIR}/ovpnconn.desktop"
}

install_macos() {
    brew install python openvpn
    wget "${ARCHIVE_URL}" -O "${PKG_NAME}-${PKG_VER}.tar.gz"
    tar xf "${PKG_NAME}-${PKG_VER}.tar.gz"
    cd "${SRC_DIR}"

    # Install the Python script
    sudo install -m 755 "src/main.py" "${INSTALL_DIR}/ovpnconn.py"
    
    # Create a shell script to execute ovpnconn.py and copy it to /usr/local/bin
    echo '#!/bin/bash' | sudo tee "${INSTALL_DIR}/ovpnconn" > /dev/null
    echo 'python3 /usr/local/bin/ovpnconn.py "$@"' | sudo tee -a "${INSTALL_DIR}/ovpnconn" > /dev/null
    sudo chmod +x "${INSTALL_DIR}/ovpnconn"

    # Install the icon (use a directory that macOS supports)
    sudo mkdir -p "${ICON_DIR}"
    sudo cp "src/ovpnconn-iconlogo.png" "${ICON_DIR}/ovpnconn.png"

    # macOS doesn't use .desktop files, so this part is skipped
}

cleanup() {
    echo "Cleaning up..."
    cd ..
    rm -rf "${PKG_NAME}-${PKG_VER}.tar.gz" "${SRC_DIR}"
    echo "Cleanup completed."
}

goodbye() {
    echo "
    ╔═══════════════════════════════════════╗
    ║                                       ║
    ║   ~ Installation Complete! ~          ║
    ║   OpenVPN-GUI-Connect is now ready    ║
    ║   to use. Enjoy a more secure         ║
    ║   browsing experience!                ║
    ║                                       ║
    ║   Developed by Felipe Alfonso G.      ║
    ║                                       ║
    ╚═══════════════════════════════════════╝
    "
    echo "To launch OpenVPN-GUI-Connect, use the command: ovpnconn"
}

main() {
    welcome

    case "$(uname)" in
        Linux)
            if command -v pacman &> /dev/null; then
                install_arch
            elif command -v apt-get &> /dev/null; then
                install_debian
            else
                echo "Unsupported Linux distribution."
                exit 1
            fi
            ;;
        Darwin)
            install_macos
            ;;
        *)
            echo "Unsupported OS."
            exit 1
            ;;
    esac

    echo "Installation completed successfully!"
    cleanup
    goodbye
}

main
