# ==========================================
# Step 5 - Pages + Navbar + Simple i18n (EN/MN)
# Creates:
# - app/i18n.py
# - blueprints: services, milwaukee, invoices, support, contact
# - templates for ALL required pages
# - updates templates/base.html navbar + language toggle
# ==========================================

$ErrorActionPreference = "Stop"

Write-Host "Ensuring folders exist..." -ForegroundColor Cyan

$folders = @(
  "app",
  "app\services",
  "app\milwaukee",
  "app\invoices",
  "app\support",
  "app\contact",
  "templates",
  "templates\services",
  "templates\milwaukee",
  "templates\invoices",
  "templates\support",
  "templates\contact"
)

foreach ($f in $folders) { New-Item -ItemType Directory -Force -Path $f | Out-Null }

Write-Host "Writing app/i18n.py ..." -ForegroundColor Cyan
@"
from flask import session, request

TRANSLATIONS = {
    "en": {
        "home": "Home",
        "about_us": "About Us",
        "our_vision": "Our Vision",
        "our_mission": "Our Mission",
        "services": "Services",
        "procurement": "Procurement",
        "training": "Training",
        "course_catalog": "Course Catalog",
        "registration": "Registration",
        "milwaukee": "Milwaukee",
        "products_catalog": "Products Catalog",
        "quote": "Quote",
        "buy": "Buy",
        "tool_rent": "Tool Rent",
        "safety": "Safety",
        "invoices_payments": "Invoices / Payments",
        "invoices": "Invoices",
        "credits": "Credits",
        "special_offer": "Special Offer",
        "support": "Support",
        "leave_message": "Leave Message",
        "faq": "FAQ",
        "contact_us": "Contact Us",
        "language": "Language",
        "signup": "Sign Up",
        "login": "Log In",
        "logout": "Log Out",
        "my_account": "My Account",
        "profile": "Profile",
        "page": "Page",
        "coming_soon": "This page is ready. Dynamic features will be added in the next steps."
    },
    "mn": {
        "home": "Нүүр",
        "about_us": "Бидний тухай",
        "our_vision": "Алсын хараа",
        "our_mission": "Эрхэм зорилго",
        "services": "Үйлчилгээ",
        "procurement": "Нийлүүлэлт",
        "training": "Сургалт",
        "course_catalog": "Сургалтын жагсаалт",
        "registration": "Бүртгэл",
        "milwaukee": "Milwaukee",
        "products_catalog": "Бүтээгдэхүүний каталог",
        "quote": "Үнийн санал",
        "buy": "Захиалга",
        "tool_rent": "Багаж түрээс",
        "safety": "Аюулгүй байдал",
        "invoices_payments": "Нэхэмжлэл / Төлбөр",
        "invoices": "Нэхэмжлэл",
        "credits": "Кредит",
        "special_offer": "Тусгай санал",
        "support": "Тусламж",
        "leave_message": "Мессеж үлдээх",
        "faq": "Түгээмэл асуулт",
        "contact_us": "Холбоо барих",
        "language": "Хэл",
        "signup": "Бүртгүүлэх",
        "login": "Нэвтрэх",
        "logout": "Гарах",
        "my_account": "Миний булан",
        "profile": "Профайл",
        "page": "Хуудас",
        "coming_soon": "Энэ хуудас бэлэн. Дараагийн алхмуудад динамик хэсгүүд нэмнэ."
    }
}

def get_lang():
    lang = session.get("lang")
    if lang in TRANSLATIONS:
        return lang
    # Default: browser preference -> en fallback
    accept = (request.accept_languages.best or "").lower()
    if accept.startswith("mn"):
        return "mn"
    return "en"

def t(key: str) -> str:
    lang = get_lang()
    return TRANSLATIONS.get(lang, TRANSLATIONS["en"]).get(key, key)
"@ | Set-Content -Encoding UTF8 -Path "app\i18n.py"

# --- Blueprints

Write-Host "Writing blueprint files..." -ForegroundColor Cyan

@"
from flask import Blueprint
bp = Blueprint('services', __name__, url_prefix='/services')
from . import routes  # noqa
"@ | Set-Content -Encoding UTF8 -Path "app\services\__init__.py"

@"
from flask import render_template
from . import bp

@bp.route('/procurement')
def procurement():
    return render_template('services/procurement.html')

@bp.route('/training')
def training():
    return render_template('services/training.html')

@bp.route('/training/catalog')
def course_catalog():
    return render_template('services/course_catalog.html')

@bp.route('/training/registration')
def training_registration():
    return render_template('services/training_registration.html')
