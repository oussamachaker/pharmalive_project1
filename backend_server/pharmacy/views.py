from flask import Blueprint, request, make_response, jsonify
from flask.views import MethodView

from backend_server import bcrypt, db, ma
from backend_server.models import User, BlacklistToken, Pharmacy

from backend_server.utils import geocoding

pharmacy_blueprint = Blueprint(
    "pharmacy", __name__
)  # This blueprint is registered in __init__.py

# Pharmacy Schema
class PharmacySchema(ma.Schema):
    class Meta:
        fields = (
            "id",
            "pharmacy_name",
            "address",
            "phone_number",
            "longitude",
            "latitude",
            "available",
        )


# Init schema
pharmacy_schema = PharmacySchema()
pharmacies_schema = PharmacySchema(many=True)


class PharmacyRegistration(MethodView):
    """
    Add new pharmacy
    """

    def post(self):
        pharmacy_name = request.json["pharmacy_name"]
        address = request.json["address"]
        phone_number = request.json["phone_number"]
        available = request.json["available"]

        # Get the longitude and latitude from physical address
        latitude, longitude = geocoding(address=address)

        new_pharmacy = Pharmacy(
            pharmacy_name, address, phone_number, longitude, latitude, available
        )

        db.session.add(new_pharmacy)
        db.session.commit()

        return pharmacy_schema.jsonify(new_pharmacy)


class PharmacyDelete(MethodView):
    """
    Delete a pharmacy
    """

    def delete(self, id):
        pharmacy = Pharmacy.query.get(id)
        db.session.delete(pharmacy)
        db.session.commit()

        return pharmacy_schema.jsonify(pharmacy)


class PharmacyGetAll(MethodView):
    """
    Get all pharmacies
    """

    def get(self):
        all_pharmacies = Pharmacy.query.all()
        result = pharmacies_schema.dump(all_pharmacies)
        return jsonify(result)


class PharmacyGetById(MethodView):
    """
    Get a pharmacy given it's id
    """

    def get(self, id):
        pharmacy = Pharmacy.query.get(id)
        return pharmacy_schema.jsonify(pharmacy)


class PharmacyUpdate(MethodView):
    """
    Update pharmacy info
    """

    def put(self, id):
        pharmacy = Pharmacy.query.get(id)

        pharmacy_name = request.json["pharmacy_name"]
        address = request.json["address"]
        phone_number = request.json["phone_number"]
        available = request.json["available"]

        # Get the longitude and latitude from physical address
        latitude, longitude = geocoding(address=address)

        pharmacy.pharmacy_name = pharmacy_name
        pharmacy.address = address
        pharmacy.phone_number = phone_number
        pharmacy.longitude = longitude
        pharmacy.latitude = latitude
        pharmacy.available = available

        db.session.commit()

        return pharmacy_schema.jsonify(pharmacy)


# define the API resources
pharmacy_registration = PharmacyRegistration.as_view("pharmacy_registration")
pharmacy_update = PharmacyUpdate.as_view("pharmacy_update")
pharmacy_get_all = PharmacyGetAll.as_view("pharmacy_get_all")
pharmacy_get_by_id = PharmacyGetById.as_view("pharmacy_get_by_id")
pharmacy_delete = PharmacyDelete.as_view("pharmacy_delete")

# add Rules for API Endpoints
pharmacy_blueprint.add_url_rule(
    "/pharmacy", view_func=pharmacy_registration, methods=["POST"]
)
pharmacy_blueprint.add_url_rule(
    "/pharmacy", view_func=pharmacy_get_all, methods=["GET"]
)
pharmacy_blueprint.add_url_rule(
    "/pharmacy/<id>", view_func=pharmacy_get_by_id, methods=["GET"]
)
pharmacy_blueprint.add_url_rule(
    "/pharmacy/<id>", view_func=pharmacy_delete, methods=["PUT"]
)
