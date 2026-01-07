from flask import render_template
from . import bp

@bp.route('/')
def contact():
    return render_template('contact/contact.html')
