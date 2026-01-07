from flask import render_template, redirect, url_for, flash
from flask_login import login_required

from ..extensions import db
from ..forms_models import QuoteRequest
from ..utils.forms import QuoteRequestForm
from ..utils.email_utils import send_basic_email

from ..products.models import Product  # NEW
from . import bp


@bp.route("/products")
def products():
    products = Product.query.order_by(Product.part_number.asc()).all()
    return render_template("milwaukee/products.html", products=products)


@bp.route("/quote", methods=["GET", "POST"])
def quote():
    form = QuoteRequestForm()
    if form.validate_on_submit():
        record = QuoteRequest(
            name=form.name.data.strip(),
            email=form.email.data.strip().lower(),
            phone=(form.phone.data.strip() if form.phone.data else None),
            item=form.item.data.strip(),
            quantity=form.quantity.data,
            message=form.message.data.strip(),
        )
        db.session.add(record)
        db.session.commit()

        send_basic_email(
            to_email=record.email,
            subject="Grey Stone - Quote request received",
            body=f"Hello {record.name},\n\nWe received your quote request for: {record.item}.\nWe will contact you soon.\n\n- Grey Stone",
        )

        flash("Quote request submitted successfully!", "success")
        return redirect(url_for("milwaukee.quote"))

    return render_template("milwaukee/quote.html", form=form)


@bp.route("/buy")
def buy():
    return render_template("milwaukee/buy.html")


@bp.route("/tool-rent")
def tool_rent():
    return render_template("milwaukee/tool_rent.html")


@bp.route("/tool-rent/checkout")
@login_required
def tool_rent_checkout():
    return render_template("milwaukee/tool_rent_checkout.html")


@bp.route("/tool-rent/receipt")
@login_required
def tool_rent_receipt():
    return render_template("milwaukee/tool_rent_receipt.html")


@bp.route("/safety")
def safety():
    return render_template("milwaukee/safety.html")
