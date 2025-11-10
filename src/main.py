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
        self.update_ip_status()  # Show IP status on startup

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

        self.status_label = QLabel('Status: Not connected')
        layout.addWidget(self.status_label)

        self.ip_status_label = QLabel('IP Status: Not available')
        layout.addWidget(self.ip_status_label)

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
            self.update_status('Please select an .ovpn file first!')
            return

        username = self.username_input.text()
        password = self.password_input.text()

        if not username or not password:
            self.update_status('Username and Password are required!')
            return

        # Write the username and password to a temporary file
        with open('/tmp/vpn_auth.txt', 'w') as auth_file:
            auth_file.write(f'{username}\n{password}')

        # Prepare the OpenVPN command
        command = ['pkexec', 'openvpn', '--config', self.ovpn_file_path, '--auth-user-pass', '/tmp/vpn_auth.txt']

        # Disable Connect button and enable Disconnect button
        self.connect_button.setEnabled(False)
        self.disconnect_button.setEnabled(True)
        self.update_status('Connecting...')

        # Run the OpenVPN command in a separate thread to avoid blocking the UI
        self.process = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        threading.Thread(target=self.wait_for_connection).start()

    def wait_for_connection(self):
        try:
            # Monitor the process output
            while True:
                output = self.process.stdout.readline()
                if output == '' and self.process.poll() is not None:
                    break
                if output:
                    # Check if the connection was established
                    if 'Initialization Sequence Completed' in output:
                        self.update_status('Connected successfully.')
                        self.update_ip_status()
                        break
            else:
                # If we exit the loop without finding a success message
                if self.process.returncode != 0:
                    self.update_status(f'Error connecting to VPN.')
        except Exception as e:
            self.update_status(f'Error: {e}')

    def disconnect_vpn(self):
        try:
            # Use pkill to terminate openvpn process
            subprocess.run(['sudo', 'pkill', 'openvpn'], check=True)
            self.update_status('Successfully disconnected from VPN.')
            self.update_ip_status()
        except subprocess.CalledProcessError:
            self.update_status('Error disconnecting from VPN.')
        finally:
            self.process = None
            self.connect_button.setEnabled(True)
            self.disconnect_button.setEnabled(False)

    def quit_program(self):
        if self.process:
            self.disconnect_vpn()  # Ensure VPN is disconnected
        self.close()

    def update_status(self, message):
        self.status_label.setText(f'Status: {message}')

    def update_ip_status(self):
        try:
            # Fetch the current IP address
            result = subprocess.run(['curl', '-s', 'ifconfig.me'], capture_output=True, text=True)
            if result.returncode == 0:
                ip_address = result.stdout.strip()
                self.ip_status_label.setText(f'IP Status: {ip_address}')
            else:
                self.ip_status_label.setText('IP Status: Error fetching IP address')
        except Exception as e:
            self.ip_status_label.setText(f'IP Status: Error {e}')

    def show_credits(self):
        QMessageBox.information(self, 'Credits', 'Developed by Engineer: Felipe Alfonso Gonzalez\nEmail: f.alfonso@res-ear.ch\nGitHub: github.com/felipealfonsog\nLicense: BSD 3-Clause')

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = VPNConnector()
    window.show()
    sys.exit(app.exec_())
