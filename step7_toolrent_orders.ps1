$ErrorActionPreference = "Stop"

Write-Host "Creating folders..." -ForegroundColor Cyan
$folders = @(
  "app\rent",
  "app\payments",
  "templates\milwaukee",
  "templates\payments"
)
foreach ($f in $folders) { New-Item -ItemType Directory -Force -Path $f | Out-Null }

Write-Host "Writing app/payments/models.py ..." -ForegroundColor Cyan
@"
from datetime import datetime
from ..extensions import db

class Order(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    total_amount = db.Column(db.Integer, nullable=False)  # MNT int
    status = db.Column(db.String(20), default='pending', nullable=False)  # pending/paid/cancelled/completed
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Payment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    order_id = db.Column(db.Integer, db.ForeignKey('order.id'), nullable=False)
    method = db.Column(db.String(20), nullable=True)  # qpay/bank
    amount = db.Column(db.Integer, nullable=False)  # MNT int
    status = db.Column(db.String(20), default='unpaid', nullable=False)  # unpaid/paid/failed

    qpay_invoice_id = db.Column(db.String(120), nullable=True)
    qpay_qr_text = db.Column(db.Text, nullable=True)
    qpay_payment_url = db.Column(db.Text, nullable=True)

    bank_reference = db.Column(db.String(120), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
"@ | Set-Content -Encoding UTF8 -Path "app\payments\models.py"

Write-Host "Writing app/payments/__init__.py ..." -ForegroundColor Cyan
@"
from flask import Blueprint
bp = Blueprint('payments', __name__, url_prefix='')
from . import routes  # noqa
"@ | Set-Content -Encoding UTF8 -Path "app\payments\__init__.py"

Write-Host "Writing app/payments/routes.py ..." -ForegroundColor Cyan
@"
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
"@ | Set-Content -Encoding UTF8 -Path "app\payments\routes.py"

Write-Host "Writing app/rent/models.py ..." -ForegroundColor Cyan
@"
from datetime import datetime
from ..extensions import db

class Tool(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(160), nullable=False)
    description = db.Column(db.Text, nullable=True)
    daily_price = db.Column(db.Integer, nullable=False)  # MNT int
    available_qty = db.Column(db.Integer, nullable=False, default=1)

class RentalRequest(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

    tool_id = db.Column(db.Integer, db.ForeignKey('tool.id'), nullable=False)
    start_date = db.Column(db.Date, nullable=False)
    end_date = db.Column(db.Date, nullable=False)
    quantity = db.Column(db.Integer, nullable=False, default=1)

    days = db.Column(db.Integer, nullable=False)
    total_cost = db.Column(db.Integer, nullable=False)  # MNT int

    order_id = db.Column(db.Integer, db.ForeignKey('order.id'), nullable=True)

    created_at = db.Column(db.DateTime, default=datetime.utcnow)
"@ | Set-Content -Encoding UTF8 -Path "app\rent\models.py"

Write-Host "Writing app/rent/__init__.py ..." -ForegroundColor Cyan
@"
from flask import Blueprint
bp = Blueprint('rent', __name__, url_prefix='/rent')
from . import routes  # noqa
"@ | Set-Content -Encoding UTF8 -Path "app\rent\__init__.py"

Write-Host "Writing app/rent/routes.py ..." -ForegroundColor Cyan
@"
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
"@ | Set-Content -Encoding UTF8 -Path "app\rent\routes.py"

Write-Host "Writing templates/milwaukee/tool_rent.html ..." -ForegroundColor Cyan
@"
{% extends "base.html" %}
{% block content %}
<div class="bg-white border rounded-4 p-4 shadow-sm">
  <h1 class="h3 fw-bold mb-3">{{ t('tool_rent') }}</h1>
  <p class="text-muted">Choose a tool, dates, and quantity. Total will be calculated after submit.</p>

  <div class="table-responsive">
    <table class="table align-middle">
      <thead>
        <tr>
          <th>Tool</th>
          <th>Description</th>
          <th>Daily Price (MNT)</th>
          <th>Available</th>
          <th style="width: 340px;">Rent</th>
        </tr>
      </thead>
      <tbody>
        {% for tool in tools %}
        <tr>
          <td class="fw-semibold">{{ tool.name }}</td>
          <td class="text-muted small">{{ tool.description }}</td>
          <td>{{ tool.daily_price }}</td>
          <td>{{ tool.available_qty }}</td>
          <td>
            <form method="post" action="{{ url_for('rent.tools') }}" class="row g-2">
              <input type="hidden" name="tool_id" value="{{ tool.id }}">
              <div class="col-6">
                <input type="date" name="start_date" class="form-control form-control-sm" required>
              </div>
              <div class="col-6">
                <input type="date" name="end_date" class="form-control form-control-sm" required>
              </div>
              <div class="col-6">
                <input type="number" name="quantity" min="1" max="{{ tool.available_qty }}" value="1" class="form-control form-control-sm" required>
              </div>
              <div class="col-6">
                <button class="btn btn-dark btn-sm w-100" type="submit">Checkout</button>
              </div>
            </form>
          </td>
        </tr>
        {% endfor %}
        {% if tools|length == 0 %}
        <tr><td colspan="5" class="text-muted">No tools yet. We will seed tools in the next step.</td></tr>
        {% endif %}
      </tbody>
    </table>
  </div>
</div>
{% endblock %}
"@ | Set-Content -Encoding UTF8 -Path "templates\milwaukee\tool_rent.html"

Write-Host "Writing templates/payments/checkout.html ..." -ForegroundColor Cyan
@"
{% extends "base.html" %}
{% block content %}
<div class="bg-white border rounded-4 p-4 shadow-sm">
  <h1 class="h3 fw-bold mb-3">Checkout</h1>

  <div class="border rounded-4 p-3 bg-light mb-3">
    <div><b>Order ID:</b> {{ order.id }}</div>
    <div><b>Total:</b> {{ order.total_amount }} MNT</div>
    <div><b>Status:</b> {{ order.status }}</div>
  </div>

  <p class="text-muted mb-2">Payment methods will be enabled in Step 8 (QPay + Bank).</p>

  <div class="d-flex gap-2">
    <button class="btn btn-outline-dark" disabled>Pay with QPay</button>
    <button class="btn btn-outline-dark" disabled>Pay with Bank Transfer</button>
  </div>
</div>
{% endblock %}
"@ | Set-Content -Encoding UTF8 -Path "templates\payments\checkout.html"

Write-Host "DONE  Step 7 files created." -ForegroundColor Green
