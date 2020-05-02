from flask import Blueprint, request, jsonify
from sqlalchemy.sql import text
from flask.views import MethodView

from backend_server import db, ma

usecaseAziz_blueprint = Blueprint(
    "usecaseAziz", __name__
)  # This blueprint is registered in __init__.py

class ResultSchema(ma.Schema):
        class Meta:
            fields = (
                "pharmacy_name",
                "address",
                "longitude",
                "latitude",
                "quantity",
                "last_update",
            )

class usecaseAziz(MethodView) :

    def get(self)

        lat1 = request.json["latitude1"]
        long1 = request.json["longitude1"]
        lat2 = request.json["latitude2"]
        long2 = request.json["longitude2"]

        if lat1 < lat2:
            A = lat1
            B = lat2
        else:
            A = lat2
            B = lat1	

        if long1 < long2 :
            C = long1
            D = long2
        else:
            C = long2
            D = long1	

        query = text('SELECT pharmacy_name, address, longitude, latitude, quantity, last_update FROM pharmacies AS ph FULL JOIN products AS pr on ph.pharmacist_id = pr.pharmacist_id WHERE (ph.longitude BETWEEN :A AND :B) AND (ph.latitude BETWEEN :C AND :D)') 

        result = db.engine.execute(query)

        output = results_schema.dump(result)

        return jsonify(output)

# define the API resources
usecase_aziz = PharmacyRegistration.as_view("usecase_aziz")

# add Rules for API Endpoints
usecaseAziz_blueprint.add_url_rule(
    "/usecaseAziz", view_func=usecase_aziz, methods=["GET"]
)