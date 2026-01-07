from datetime import datetime
from flask import render_template, redirect, url_for, flash, request
from flask_login import login_required, current_user

from ..extensions import db
from ..payments.models import Order, Payment
from .models import Tool, RentalRequest
from . import bp

def calc_days(start_date, end_date):
    delta = (end_date - start_date).days + 1
    return max(delta, 1)

@bp.route('/tools', methods=['GET', 'POST'])
@login_required
def tools():
    tools = Tool.query.order_by(Tool.name.asc()).all()

    if request.method == 'POST':
        tool_id = int(request.form.get('tool_id'))
        start_str = request.form.get('start_date')
        end_str = request.form.get('end_date')
        qty = int(request.form.get('quantity') or 1)

        tool = Tool.query.get_or_404(tool_id)

        start_date = datetime.strptime(start_str, '%Y-%m-%d').date()
        end_date = datetime.strptime(end_str, '%Y-%m-%d').date()

        if end_date < start_date:
            flash("End date must be after start date.", "danger")
            return redirect(url_for('rent.tools'))

        if qty < 1 or qty > tool.available_qty:
            flash("Invalid quantity.", "danger")
            return redirect(url_for('rent.tools'))

        days = calc_days(start_date, end_date)
        total_cost = days * tool.daily_price * qty

        rental = RentalRequest(
            user_id=current_user.id,
            tool_id=tool.id,
            start_date=start_date,
            end_date=end_date,
            quantity=qty,
            days=days,
            total_cost=total_cost,
        )
        db.session.add(rental)
        db.session.flush()

        order = Order(
            user_id=current_user.id,
            total_amount=total_cost,
            status='pending'
        )
        db.session.add(order)
        db.session.flush()

        payment = Payment(
            order_id=order.id,
            amount=total_cost,
            status='unpaid'
        )
        db.session.add(payment)

        rental.order_id = order.id
        db.session.commit()

        flash("Rental request created. Please choose payment method.", "success")
        return redirect(url_for('payments.checkout', order_id=order.id))

    return render_template('milwaukee/tool_rent.html', tools=tools)