"@ | Set-Content -Encoding UTF8 -Path "app\services\routes.py"

@"
from flask import Blueprint
bp = Blueprint('milwaukee', __name__, url_prefix='/milwaukee')
from . import routes  # noqa
"@ | Set-Content -Encoding UTF8 -Path "app\milwaukee\__init__.py"

@"
from flask import render_template
from flask_login import login_required
from . import bp

@bp.route('/products')
def products():
    return render_template('milwaukee/products.html')

@bp.route('/quote')
def quote():
    return render_template('milwaukee/quote.html')

@bp.route('/buy')
def buy():
    return render_template('milwaukee/buy.html')

@bp.route('/tool-rent')
def tool_rent():
    return render_template('milwaukee/tool_rent.html')

# protected placeholders (real checkout/receipt in later step)
@bp.route('/tool-rent/checkout')
@login_required
def tool_rent_checkout():
    return render_template('milwaukee/tool_rent_checkout.html')

@bp.route('/tool-rent/receipt')
@login_required
def tool_rent_receipt():
    return render_template('milwaukee/tool_rent_receipt.html')

@bp.route('/safety')
def safety():
    return render_template('milwaukee/safety.html')
"@ | Set-Content -Encoding UTF8 -Path "app\milwaukee\routes.py"

@"
from flask import Blueprint
bp = Blueprint('invoices', __name__, url_prefix='/invoices')
from . import routes  # noqa
"@ | Set-Content -Encoding UTF8 -Path "app\invoices\__init__.py"

@"
from flask import render_template
from flask_login import login_required
from . import bp

@bp.route('/')
@login_required
def invoices():
    return render_template('invoices/invoices.html')

@bp.route('/credits')
@login_required
def credits():
    return render_template('invoices/credits.html')

@bp.route('/special-offer')
@login_required
def special_offer():
    return render_template('invoices/special_offer.html')
"@ | Set-Content -Encoding UTF8 -Path "app\invoices\routes.py"

@"
from flask import Blueprint
bp = Blueprint('support', __name__, url_prefix='/support')
from . import routes  # noqa
"@ | Set-Content -Encoding UTF8 -Path "app\support\__init__.py"

@"
from flask import render_template
from . import bp

@bp.route('/leave-message')
def leave_message():
    return render_template('support/leave_message.html')

@bp.route('/faq')
def faq():
    return render_template('support/faq.html')
"@ | Set-Content -Encoding UTF8 -Path "app\support\routes.py"

@"
from flask import Blueprint
bp = Blueprint('contact', __name__, url_prefix='/contact')
from . import routes  # noqa
"@ | Set-Content -Encoding UTF8 -Path "app\contact\__init__.py"

@"
from flask import render_template
from . import bp

@bp.route('/')
def contact():
    return render_template('contact/contact.html')
"@ | Set-Content -Encoding UTF8 -Path "app\contact\routes.py"

# --- Templates (simple placeholders)

Write-Host "Writing templates..." -ForegroundColor Cyan

function Write-Page($path, $titleKey) {
@"
{% extends "base.html" %}
{% block content %}
<div class="bg-white border rounded-4 p-4 shadow-sm">
  <h1 class="h3 fw-bold mb-2">{{ t('$titleKey') }}</h1>
  <p class="text-muted mb-0">{{ t('coming_soon') }}</p>
</div>
{% endblock %}
"@ | Set-Content -Encoding UTF8 -Path $path
}

Write-Page "templates\services\procurement.html" "procurement"
Write-Page "templates\services\training.html" "training"
Write-Page "templates\services\course_catalog.html" "course_catalog"
Write-Page "templates\services\training_registration.html" "registration"

Write-Page "templates\milwaukee\products.html" "products_catalog"
Write-Page "templates\milwaukee\quote.html" "quote"
Write-Page "templates\milwaukee\buy.html" "buy"
Write-Page "templates\milwaukee\tool_rent.html" "tool_rent"
Write-Page "templates\milwaukee\tool_rent_checkout.html" "tool_rent"
Write-Page "templates\milwaukee\tool_rent_receipt.html" "tool_rent"
Write-Page "templates\milwaukee\safety.html" "safety"

Write-Page "templates\invoices\invoices.html" "invoices"
Write-Page "templates\invoices\credits.html" "credits"
Write-Page "templates\invoices\special_offer.html" "special_offer"

Write-Page "templates\support\leave_message.html" "leave_message"
Write-Page "templates\support\faq.html" "faq"

Write-Page "templates\contact\contact.html" "contact_us"

# --- Update templates/base.html with full navbar + language toggle (safe overwrite)

