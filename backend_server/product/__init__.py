from backend_server import app
from backend_server.pharmacy.views import pharmacy_blueprint
app.register_blueprint(product_blueprint)