from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
import os

# Init app
app = Flask(__name__)
basedir = os.path.abspath(os.path.dirname(__file__))

# Database
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///" + os.path.join(
    basedir, "db.sqlite"
)
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

# Init db
db = SQLAlchemy(app)

# Init marshmallow
ma = Marshmallow(app)


# Product Class/Model
class Pharmacy(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True)
    address = db.Column(db.String(100))
    coordinates = db.Column(db.String(100))

    def __init__(self, name, address, coordinates):
        self.name = name
        self.address = address
        self.coordinates = coordinates


# Pharmacy Schema
class PharmacySchema(ma.Schema):
    class Meta:
        fields = ("id", "name", "address", "coordinates")


# Init schema
pharmacy_schema = PharmacySchema()
pharmacies_schema = PharmacySchema(many=True)


# Add a pharmacy
@app.route("/pharmacy", methods=["POST"])
def add_product():
    name = request.json["name"]
    address = request.json["address"]
    coordinates = request.json["coordinates"]

    new_pharmacy = Pharmacy(name, address, coordinates)

    db.session.add(new_pharmacy)
    db.session.commit()

    return pharmacy_schema.jsonify(new_pharmacy)


# Get All Pharmacies
@app.route("/pharmacy", methods=["GET"])
def get_pharmacies():
    all_pharmacies = Pharmacy.query.all()
    result = pharmacies_schema.dump(all_pharmacies)
    return jsonify(result)


# Get Single Pharmacy given by it's id
@app.route("/pharmacy/<id>", methods=["GET"])
def get_pharmacy(id):
    pharmacy = Pharmacy.query.get(id)
    return pharmacy_schema.jsonify(pharmacy)


# Update a Pharmacy
@app.route("/pharmacy/<id>", methods=["PUT"])
def update_pharmacy(id):
    pharmacy = Pharmacy.query.get(id)

    name = request.json["name"]
    address = request.json["address"]
    coordinates = request.json["coordinates"]

    pharmacy.name = name
    pharmacy.address = address
    pharmacy.coordinates = coordinates

    db.session.commit()

    return pharmacy_schema.jsonify(pharmacy)


# Delete Pharmacy
@app.route("/pharmacy/<id>", methods=["DELETE"])
def delete_pharmacy(id):
    pharmacy = Pharmacy.query.get(id)
    db.session.delete(pharmacy)
    db.session.commit()

    return pharmacy_schema.jsonify(pharmacy)


# Run Server
if __name__ == "__main__":
    app.run(debug=True)

