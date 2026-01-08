import os
from flask import Flask
from dotenv import load_dotenv

from .extensions import db, migrate, login_manager


def create_app():
    load_dotenv()

    app = Flask(__name__, instance_relative_config=True)

    # --- Config ---
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "change-me")
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL", "sqlite:///greystone.db")
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    # --- Init extensions ---
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)

    # --- Blueprints (your project uses `bp` names) ---
    from app.main.routes import bp as main_bp
    from app.services.routes import bp as services_bp
    from app.milwaukee.routes import bp as milwaukee_bp
    from app.invoices.routes import bp as invoices_bp
    from app.support.routes import bp as support_bp
    from app.contact.routes import bp as contact_bp
    from app.auth.routes import bp as auth_bp

    app.register_blueprint(main_bp)
    app.register_blueprint(services_bp)
    app.register_blueprint(milwaukee_bp)
    app.register_blueprint(invoices_bp)
    app.register_blueprint(support_bp)
    app.register_blueprint(contact_bp)
    app.register_blueprint(auth_bp)

    return app
