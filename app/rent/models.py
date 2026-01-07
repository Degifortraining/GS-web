from datetime import datetime
from ..extensions import db


class Tool(db.Model):
    id = db.Column(db.Integer, primary_key=True)

    # NEW: used to show image from static/products/<part_number>.png
    part_number = db.Column(db.String(80), nullable=True, index=True)

    name = db.Column(db.String(160), nullable=False)
    description = db.Column(db.Text, nullable=True)

    # Required by spec (we will use 1-7 day price here)
    daily_price = db.Column(db.Integer, nullable=False)  # MNT int

    # Optional extra tier from your Excel (8-30 days)
    daily_price_8_30 = db.Column(db.Integer, nullable=True)  # MNT int

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
