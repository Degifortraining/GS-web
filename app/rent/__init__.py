from flask import Blueprint
bp = Blueprint('rent', __name__, url_prefix='/rent')
from . import routes  # noqa
