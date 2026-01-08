from flask import Blueprint, render_template
from flask_login import login_required

from app.rent.models import Tool

milwaukee_bp = Blueprint("milwaukee", __name__, url_prefix="/milwaukee")


@milwaukee_bp.route("/products")
def products():
    return render_template("milwaukee/products.html")


@milwaukee_bp.route("/quote", methods=["GET", "POST"])
def quote():
    return render_template("milwaukee/quote.html")


@milwaukee_bp.route("/buy", methods=["GET", "POST"])
def buy():
    return render_template("milwaukee/buy.html")


@milwaukee_bp.route("/safety")
def safety():
    return render_template("milwaukee/safety.html")


# ✅ Support BOTH URLs: /tool_rent and /tool-rent
@milwaukee_bp.route("/tool_rent")
@milwaukee_bp.route("/tool-rent")
@login_required
def tool_rent():
    tools = Tool.query.order_by(Tool.id.desc()).all()
    return render_template("milwaukee/tool_rent.html", tools=tools)


# ✅ Support BOTH checkout URLs too
@milwaukee_bp.route("/tool_rent/checkout", methods=["GET", "POST"])
@milwaukee_bp.route("/tool-rent/checkout", methods=["GET", "POST"])
@login_required
def tool_rent_checkout():
    return render_template("milwaukee/tool_rent_checkout.html")
