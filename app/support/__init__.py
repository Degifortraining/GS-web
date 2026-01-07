from flask import Blueprint
bp = Blueprint('support', __name__, url_prefix='/support')
from . import routes  # noqa
