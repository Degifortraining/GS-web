import os
from flask import Flask
from dotenv import load_dotenv

from .extensions import db, migrate, login_manager


def create_app():
    load_dotenv()

    app = Flask(__name__, instance_relative_config=True)

    # --- Config ---
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "change-me")
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL") or os.getenv("DATABASE_URL".lower()) or os.getenv("DATABASE_URL".upper())  # compatibility
    if not app.config["SQLALCHEMY_DATABASE_URI"]:
        app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL", "") or os.getenv("DATABASE_URI", "") or os.getenv("DATABASE_URL".lower(), "")
    # your project uses DATABASE_URL in .env, but you showed DATABASE_URL=sqlite:///greystone.db earlier
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL", os.getenv("DATABASE_URI", os.getenv("DATABASE_URL", "sqlite:///greystone.db")))
    # If you use DATABASE_URL=sqlite:///greystone.db this works.
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    # --- Init extensions ---
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)

    # --- Blueprints ---
    from app.main.routes import main_bp
    from app.services.routes import services_bp
    from app.milwaukee.routes import milwaukee_bp
    from app.invoices.routes import invoices_bp
    from app.support.routes import support_bp
    from app.contact.routes import contact_bp
    from app.auth.routes import auth_bp

    app.register_blueprint(main_bp)
    app.register_blueprint(services_bp)
    app.register_blueprint(milwaukee_bp)   # ✅ this creates endpoint names like milwaukee.products
    app.register_blueprint(invoices_bp)
    app.register_blueprint(support_bp)
    app.register_blueprint(contact_bp)
    app.register_blueprint(auth_bp)

    return app
