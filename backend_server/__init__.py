import os

from flask import Flask
from flask_bcrypt import Bcrypt
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

app_settings = os.getenv("APP_SETTINGS", "backend_server.config.DevelopmentConfig")
app.config.from_object(app_settings)

bcrypt = Bcrypt(app)
# Init db
db = SQLAlchemy(app)
# Init marshmallow
ma = Marshmallow(app)

from backend_server.auth.views import auth_blueprint
from backend_server.pharmacy.views import pharmacy_blueprint

app.register_blueprint(auth_blueprint)
app.register_blueprint(pharmacy_blueprint)
