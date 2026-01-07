from flask import Blueprint
bp = Blueprint('payments', __name__, url_prefix='')
from . import routes  # noqa
