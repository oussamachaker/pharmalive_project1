import os

basedir = os.path.abspath(os.path.dirname(__file__))
sqlite_local_base = "sqlite:///"
database_name = os.path.join(basedir, 'sqlite.db')



class BaseConfig:
    """Base configuration."""
    SECRET_KEY = os.getenv('SECRET_KEY', 'my_precious') #SECRET_KEY has to be generated with os.urandom(24) then exported : environment variable 
    DEBUG = False
    BCRYPT_LOG_ROUNDS = 13
    SQLALCHEMY_TRACK_MODIFICATIONS = False

class DevelopmentConfig(BaseConfig):
    """Development configuration."""
    DEBUG = True
    BCRYPT_LOG_ROUNDS = 4
    SQLALCHEMY_DATABASE_URI = sqlite_local_base + database_name