Write-Host "Updating templates/base.html navbar + language toggle..." -ForegroundColor Cyan
@"
<!doctype html>
<html lang="{{ get_lang() }}">
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
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMain">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navMain">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">

        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">{{ t('home') }}</a>
          <ul class="dropdown-menu">
            <li><a class="dropdown-item" href="{{ url_for('main.about') }}">{{ t('about_us') }}</a></li>
            <li><a class="dropdown-item" href="{{ url_for('main.vision') }}">{{ t('our_vision') }}</a></li>
            <li><a class="dropdown-item" href="{{ url_for('main.mission') }}">{{ t('our_mission') }}</a></li>
          </ul>
        </li>

        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">{{ t('services') }}</a>
          <ul class="dropdown-menu">
            <li><a class="dropdown-item" href="{{ url_for('services.procurement') }}">{{ t('procurement') }}</a></li>
            <li><hr class="dropdown-divider"></li>
            <li><a class="dropdown-item" href="{{ url_for('services.training') }}">{{ t('training') }}</a></li>
            <li><a class="dropdown-item" href="{{ url_for('services.course_catalog') }}">{{ t('course_catalog') }}</a></li>
            <li><a class="dropdown-item" href="{{ url_for('services.training_registration') }}">{{ t('registration') }}</a></li>
          </ul>
        </li>

        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">{{ t('milwaukee') }}</a>
          <ul class="dropdown-menu">
            <li><a class="dropdown-item" href="{{ url_for('milwaukee.products') }}">{{ t('products_catalog') }}</a></li>
            <li><a class="dropdown-item" href="{{ url_for('milwaukee.quote') }}">{{ t('quote') }}</a></li>
            <li><a class="dropdown-item" href="{{ url_for('milwaukee.buy') }}">{{ t('buy') }}</a></li>
            <li><a class="dropdown-item" href="{{ url_for('milwaukee.tool_rent') }}">{{ t('tool_rent') }}</a></li>
            <li><a class="dropdown-item" href="{{ url_for('milwaukee.safety') }}">{{ t('safety') }}</a></li>
          </ul>
        </li>

        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">{{ t('invoices_payments') }}</a>
          <ul class="dropdown-menu">
            <li><a class="dropdown-item" href="{{ url_for('invoices.invoices') }}">{{ t('invoices') }}</a></li>
            <li><a class="dropdown-item" href="{{ url_for('invoices.credits') }}">{{ t('credits') }}</a></li>
            <li><a class="dropdown-item" href="{{ url_for('invoices.special_offer') }}">{{ t('special_offer') }}</a></li>
          </ul>
        </li>

        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">{{ t('support') }}</a>
          <ul class="dropdown-menu">
            <li><a class="dropdown-item" href="{{ url_for('support.leave_message') }}">{{ t('leave_message') }}</a></li>
            <li><a class="dropdown-item" href="{{ url_for('support.faq') }}">{{ t('faq') }}</a></li>
          </ul>
        </li>

        <li class="nav-item">
          <a class="nav-link" href="{{ url_for('contact.contact') }}">{{ t('contact_us') }}</a>
        </li>
      </ul>

      <div class="d-flex align-items-center gap-2">

        <div class="btn-group btn-group-sm" role="group" aria-label="Language toggle">
          <a class="btn btn-outline-light" href="{{ url_for('main.set_language', lang='en') }}">EN</a>
          <a class="btn btn-outline-light" href="{{ url_for('main.set_language', lang='mn') }}">MN</a>
        </div>

        {% if current_user.is_authenticated %}
          <div class="dropdown">
            <a class="btn btn-light btn-sm dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
              {{ t('my_account') }}
            </a>
            <ul class="dropdown-menu dropdown-menu-end">
              <li><a class="dropdown-item" href="{{ url_for('main.profile') }}">{{ t('profile') }}</a></li>
              <li><hr class="dropdown-divider"></li>
              <li><a class="dropdown-item" href="{{ url_for('auth.logout') }}">{{ t('logout') }}</a></li>
            </ul>
          </div>
        {% else %}
          <a class="btn btn-outline-light btn-sm" href="{{ url_for('auth.signup') }}">{{ t('signup') }}</a>
          <a class="btn btn-light btn-sm" href="{{ url_for('auth.login') }}">{{ t('login') }}</a>
        {% endif %}
      </div>
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
  <div class="container small text-muted"> Grey Stone</div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
"@ | Set-Content -Encoding UTF8 -Path "templates\base.html"

Write-Host "DONE  Step 5 pages + navbar + i18n files created." -ForegroundColor Green
