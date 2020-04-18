from . import db
import sqlalchemy
from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship, backref
import uuid

class pharmacists(db.Model):
    """Model for pharmaLive users ."""

    __tablename__ = 'pharmacists'
    id = db.Column(db.Integer,
                   primary_key=True)
    username = db.Column(db.String(64),
                         index=False,
                         unique=True,
                         nullable=False)
    email = db.Column(db.String(80),
                      index=True,
                      unique=True,
                      nullable=False)
    password = db.Column(db.String,
                        index=False,
                        unique=True,
                        nullable=False)
    adress = db.relationship('pharmacies', backref=backref('pharmacists',uselist = false))
    product = db.relationship('products', backref=backref('pharmacists',uselist = false))

    def __init__(self, username, email, password):
        self.id = uuid.uuid4().hex
        self.username = username
        self.email = email
        self.password = password

    def __repr__(self):
        return '<User {}>'.format(self.username)

class pharmacies(db.Model):
    """Model for pharmaLive pharmacies ."""

    __tablename__ = 'pharmacies'
    id = db.Column(db.Integer,
                   primary_key=True)
    pharmacy_name = db.Column(db.String(64),
                         index=false,
                         unique=false,
                         nullable=true)
    address = db.Column(db.String(64),
                         index=true,
                         unique=True,
                         nullable=False)
    phone_number = db.Column(db.Integer,
                      index=false,
                      unique=True,
                      nullable=true)
    longitude = db.Column(db.Integer,
                      index=false,
                      unique=True,
                      nullable=False)
    latitude = db.Column(db.Integer,
                        index=False,
                        unique=true,
                        nullable=False)
    pharmacist_id = db.Column(db.String,
                    db.ForeignKey('pharmacists.username'),
                    nullable=false)
    pharmacist = relationship("pharmacists", backref="pharmacies")

    def __init__(self,pharmacy_name, address ,phone_number, longitude, latitude,pharmacist_id,available):
        self.id = uuid.uuid4().hex
        self.pharmacy_name = pharmacy_name
        self.address = address
        self.phone_number = phone_number
        self.longitude = longitude
        self.latitude = latitude
        self.pharmacist_id = pharmacist_id
        self.available = available

    def __repr__(self):
        return '<pharmacies {}>'.format(self.pharmacist_id, self.address, self.available)

class products(db.Model):
    """Model for pharmaLive products ."""

    __tablename__ = 'products'
    id = db.Column(db.Integer,
                   primary_key=True)
    product_name = db.Column(db.String(64),
                         index=false,
                         unique=false,
                         nullable=False)
    quantity = db.Column(db.Integer,
                      index=false,
                      unique=false,
                      nullable=true)
    last_update = db.Column(db.DateTime,
                        index=true,
                        unique=False,
                        nullable=False)
    pharmacist_id = db.Column(db.String,
                    db.ForeignKey('pharmacists.username'),
                    nullable=false)
    pharmacist = relationship("pharmacists", backref="products")                    

    def __init__(self,pharmacist_id , product_name, quantity,last_update):
        self.id = uuid.uuid4().hex
        self.pharmacist_id = pharmacist_id
        self.product_name = product_name
        self.quantity = quantity
        self.last_update = last_update

    def __repr__(self):
        return '<produits {}>'.format(self.pharmacist_id,self.produit_name, self.stock)
