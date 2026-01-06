Write-Host "Ensuring folders exist..." -ForegroundColor Cyan

$folders = @(
  "app",
  "app\main",
  "templates",
  "templates\main"
)

foreach ($f in $folders) {
  New-Item -ItemType Directory -Force -Path $f | Out-Null
}

Write-Host "Updating requirements.txt (adds Step 3 dependencies)..." -ForegroundColor Cyan

@"
Flask==3.0.3
python-dotenv==1.0.1
Flask-SQLAlchemy==3.1.1
Flask-Migrate==4.0.7
Flask-Login==0.6.3
Flask-WTF==1.2.1
email-validator==2.2.0
Werkzeug==3.0.3
"@ | Set-Content -Encoding UTF8 -Path "requirements.txt"

Write-Host "Writing app/extensions.py ..." -ForegroundColor Cyan
@"
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from flask_wtf import CSRFProtect

db = SQLAlchemy()
migrate = Migrate()
login_manager = LoginManager()
csrf = CSRFProtect()
"@ | Set-Content -Encoding UTF8 -Path "app\extensions.py"

Write-Host "Writing app/config.py ..." -ForegroundColor Cyan
@"
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "dev-only-change-me")
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///greystone.db")

    SQLALCHEMY_DATABASE_URI = DATABASE_URL
    SQLALCHEMY_TRACK_MODIFICATIONS = False
"@ | Set-Content -Encoding UTF8 -Path "app\config.py"

Write-Host "Writing app/main/__init__.py ..." -ForegroundColor Cyan
@"
from flask import Blueprint

bp = Blueprint("main", __name__)

from . import routes  # noqa
"@ | Set-Content -Encoding UTF8 -Path "app\main\__init__.py"

Write-Host "Writing app/main/routes.py ..." -ForegroundColor Cyan
@"
from flask import render_template
from . import bp

@bp.route("/")
def home():
    return render_template("main/home.html")
"@ | Set-Content -Encoding UTF8 -Path "app\main\routes.py"

Write-Host "Updating app/__init__.py (register blueprint + extensions)..." -ForegroundColor Cyan
@"
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

    login_manager.login_view = "auth.login"  # will exist later

    from .main import bp as main_bp
    app.register_blueprint(main_bp)

    return app
"@ | Set-Content -Encoding UTF8 -Path "app\__init__.py"

Write-Host "Writing templates/main/home.html ..." -ForegroundColor Cyan
@"
{% extends "base.html" %}
{% block content %}
<div class="p-4 p-md-5 bg-white border rounded-3 shadow-sm">
  <h1 class="display-6 fw-bold mb-2">Grey Stone</h1>
  <p class="lead mb-0">Step 3 OK: Blueprints + extensions loaded successfully.</p>
</div>
{% endblock %}
"@ | Set-Content -Encoding UTF8 -Path "templates\main\home.html"

Write-Host ""
Write-Host "DONE  Step 3 upgrade applied." -ForegroundColor Green
