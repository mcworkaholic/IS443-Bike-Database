from flask import Flask
from flask_login import LoginManager
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
import cx_Oracle
from dotenv import load_dotenv
import os 


load_dotenv()

# set path to downloaded Oracle instant client here
cx_Oracle.init_oracle_client(lib_dir="C:\\Users\\Weston\\Desktop\\instantclient-basic-windows.x64-21.7.0.0.0dbru\\instantclient_21_7")


# setting credentials from .env
un = os.getenv('ADMIN')
pw = os.getenv('PASSWORD')
host = os.getenv('HOST')
port = os.getenv('PORT')
sid = os.getenv('SID')
sid = cx_Oracle.makedsn(host, port, sid=sid)

# setting Oracle connection string with above credentials
cstr = f'oracle://{un}:{pw}@{sid}'
          


login_manager = LoginManager()
login_manager.session_protection = "strong"
login_manager.login_view = "login"
login_manager.login_message_category = "info"

bcrypt = Bcrypt()
db = SQLAlchemy()


def create_app():
    app = Flask(__name__, static_folder=".\static")
    app.secret_key = os.getenv('SECRET_KEY')
    app.config['SQLALCHEMY_DATABASE_URI'] = cstr
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    
    login_manager.init_app(app)
    bcrypt.init_app(app)

    from .models import db
    db.init_app(app)

    from .views import views
    app.register_blueprint(views, url_prefix='/')
    
    
    with app.app_context():
        db.create_all()

    return app

