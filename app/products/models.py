from datetime import datetime
from ..extensions import db


class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)

    part_number = db.Column(db.String(80), unique=True, nullable=False, index=True)
    description = db.Column(db.Text, nullable=False)
    uom = db.Column(db.String(40), nullable=True)

    unit_price_mnt = db.Column(db.Integer, nullable=False)  # store MNT as int

    created_at = db.Column(db.DateTime, default=datetime.utcnow)
