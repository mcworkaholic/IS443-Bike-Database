from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.dialects.oracle import \
            BFILE, BLOB, CHAR, CLOB, DATE, \
            DOUBLE_PRECISION, FLOAT, INTERVAL, LONG, NCLOB, \
            NUMBER, NVARCHAR, NVARCHAR2, RAW, TIMESTAMP, VARCHAR, \
            VARCHAR2
from flask_login import UserMixin

db = SQLAlchemy()

class User(UserMixin, db.Model):
    __tablename__ = "customer"

    member_id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.VARCHAR(250), unique=True, nullable=False)
    password = db.Column(db.VARCHAR(200), nullable=False)
    fname = db.Column(db.VARCHAR(150), nullable=False)
    lname = db.Column(db.VARCHAR(150), nullable=False)
    phone = db.Column(db.VARCHAR(20), nullable=False)
    address = db.Column(db.VARCHAR(200), nullable=False)
    registration_date = db.Column(db.DATE(), nullable=False)
    unpaid_balance = db.Column(db.Integer, nullable=True)
    num_rentals = db.Column(db.Integer, nullable=True)

    

    def __repr__(self):
        return '<User %r>' % self.email

    def get_id(self):
           return (self.member_id)


class rental_bike(db.Model):
    __tablename__ = "rental_bike"

    rental_id = db.Column(db.Integer, primary_key=True)
    member_id = db.Column(db.Integer, nullable=False)
    rented_out = db.Column(db.DATE(), nullable=True)





