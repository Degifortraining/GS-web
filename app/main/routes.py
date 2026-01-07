from flask import render_template, redirect, url_for, session
from flask_login import login_required, current_user
from . import bp

@bp.route("/")
def home():
    return render_template("main/home.html")

@bp.route("/about")
def about():
    return render_template("main/about.html")

@bp.route("/vision")
def vision():
    return render_template("main/vision.html")

@bp.route("/mission")
def mission():
    return render_template("main/mission.html")

@bp.route("/profile")
@login_required
def profile():
    return render_template("main/profile.html", user=current_user)

@bp.route("/lang/<lang>")
def set_language(lang):
    if lang in ("en", "mn"):
        session["lang"] = lang
    return redirect(url_for("main.home"))
