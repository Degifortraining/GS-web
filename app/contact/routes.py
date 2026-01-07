from flask import render_template, redirect, url_for, flash

from ..extensions import db
from ..forms_models import ContactMessage
from ..utils.forms import ContactForm
from ..utils.email_utils import send_basic_email
from . import bp


@bp.route("/", methods=["GET", "POST"])
def contact():
    form = ContactForm()

    if form.validate_on_submit():
        record = ContactMessage(
            name=form.name.data.strip(),
            email=form.email.data.strip().lower(),
            subject=form.subject.data.strip(),
            message=form.message.data.strip(),
        )
        db.session.add(record)
        db.session.commit()

        # Send confirmation email (won't crash if SMTP not configured)
        send_basic_email(
            to_email=record.email,
            subject="Grey Stone - Message received",
            body=f"Hello {record.name},\n\nWe received your message:\nSubject: {record.subject}\n\nWe will reply soon.\n\n- Grey Stone",
        )

        flash("Message sent successfully!", "success")
        return redirect(url_for("contact.contact"))

    return render_template("contact/contact.html", form=form)
