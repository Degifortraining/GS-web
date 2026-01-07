from flask import render_template
from . import bp

@bp.route('/leave-message')
def leave_message():
    return render_template('support/leave_message.html')

@bp.route('/faq')
def faq():
    return render_template('support/faq.html')
