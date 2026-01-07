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
