# ==========================================
# Step 6 - Forms + DB save + Emails + ICS
# ==========================================

$ErrorActionPreference = "Stop"

Write-Host "Ensuring folders..." -ForegroundColor Cyan
$folders = @(
  "app\utils",
  "templates\milwaukee",
  "templates\contact",
  "templates\services"
)
foreach ($f in $folders) { New-Item -ItemType Directory -Force -Path $f | Out-Null }

Write-Host "Updating requirements.txt (add Flask-Mail)..." -ForegroundColor Cyan
$req = Get-Content "requirements.txt" -Raw
if ($req -notmatch "Flask-Mail") {
  $req = $req.TrimEnd() + "`r`nFlask-Mail==0.9.1`r`n"
  $req | Set-Content -Encoding UTF8 "requirements.txt"
}

Write-Host "Writing app/utils/email_utils.py ..." -ForegroundColor Cyan
@"
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
"@ | Set-Content -Encoding UTF8 -Path "app\utils\email_utils.py"

Write-Host "Writing app/forms_models.py ..." -ForegroundColor Cyan
@"
from datetime import datetime
from .extensions import db

class QuoteRequest(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(180), nullable=False, index=True)
    phone = db.Column(db.String(50), nullable=True)
    item = db.Column(db.String(200), nullable=False)
    quantity = db.Column(db.Integer, nullable=True)
    message = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class ContactMessage(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(180), nullable=False, index=True)
    subject = db.Column(db.String(200), nullable=False)
    message = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class TrainingRegistration(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(180), nullable=False, index=True)
    course = db.Column(db.String(200), nullable=False)
    phone = db.Column(db.String(50), nullable=True)
    notes = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
"@ | Set-Content -Encoding UTF8 -Path "app\forms_models.py"

Write-Host "Writing app/utils/forms.py ..." -ForegroundColor Cyan
@"
from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField, IntegerField, SelectField, SubmitField
from wtforms.validators import DataRequired, Email, Length, Optional, NumberRange

class QuoteRequestForm(FlaskForm):
    name = StringField("Name", validators=[DataRequired(), Length(max=120)])
    email = StringField("Email", validators=[DataRequired(), Email(), Length(max=180)])
    phone = StringField("Phone (optional)", validators=[Optional(), Length(max=50)])
    item = StringField("Item / Product / Service", validators=[DataRequired(), Length(max=200)])
    quantity = IntegerField("Quantity (optional)", validators=[Optional(), NumberRange(min=1)])
    message = TextAreaField("Message", validators=[DataRequired(), Length(max=3000)])
    submit = SubmitField("Submit Quote Request")

class ContactForm(FlaskForm):
    name = StringField("Name", validators=[DataRequired(), Length(max=120)])
    email = StringField("Email", validators=[DataRequired(), Email(), Length(max=180)])
    subject = StringField("Subject", validators=[DataRequired(), Length(max=200)])
    message = TextAreaField("Message", validators=[DataRequired(), Length(max=3000)])
    submit = SubmitField("Send Message")

class TrainingRegistrationForm(FlaskForm):
    name = StringField("Name", validators=[DataRequired(), Length(max=120)])
    email = StringField("Email", validators=[DataRequired(), Email(), Length(max=180)])
    course = SelectField("Course", choices=[
        ("Safety Basics", "Safety Basics"),
        ("Tool Handling", "Tool Handling"),
        ("Procurement 101", "Procurement 101"),
        ("Industrial Training", "Industrial Training"),
    ], validators=[DataRequired()])
    phone = StringField("Phone (optional)", validators=[Optional(), Length(max=50)])
    notes = TextAreaField("Notes (optional)", validators=[Optional(), Length(max=3000)])
    submit = SubmitField("Register")
"@ | Set-Content -Encoding UTF8 -Path "app\utils\forms.py"

Write-Host "DONE  Step 6 script created successfully." -ForegroundColor Green
