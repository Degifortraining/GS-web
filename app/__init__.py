from flask import Flask
from dotenv import load_dotenv

from .config import Config
from .extensions import db, migrate, login_manager, csrf
from .i18n import t, get_lang
from .utils.email_utils import init_mail

load_dotenv()


def create_app():
    app = Flask(
        __name__,
        template_folder="../templates",
        static_folder="../static"
    )
    app.config.from_object(Config)

    # Extensions
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    csrf.init_app(app)

    # Email
    init_mail(app)

    login_manager.login_view = "auth.login"

    # Import models so migrations can detect them
    from .models import User  # noqa
    from .forms_models import QuoteRequest, ContactMessage, TrainingRegistration  # noqa
    from .rent.models import Tool, RentalRequest  # noqa
    from .payments.models import Order, Payment  # noqa
    from .products.models import Product  # noqa  <-- NEW

    @login_manager.user_loader
    def load_user(user_id):
        try:
            return User.query.get(int(user_id))
        except Exception:
            return None

    # Blueprints
    from .main import bp as main_bp
    from .auth import bp as auth_bp
    from .services import bp as services_bp
    from .milwaukee import bp as milwaukee_bp
    from .invoices import bp as invoices_bp
    from .support import bp as support_bp
    from .contact import bp as contact_bp
    from .rent import bp as rent_bp
    from .payments import bp as payments_bp

    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp)
    app.register_blueprint(services_bp)
    app.register_blueprint(milwaukee_bp)
    app.register_blueprint(invoices_bp)
    app.register_blueprint(support_bp)
    app.register_blueprint(contact_bp)
    app.register_blueprint(rent_bp)
    app.register_blueprint(payments_bp)

    @app.context_processor
    def inject_helpers():
        return {"t": t, "get_lang": get_lang}

    return app
