#!/bin/bash

set -e

# Define variables
PKG_NAME="ovpnconn"
PKG_VER="0.0.1"
REPO_URL="https://github.com/felipealfonsog/OpenVPN-GUI-Connect"
ARCHIVE_URL="${REPO_URL}/archive/refs/tags/v.${PKG_VER}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VER}"
INSTALL_DIR="/usr/local/bin"
ICON_DIR="/usr/share/pixmaps"
DESKTOP_DIR="/usr/share/applications"

# Welcome message function
welcome() {
    echo "
    ╔═════════════════════════════════════════════════════════╗
    ║                                                         ║
    ║   ~ OpenVPN-GUI-Connect Installer ~                     ║
    ║   Developed with ❤️ by Felipe Alfonso González L.       ║
    ║   Computer Science Engineer                             ║
    ║   Chile                                                 ║
    ║                                                         ║
    ║   Contact: f.alfonso@res-ear.ch                         ║
    ║   Licensed under BSD 3-clause                           ║
    ║   GitHub: github.com/felipealfonsog                     ║
    ║                                                         ║
    ╚═════════════════════════════════════════════════════════╝
    "
    echo "Welcome to the OpenVPN-GUI-Connect Installer!"
    echo "---------------------------------------------------------------------"
}

# Function to install dependencies
install_dependencies() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v pacman &> /dev/null; then
      sudo pacman -Syu --needed python openvpn python-pyqt5 pkexec curl
    elif command -v apt &> /dev/null; then
      sudo apt update && sudo apt install -y python3 openvpn python3-pyqt5 pkexec curl
    else
      echo "Unsupported Linux distribution."
      exit 1
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
      brew install python openvpn pyqt5 curl
    else
      echo "Homebrew is required on macOS. Please install it first."
      exit 1
    fi
  else
    echo "Unsupported OS."
    exit 1
  fi
}

# Function to download and extract the source code
download_source() {
  curl -L "${ARCHIVE_URL}" -o "v.${PKG_VER}.tar.gz"
  tar xf "v.${PKG_VER}.tar.gz"
}

# Function to install the package
install_package() {
  # Install the Python script
  sudo install -Dm755 "${SRC_DIR}/src/main.py" "${INSTALL_DIR}/ovpnconn.py"

  # Create a shell script to execute ovpnconn.py
  echo '#!/bin/bash' | sudo tee "${INSTALL_DIR}/ovpnconn" > /dev/null
  echo "python3 ${INSTALL_DIR}/ovpnconn.py \"\$@\"" | sudo tee -a "${INSTALL_DIR}/ovpnconn" > /dev/null
  sudo chmod +x "${INSTALL_DIR}/ovpnconn"

  # Install the icon
  sudo install -Dm644 -p "${SRC_DIR}/src/ovpnconn-iconlogo.png" "${ICON_DIR}/ovpnconn.png"

  # Install the .desktop file (Linux only)
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo install -Dm644 -p "${SRC_DIR}/src/ovpnconn.desktop" "${DESKTOP_DIR}/ovpnconn.desktop"
  fi
}

# Function to clean up
cleanup() {
  rm -rf "${SRC_DIR}" "v.${PKG_VER}.tar.gz"
}

# Execute functions
welcome
install_dependencies
download_source
install_package
cleanup

# Final message
echo "
╔═════════════════════════════════════════════════════════╗
║                                                         ║
║   ~ Installation Complete ~                             ║
║   OpenVPN-GUI-Connect v${PKG_VER} has been successfully  ║
║   installed on your system!                             ║
║                                                         ║
║   You can now launch the application by typing:         ║
║   'ovpnconn' in your terminal.                          ║
║                                                         ║
║   Thank you for using OpenVPN-GUI-Connect!              ║
╚═════════════════════════════════════════════════════════╝
"
