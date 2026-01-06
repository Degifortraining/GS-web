from flask import Flask
from dotenv import load_dotenv

from .config import Config
from .extensions import db, migrate, login_manager, csrf

load_dotenv()


@login_manager.user_loader
def load_user(user_id):
    # Step 3: We don't have a User model yet (that's Step 4),
    # so we return None for now to keep Flask-Login happy.
    return None


def create_app():
    app = Flask(
        __name__,
        template_folder="../templates",
        static_folder="../static"
    )
    app.config.from_object(Config)

    # Init extensions
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    csrf.init_app(app)

    # This endpoint will exist in Step 4 (Auth). It's OK for now.
    login_manager.login_view = "auth.login"

    # Register blueprints
    from .main import bp as main_bp
    app.register_blueprint(main_bp)

    return app
