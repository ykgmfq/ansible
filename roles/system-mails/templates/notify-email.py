#!/usr/bin/python3
import subprocess
import ssl
import platform
from argparse import ArgumentParser
from smtplib import SMTP_SSL
from email.message import EmailMessage

parser = ArgumentParser(description="Send system status mails.")
parser.add_argument("service", help="Service name")

args = parser.parse_args()
service_name = args.service
host_name = platform.node()

status = subprocess.check_output(
    ["/usr/bin/systemctl", "-l", "--no-pager", "status", service_name],
    universal_newlines=True,
)
message = EmailMessage()
message["From"] = "Failure Notifier"
message["To"] = "private@dm-poepperl.de"
message["Subject"] = f"Failure of {service_name} on {host_name} ☹"
message.set_content(status)

port = 465  # For SSL
smtp_server = "smtp.strato.de"
password = "{{ secrets.mails.pw }}"
sender_email = "{{ mail_smtpname }}"
with SMTP_SSL(smtp_server, port, context=ssl.create_default_context()) as server:
    server.login(sender_email, password)
    server.send_message(message)
