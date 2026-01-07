from flask import Flask
from dotenv import load_dotenv

from .config import Config
from .extensions import db, migrate, login_manager, csrf

load_dotenv()

def create_app():
    app = Flask(
        __name__,
        template_folder="../templates",
        static_folder="../static"
    )
    app.config.from_object(Config)

    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    csrf.init_app(app)

    login_manager.login_view = "auth.login"

    from .models import User

    @login_manager.user_loader
    def load_user(user_id):
        return User.query.get(int(user_id))

    from .main import bp as main_bp
    from .auth import bp as auth_bp

    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp)

    return app
