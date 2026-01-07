import os
from datetime import datetime, timedelta

from flask import current_app
from flask_mail import Mail, Message

mail = Mail()

def init_mail(app):
    app.config["MAIL_SERVER"] = os.getenv("MAIL_SERVER", "")
    app.config["MAIL_PORT"] = int(os.getenv("MAIL_PORT", "587"))
    app.config["MAIL_USE_TLS"] = os.getenv("MAIL_USE_TLS", "true").lower() == "true"
    app.config["MAIL_USERNAME"] = os.getenv("MAIL_USERNAME", "")
    app.config["MAIL_PASSWORD"] = os.getenv("MAIL_PASSWORD", "")
    app.config["MAIL_DEFAULT_SENDER"] = os.getenv("MAIL_DEFAULT_SENDER", app.config.get("MAIL_USERNAME", ""))

    mail.init_app(app)

def send_basic_email(to_email: str, subject: str, body: str):
    if not current_app.config.get("MAIL_SERVER") or not current_app.config.get("MAIL_USERNAME"):
        current_app.logger.warning("Email not sent (MAIL not configured).")
        return False

    msg = Message(subject=subject, recipients=[to_email], body=body)
    mail.send(msg)
    return True

def build_ics_event(title: str, description: str, start_dt: datetime, duration_minutes: int = 60, location: str = "Grey Stone (TBD)") -> str:
    end_dt = start_dt + timedelta(minutes=duration_minutes)

    def fmt(dt: datetime) -> str:
        return dt.strftime("%Y%m%dT%H%M%S")

    uid = f"{fmt(start_dt)}-greystone@local"

    ics = f"""BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Grey Stone//Training//EN
CALSCALE:GREGORIAN
METHOD:REQUEST
BEGIN:VEVENT
UID:{uid}
DTSTAMP:{fmt(datetime.utcnow())}
DTSTART:{fmt(start_dt)}
DTEND:{fmt(end_dt)}
SUMMARY:{title}
DESCRIPTION:{description}
LOCATION:{location}
END:VEVENT
END:VCALENDAR
"""
    return ics

def send_email_with_ics(to_email: str, subject: str, body: str, ics_content: str, filename: str = "invite.ics"):
    if not current_app.config.get("MAIL_SERVER") or not current_app.config.get("MAIL_USERNAME"):
        current_app.logger.warning("Email with ICS not sent (MAIL not configured).")
        return False

    msg = Message(subject=subject, recipients=[to_email], body=body)
    msg.attach(filename, "text/calendar", ics_content)
    mail.send(msg)
    return True
