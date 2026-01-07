# ==========================================
# Step 4.1 - Auth + Models + Migrations Setup
# Creates/updates:
# - app/models.py (User model)
# - app/auth blueprint (routes + forms)
# - templates/auth/* (signup/login)
# - templates/base.html (navbar auth links)
# - app/__init__.py (real user_loader)
# - adds Flask CLI entry for migrations
# ==========================================

$ErrorActionPreference = "Stop"

Write-Host "Ensuring folders exist..." -ForegroundColor Cyan

$folders = @(
  "app",
  "app\auth",
  "templates",
  "templates\auth"
)

foreach ($f in $folders) {
  New-Item -ItemType Directory -Force -Path $f | Out-Null
}

Write-Host "Writing app/models.py ..." -ForegroundColor Cyan
@"
from datetime import datetime
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash

from .extensions import db

class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(180), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    is_admin = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def set_password(self, password: str):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password: str) -> bool:
        return check_password_hash(self.password_hash, password)
"@ | Set-Content -Encoding UTF8 -Path "app\models.py"

Write-Host "Writing app/auth/__init__.py ..." -ForegroundColor Cyan
@"
from flask import Blueprint

bp = Blueprint("auth", __name__, url_prefix="/auth")

from . import routes  # noqa
"@ | Set-Content -Encoding UTF8 -Path "app\auth\__init__.py"

Write-Host "Writing app/auth/forms.py ..." -ForegroundColor Cyan
@"
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import DataRequired, Email, Length, EqualTo

class SignUpForm(FlaskForm):
    name = StringField("Name", validators=[DataRequired(), Length(max=120)])
    email = StringField("Email", validators=[DataRequired(), Email(), Length(max=180)])
    password = PasswordField("Password", validators=[DataRequired(), Length(min=6, max=128)])
    confirm_password = PasswordField("Confirm Password", validators=[DataRequired(), EqualTo("password")])
    submit = SubmitField("Create Account")

class LoginForm(FlaskForm):
    email = StringField("Email", validators=[DataRequired(), Email(), Length(max=180)])
    password = PasswordField("Password", validators=[DataRequired(), Length(min=6, max=128)])
    submit = SubmitField("Log In")
"@ | Set-Content -Encoding UTF8 -Path "app\auth\forms.py"

Write-Host "Writing app/auth/routes.py ..." -ForegroundColor Cyan
@"
from flask import render_template, redirect, url_for, flash, request
from flask_login import login_user, logout_user, login_required, current_user

from ..extensions import db
from ..models import User
from .forms import SignUpForm, LoginForm
from . import bp

@bp.route("/signup", methods=["GET", "POST"])
def signup():
    if current_user.is_authenticated:
        return redirect(url_for("main.home"))

    form = SignUpForm()
    if form.validate_on_submit():
        existing = User.query.filter_by(email=form.email.data.strip().lower()).first()
        if existing:
            flash("Email already registered. Please log in.", "warning")
            return redirect(url_for("auth.login"))

        user = User(
            name=form.name.data.strip(),
            email=form.email.data.strip().lower(),
        )
        user.set_password(form.password.data)

        db.session.add(user)
        db.session.commit()

        login_user(user)
        flash("Account created. You are now logged in.", "success")
        return redirect(url_for("main.home"))

    return render_template("auth/signup.html", form=form)

@bp.route("/login", methods=["GET", "POST"])
def login():
    if current_user.is_authenticated:
        return redirect(url_for("main.home"))

    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(email=form.email.data.strip().lower()).first()
        if not user or not user.check_password(form.password.data):
            flash("Invalid email or password.", "danger")
            return render_template("auth/login.html", form=form)

        login_user(user)
        flash("Logged in successfully.", "success")

        next_url = request.args.get("next")
        return redirect(next_url or url_for("main.home"))

    return render_template("auth/login.html", form=form)

@bp.route("/logout")
@login_required
def logout():
    logout_user()
    flash("You have been logged out.", "info")
    return redirect(url_for("main.home"))
"@ | Set-Content -Encoding UTF8 -Path "app\auth\routes.py"

