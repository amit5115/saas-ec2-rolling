import smtplib
from email.message import EmailMessage
import sys
import os

ENV = sys.argv[1]

EMAIL_TO = "amitcool5115@gmail.com"
EMAIL_FROM = "amitcool5115@gmail.com"
APP_PASSWORD = os.environ.get("GMAIL_APP_PASSWORD")

if not APP_PASSWORD:
    print("❌ GMAIL_APP_PASSWORD env variable not set")
    sys.exit(1)

msg = EmailMessage()
msg["Subject"] = f"[APPROVAL REQUIRED] Terraform destructive change – {ENV}"
msg["From"] = EMAIL_FROM
msg["To"] = EMAIL_TO

msg.set_content(f"""
Terraform detected destructive changes in environment: {ENV}

To approve, create this file:

approvals/approve-{ENV}.txt

Then re-run the self-service command.
""")

with smtplib.SMTP("smtp.gmail.com", 587) as server:
    server.starttls()
    server.login(EMAIL_FROM, APP_PASSWORD)
    server.send_message(msg)

print("📧 Approval email sent successfully")
