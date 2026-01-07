from flask import render_template
from flask_login import login_required, current_user

from .models import Order, Payment
from . import bp

@bp.route('/checkout/<int:order_id>')
@login_required
def checkout(order_id):
    order = Order.query.get_or_404(order_id)
    if order.user_id != current_user.id:
        return "Forbidden", 403

    payment = Payment.query.filter_by(order_id=order.id).first()
    return render_template('payments/checkout.html', order=order, payment=payment)