Write-Host "Writing templates/auth/signup.html ..." -ForegroundColor Cyan
@"
{% extends "base.html" %}
{% block content %}
<div class="row justify-content-center">
  <div class="col-md-6 col-lg-5">
    <div class="card shadow-sm border-0 rounded-4">
      <div class="card-body p-4">
        <h2 class="h4 fw-bold mb-3">Sign Up</h2>
        <form method="post">
          {{ form.csrf_token }}
          <div class="mb-3">
            <label class="form-label">Name</label>
            {{ form.name(class="form-control") }}
          </div>
          <div class="mb-3">
            <label class="form-label">Email</label>
            {{ form.email(class="form-control") }}
          </div>
          <div class="mb-3">
            <label class="form-label">Password</label>
            {{ form.password(class="form-control") }}
          </div>
          <div class="mb-3">
            <label class="form-label">Confirm Password</label>
            {{ form.confirm_password(class="form-control") }}
          </div>
          <div class="d-grid">
            {{ form.submit(class="btn btn-dark") }}
          </div>
        </form>
        <div class="mt-3 small">
          Already have an account? <a href="{{ url_for('auth.login') }}">Log in</a>
        </div>
      </div>
    </div>
  </div>
</div>
{% endblock %}
"@ | Set-Content -Encoding UTF8 -Path "templates\auth\signup.html"

Write-Host "Writing templates/auth/login.html ..." -ForegroundColor Cyan
@"
{% extends "base.html" %}
{% block content %}
<div class="row justify-content-center">
  <div class="col-md-6 col-lg-5">
    <div class="card shadow-sm border-0 rounded-4">
      <div class="card-body p-4">
        <h2 class="h4 fw-bold mb-3">Log In</h2>
        <form method="post">
          {{ form.csrf_token }}
          <div class="mb-3">
            <label class="form-label">Email</label>
            {{ form.email(class="form-control") }}
          </div>
          <div class="mb-3">
            <label class="form-label">Password</label>
            {{ form.password(class="form-control") }}
          </div>
          <div class="d-grid">
            {{ form.submit(class="btn btn-dark") }}
          </div>
        </form>
        <div class="mt-3 small">
          No account? <a href="{{ url_for('auth.signup') }}">Sign up</a>
        </div>
      </div>
    </div>
  </div>
</div>
{% endblock %}
"@ | Set-Content -Encoding UTF8 -Path "templates\auth\login.html"

Write-Host "Updating templates/base.html (navbar auth links + flash messages)..." -ForegroundColor Cyan
$base = Get-Content "templates\base.html" -Raw

# Insert flash messages and auth links in a safe way by replacing entire base.html with a compatible version.
@"
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Grey Stone</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container">
    <a class="navbar-brand fw-semibold" href="{{ url_for('main.home') }}">Grey Stone</a>

    <div class="ms-auto d-flex gap-2">
      {% if current_user.is_authenticated %}
        <a class="btn btn-outline-light btn-sm" href="{{ url_for('auth.logout') }}">Log Out</a>
      {% else %}
        <a class="btn btn-outline-light btn-sm" href="{{ url_for('auth.signup') }}">Sign Up</a>
        <a class="btn btn-light btn-sm" href="{{ url_for('auth.login') }}">Log In</a>
      {% endif %}
    </div>
  </div>
</nav>

<main class="container py-4">

  {% with messages = get_flashed_messages(with_categories=true) %}
    {% if messages %}
      <div class="mb-3">
        {% for category, message in messages %}
          <div class="alert alert-{{ category }} mb-2" role="alert">{{ message }}</div>
        {% endfor %}
      </div>
    {% endif %}
  {% endwith %}

  {% block content %}{% endblock %}
</main>

<footer class="border-top py-3 mt-4 bg-white">
  <div class="container small text-muted">
     Grey Stone
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
"@ | Set-Content -Encoding UTF8 -Path "templates\base.html"

Write-Host "Updating app/__init__.py (real user_loader + register auth blueprint)..." -ForegroundColor Cyan
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
"@ | Set-Content -Encoding UTF8 -Path "app\__init__.py"

Write-Host "DONE  Step 4.1 auth files created/updated." -ForegroundColor Green
