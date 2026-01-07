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
