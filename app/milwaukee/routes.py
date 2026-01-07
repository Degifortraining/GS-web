from flask import render_template
from flask_login import login_required
from . import bp

@bp.route('/products')
def products():
    return render_template('milwaukee/products.html')

@bp.route('/quote')
def quote():
    return render_template('milwaukee/quote.html')

@bp.route('/buy')
def buy():
    return render_template('milwaukee/buy.html')

@bp.route('/tool-rent')
def tool_rent():
    return render_template('milwaukee/tool_rent.html')

# protected placeholders (real checkout/receipt in later step)
@bp.route('/tool-rent/checkout')
@login_required
def tool_rent_checkout():
    return render_template('milwaukee/tool_rent_checkout.html')

@bp.route('/tool-rent/receipt')
@login_required
def tool_rent_receipt():
    return render_template('milwaukee/tool_rent_receipt.html')

@bp.route('/safety')
def safety():
    return render_template('milwaukee/safety.html')
