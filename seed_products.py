import csv
import os
import re

from app import create_app
from app.extensions import db
from app.products.models import Product


def parse_price_to_int_mnt(value: str) -> int:
    """
    CSV has values like:
      "204,076.44"
    We convert to integer MNT:
      204076
    """
    if value is None:
        return 0
    s = str(value).strip()
    if not s:
        return 0

    # Remove commas and spaces
    s = s.replace(",", "").replace(" ", "")

    # Keep digits and dot only
    s = re.sub(r"[^0-9.]", "", s)
    if not s:
        return 0

    try:
        return int(round(float(s)))
    except ValueError:
        return 0


def seed_products_from_csv(csv_path: str):
    if not os.path.exists(csv_path):
        raise FileNotFoundError(f"CSV not found: {csv_path}")

    created = 0
    updated = 0

    with open(csv_path, "r", encoding="latin1", newline="") as f:
        reader = csv.DictReader(f)

        # Expected columns from your file:
        # Part number, Description, UOM, Unit Price
        for row in reader:
            part = (row.get("Part number") or "").strip()
            desc = (row.get("Description") or "").strip()
            uom = (row.get("UOM") or "").strip()
            price_raw = row.get("Unit Price")

            if not part or not desc:
                continue

            price_int = parse_price_to_int_mnt(price_raw)
            if price_int <= 0:
                continue

            existing = Product.query.filter_by(part_number=part).first()
            if existing:
                existing.description = desc
                existing.uom = uom or None
                existing.unit_price_mnt = price_int
                updated += 1
            else:
                db.session.add(
                    Product(
                        part_number=part,
                        description=desc,
                        uom=uom or None,
                        unit_price_mnt=price_int,
                    )
                )
                created += 1

    db.session.commit()
    return created, updated


if __name__ == "__main__":
    app = create_app()
    with app.app_context():
        csv_path = os.path.join("data", "product_catalog.csv")
        created, updated = seed_products_from_csv(csv_path)
        print(f"✅ Products seeded. Created: {created}, Updated: {updated}")
