from flask import Flask, render_template
from dotenv import load_dotenv
import os

load_dotenv()

def create_app():
    app = Flask(
        __name__,
        template_folder="../templates",
        static_folder="../static"
    )

    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "dev-only-change-me")

    @app.route("/")
    def home():
        return render_template("main/home.html")

    return app
