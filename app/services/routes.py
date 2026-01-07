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
