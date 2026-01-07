from flask import Blueprint
bp = Blueprint('milwaukee', __name__, url_prefix='/milwaukee')
from . import routes  # noqa
