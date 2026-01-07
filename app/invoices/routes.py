from flask import render_template
from flask_login import login_required
from . import bp

@bp.route('/')
@login_required
def invoices():
    return render_template('invoices/invoices.html')

@bp.route('/credits')
@login_required
def credits():
    return render_template('invoices/credits.html')

@bp.route('/special-offer')
@login_required
def special_offer():
    return render_template('invoices/special_offer.html')
