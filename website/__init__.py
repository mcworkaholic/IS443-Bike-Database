from flask import Flask
from sqlalchemy import create_engine
import pandas as pd
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
import cx_Oracle



cx_Oracle.init_oracle_client(lib_dir="C:\\Users\\Weston\\Desktop\\instantclient-basic-windows.x64-21.7.0.0.0dbru\\instantclient_21_7")
pd.set_option('display.width', 1000)
pd.options.display.max_columns = None
pd.options.display.max_rows = None

# move to .env before pushing
un = 'admin_WE'
pw = '$GoldenTeacher$'
host = 'westonevansdb.cgrdod7jxvma.us-east-1.rds.amazonaws.com'
port = '1521'
sid = 'ORCL'
sid = cx_Oracle.makedsn(host, port, sid=sid)

cstr = f'oracle://{un}:{pw}@{sid}'



# def query():
#     with oracledb.connect(user=un, password=pw, dsn=sid) as connection:
#         with connection.cursor() as cursor:
#             sql = """select * from manufacturer"""
#             for r in cursor.execute(sql):
#                 print(r)
                
                

from flask_login import (
    UserMixin,
    login_user,
    LoginManager,
    current_user,
    logout_user,
    login_required,
)

login_manager = LoginManager()
login_manager.session_protection = "strong"
login_manager.login_view = "login"
login_manager.login_message_category = "info"

bcrypt = Bcrypt()
db = SQLAlchemy()




def create_app():
    app = Flask(__name__, static_folder=".\static")
    app.secret_key = 'secret-key'
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

