from flask import Blueprint, request, jsonify
from flask.views import MethodView

from backend_server import db, ma
from backend_server.models import Products

pharmacy_blueprint = Blueprint(
    "product", __name__
)  # This blueprint is registered in __init__.py

# Pharmacy Schema
class ProductSchema(ma.Schema):
    class Meta:
        fields = (
            "id",
            "product_name",
            "quantity",
            "last_update",
            "pharmacist_id",
        )


# Init schema
product_schema = ProductSchema()
products_schema = ProductSchema(many=True)


class ProductRegistration(MethodView):
    """
    Add new product
    """

    def post(self):
        product_name = request.json["product_name"]
        quantity = request.json["quantity"]
        last_update = request.json["last_update"]
        pharmacist_id = request.json["pharmacist_id"]

        new_product = Products(
            product_name, quantity, last_update, pharmacist_id
        )

        db.session.add(new_product)
        db.session.commit()

        return product_schema.jsonify(new_product)


class ProductDelete(MethodView):
    """
    Delete a product
    """

    def delete(self, id):
        product = Products.query.get(id)
        db.session.delete(product)
        db.session.commit()

        return product_schema.jsonify(product)


class ProductGetAll(MethodView):
    """
    Get all products
    """

    def get(self):
        all_products = Products.query.all()
        result = products_schema.dump(all_products)
        return jsonify(result)


class ProductGetById(MethodView):
    """
    Get a pharmacy given it's id
    """

    def get(self, id):
        product = Products.query.get(id)
        return product_schema.jsonify(product)


class ProductUpdate(MethodView):
    """
    Update product info
    """

    def put(self, id):
        product = Products.query.get(id)

        product_name = request.json["product_name"]
        quantity = request.json["quantity"]
        last_update = request.json["last_update"]
        pharmacist_id = request.json["pharmacist_id]

        product.product_name = product_name
        product.quantity = quantity
        product.last_update = last_update
        product.pharmacist_id = pharmacist_id

        db.session.commit()

        return product_schema.jsonify(product)


# define the API resources
product_registration = ProductRegistration.as_view("product_registration")
product_update = ProductUpdate.as_view("product_update")
product_get_all = ProductGetAll.as_view("product_get_all")
product_get_by_id = ProductGetById.as_view("product_get_by_id")
product_delete = ProductDelete.as_view("product_delete")

# add Rules for API Endpoints
pharmacy_blueprint.add_url_rule(
    "/product", view_func=product_registration, methods=["POST"]
)
pharmacy_blueprint.add_url_rule(
    "/product", view_func=product_get_all, methods=["GET"]
)
pharmacy_blueprint.add_url_rule(
    "/product/<id>", view_func=product_get_by_id, methods=["GET"]
)
pharmacy_blueprint.add_url_rule(
    "/product/<id>", view_func=product_update, methods=["PUT"]
)
pharmacy_blueprint.add_url_rule(
    "/product/<id>", view_func=product_delete, methods=["DELETE"]
)