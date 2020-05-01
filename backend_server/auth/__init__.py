from backend_server import app
from backend_server.auth.views import auth_blueprint
app.register_blueprint(auth_blueprint)