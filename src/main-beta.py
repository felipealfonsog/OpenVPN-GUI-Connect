import sys
import subprocess
import threading
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QLineEdit, QPushButton, QLabel, QFileDialog, QMessageBox

class VPNConnector(QWidget):
    def __init__(self):
        super().__init__()

        self.ovpn_file_path = None
        self.process = None
        self.initUI()

    def initUI(self):
        self.setWindowTitle('VPN Connector')
        self.setGeometry(100, 100, 400, 250)

        layout = QVBoxLayout()

        self.file_button = QPushButton('Select .ovpn File', self)
        self.file_button.clicked.connect(self.select_file)
        layout.addWidget(self.file_button)

        self.username_label = QLabel('Enter Auth Username:')
        layout.addWidget(self.username_label)

        self.username_input = QLineEdit(self)
        layout.addWidget(self.username_input)

        self.password_label = QLabel('Enter Auth Password:')
        layout.addWidget(self.password_label)

        self.password_input = QLineEdit(self)
        self.password_input.setEchoMode(QLineEdit.Password)
        layout.addWidget(self.password_input)

        self.connect_button = QPushButton('Connect', self)
        self.connect_button.clicked.connect(self.connect_vpn)
        layout.addWidget(self.connect_button)

        self.disconnect_button = QPushButton('Disconnect', self)
        self.disconnect_button.clicked.connect(self.disconnect_vpn)
        self.disconnect_button.setEnabled(False)  # Disable initially
        layout.addWidget(self.disconnect_button)

        self.quit_button = QPushButton('Quit', self)
        self.quit_button.clicked.connect(self.quit_program)
        layout.addWidget(self.quit_button)

        self.credits_button = QPushButton('Credits', self)
        self.credits_button.clicked.connect(self.show_credits)
        layout.addWidget(self.credits_button)

        self.setLayout(layout)

    def select_file(self):
        options = QFileDialog.Options()
        options |= QFileDialog.ReadOnly
        file_path, _ = QFileDialog.getOpenFileName(self, "Select .ovpn File", "", "OpenVPN Files (*.ovpn);;All Files (*)", options=options)
        if file_path:
            self.ovpn_file_path = file_path
            self.file_button.setText(f'Selected: {file_path.split("/")[-1]}')

    def connect_vpn(self):
        if not self.ovpn_file_path:
            QMessageBox.warning(self, 'File Error', 'Please select an .ovpn file first!')
            return

        username = self.username_input.text()
        password = self.password_input.text()

        if not username or not password:
            QMessageBox.warning(self, 'Input Error', 'Username and Password are required!')
            return

        # Write the username and password to a temporary file
        with open('/tmp/vpn_auth.txt', 'w') as auth_file:
            auth_file.write(f'{username}\n{password}')

        # Prepare the OpenVPN command
        command = ['pkexec', 'openvpn', '--config', self.ovpn_file_path, '--auth-user-pass', '/tmp/vpn_auth.txt']

        # Disable Connect button and enable Disconnect button
        self.connect_button.setEnabled(False)
        self.disconnect_button.setEnabled(True)

        # Run the OpenVPN command in a separate thread to avoid blocking the UI
        self.process = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        threading.Thread(target=self.wait_for_connection).start()

    def wait_for_connection(self):
        stdout, stderr = self.process.communicate()  # Wait for the command to complete

        # Check for successful connection
        if self.process.returncode == 0:
            # Update the UI on the main thread
            self.show_message('Success', 'Connected to VPN successfully!')
        else:
            # Update the UI on the main thread
            self.show_message('Warning', f'VPN connection may not be fully established. Error: {stderr}')

    def disconnect_vpn(self):
        if self.process:
            try:
                self.process.terminate()
                self.process.wait()  # Wait for the process to terminate
            except Exception as e:
                QMessageBox.warning(self, 'Disconnection Error', f'Error disconnecting from VPN: {str(e)}')
            finally:
                self.process = None
                self.show_message('Disconnected', 'Disconnected from VPN.')
                # Enable Connect button and disable Disconnect button
                self.connect_button.setEnabled(True)
                self.disconnect_button.setEnabled(False)

    def quit_program(self):
        if self.process:
            self.disconnect_vpn()  # Ensure VPN is disconnected
        self.close()

    def show_message(self, title, message):
        QMessageBox.information(self, title, message)

    def show_credits(self):
        QMessageBox.information(self, 'Credits', 'Developed by Engineer: Felipe Alfonso Gonzalez\nEmail: f.alfonso@res-ear.ch\nGitHub: github.com/felipealfonsog\nLicense: BSD 3-Clause')

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = VPNConnector()
    window.show()
    sys.exit(app.exec_())
