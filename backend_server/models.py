import datetime
import jwt
import uuid

from sqlalchemy.orm import relationship, backref
from backend_server import app, db, bcrypt


class User(db.Model):
    """ User Model for storing user related details """

    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(255), index=False, unique=True, nullable=False)
    email = db.Column(db.String(255), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    registered_on = db.Column(db.DateTime, nullable=False)
    admin = db.Column(db.Boolean, nullable=False, default=False)

    adress = db.relationship("pharmacies", backref=backref("users", uselist=False))
    product = db.relationship("products", backref=backref("users", uselist=False))

    def __init__(self, username, email, password, admin=False):
        self.id = uuid.uuid4().hex
        self.email = email
        self.username = username
        self.password = bcrypt.generate_password_hash(
            password, app.config.get("BCRYPT_LOG_ROUNDS")
        ).decode()
        self.registered_on = datetime.datetime.now()
        self.admin = admin

    def __repr__(self):
        return "<User {}>".format(self.username)

    def encode_auth_token(self, user_id):
        """ Generates the Auth Token: return string """
        try:
            payload = {
                "exp": datetime.datetime.utcnow()
                + datetime.timedelta(days=0, seconds=5),  # expiration date of the token
                "iat": datetime.datetime.utcnow(),  # the time token is generated
                "sub": user_id,  # subject of the token (user identified)
            }
            return jwt.encode(payload, app.config.get("SECRET_KEY"), algorithm="HS256")
        except Exception as e:
            return e

    @staticmethod
    def decode_auth_token(auth_token):
        """
        Decodes the auth token
        :param auth_token:
        :return: integer|string
        """
        try:
            payload = jwt.decode(auth_token, app.config.get("SECRET_KEY"))
            is_blacklisted_token = BlacklistToken.check_blacklist(auth_token)
            if is_blacklisted_token:
                return "Token blacklisted. Please log in again"
            else:
                return payload["sub"]
        except jwt.ExpiredSignatureError:
            return "Signature expired. Please log in again."
        except jwt.InvalidTokenError:
            return "Invalid token. Please log in again."


class BlacklistToken(db.Model):
    """
    Token Model for storing JWT tokens
    """

    __tablename__ = "blacklist_tokens"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    token = db.Column(db.String(500), unique=True, nullable=False)
    blacklisted_on = db.Column(db.DateTime, nullable=False)

    def __init__(self, token):
        self.token = token
        self.blacklisted_on = datetime.datetime.now()

    def __repr__(self):
        return "<id: token: {}".format(self.token)

    @staticmethod
    def check_blacklist(auth_token):
        # check whether auth token has been blacklisted
        res = BlacklistToken.query.filter_by(token=str(auth_token)).first()
        if res:
            return True
        else:
            return False


class pharmacies(db.Model):
    """Model for pharmaLive pharmacies ."""

    __tablename__ = "pharmacies"
    id = db.Column(db.Integer, primary_key=True)
    pharmacy_name = db.Column(db.String(64), index=False, unique=False, nullable=True)
    address = db.Column(db.String(64), index=True, unique=True, nullable=False)
    phone_number = db.Column(db.Integer, index=False, unique=True, nullable=True)
    longitude = db.Column(db.Integer, index=False, unique=True, nullable=False)
    latitude = db.Column(db.Integer, index=False, unique=True, nullable=False)
    pharmacist_id = db.Column(db.String, db.ForeignKey("users.id"), nullable=False)
    # User = relationship("User", backref="pharmacies")

    def __init__(
        self,
        pharmacy_name,
        address,
        phone_number,
        longitude,
        latitude,
        pharmacist_id,
        available,
    ):
        self.id = uuid.uuid4().hex
        self.pharmacy_name = pharmacy_name
        self.address = address
        self.phone_number = phone_number
        self.longitude = longitude
        self.latitude = latitude
        self.pharmacist_id = pharmacist_id
        self.available = available

    def __repr__(self):
        return "<pharmacies {}\n{}\n{}>".format(
            self.pharmacist_id, self.address, self.available
        )


class products(db.Model):
    """Model for pharmaLive products ."""

    __tablename__ = "products"
    id = db.Column(db.Integer, primary_key=True)
    product_name = db.Column(db.String(64), index=False, unique=False, nullable=False)
    quantity = db.Column(db.Integer, index=False, unique=False, nullable=True)
    last_update = db.Column(db.DateTime, index=True, unique=False, nullable=False)
    pharmacist_id = db.Column(
        db.String, db.ForeignKey("users.id"), nullable=False  # Users.username
    )
    # User = relationship("User", backref="products")

    def __init__(self, pharmacist_id, product_name, quantity, last_update):
        self.id = uuid.uuid4().hex
        self.pharmacist_id = pharmacist_id
        self.product_name = product_name
        self.quantity = quantity
        self.last_update = last_update

    def __repr__(self):
        return "<produits {}\n{}\n{}>".format(
            self.pharmacist_id, self.produit_name, self.stock
        )

