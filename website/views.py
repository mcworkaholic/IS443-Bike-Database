from flask import (
    Blueprint,
    render_template,
    redirect,
    request,
    flash,
    url_for,
    session,
)
import cx_Oracle
import os
from dotenv import load_dotenv
import datetime
import oracledb
from datetime import timedelta
from sqlalchemy.exc import (
    IntegrityError,
    DataError,
    DatabaseError,
    InterfaceError,
    InvalidRequestError,
)
from werkzeug.routing import BuildError


from flask_bcrypt import check_password_hash

from flask_login import (
    login_user,
    current_user,
    logout_user,
    login_required,
)

from . import db,login_manager,bcrypt
from .models import User
from .forms import login_form,register_form

views = Blueprint('views', __name__)

load_dotenv()

un = os.getenv('ADMIN')
pw = os.getenv('PASSWORD')
host = os.getenv('HOST')
port = os.getenv('PORT')
sid = os.getenv('SID')
sid = cx_Oracle.makedsn(host, port, sid=sid)
pool = oracledb.create_pool(user=un, password = pw, dsn=sid, min=2, max=5, increment=1)

def paymentAccepted():
    with pool.acquire() as connection:
        cursor = connection.cursor() 
        statement = """UPDATE customer SET customer.unpaid_balance = :1 WHERE customer.member_id = :2"""
        cursor.execute(statement, (0.00, current_user.member_id))
        connection.commit()
        return

def insertRental():
    with pool.acquire() as connection:
        cursor = connection.cursor() 
        statement = """INSERT INTO rental_bike (member_id, bike_id, rented_out) VALUES(:1, :2, :3)"""
        cursor.execute(statement, (current_user.member_id, ))
        connection.commit()
        return

@login_manager.user_loader
def load_user(member_id):
    return User.query.get(int(member_id))

@views.before_request
def session_handler():
    session.permanent = True
    views.permanent_session_lifetime = timedelta(minutes=1)

@views.route("/shop", methods=("GET", "POST"), strict_slashes=False)
@login_required
def shop():
    with pool.acquire() as connection:
        with connection.cursor() as cursor:
                q1 = """SELECT * FROM bike INNER JOIN category ON bike.category_id = category.category_id INNER JOIN manufacturer ON bike.manufacturer_id = manufacturer.manufacturer_id ORDER BY bike_id"""
                cursor.execute(q1)
                product_data = cursor.fetchall()
    return render_template("shop.html", data = product_data, user=current_user)


@views.route("/checkout/<int:id>", methods=("GET", "POST"), strict_slashes=False)
@login_required
def checkout(id:int):
    if request.method == "POST":
                member_id = current_user.member_id
                bike_id = request.url
                if request.form['submit_button'] == 'Return':
                    return_location = request.form.get("store")
                    return_date = request.form.get("returndate")
                    days = None
                elif request.form['submit_button'] == 'Checkout':
                    days = request.form.get("quantity")
                    with pool.acquire() as connection:
                        cursor = connection.cursor() 
                        insert_bike = """INSERT INTO rental_bike (member_id, bike_id, rented_out) VALUES(:1, :2, :3)"""
                        insert_detail = """"""
                        cursor.execute(insert_bike, (current_user.member_id, int(bike_id[-1])+1, datetime.datetime.now()))
                        connection.commit()
                    return_location = None
                    return_date = None
                if days != None:
                    return render_template("blank.html", p = "days: " + str(days) + " member_id: " + str(member_id) + " bike_id: " + str(int(bike_id[-1])+1))
                else:
                    return render_template("blank.html", p = "return_date: " + str(return_date) + " return_location: " + str(return_location)+ " member_id: " + str(member_id)+ " bike_id: "  + str(int(bike_id[-1])+1))


    elif request.method == "GET":
        q1 = """SELECT * FROM bike INNER JOIN category ON bike.category_id = category.category_id INNER JOIN manufacturer ON bike.manufacturer_id = manufacturer.manufacturer_id ORDER BY bike_id"""
        q2 = """SELECT location_id, city, state FROM location"""
        with pool.acquire() as connection:
            with connection.cursor() as cursor:
                    cursor.execute(q1)
                    product_data = cursor.fetchall()
                    cursor.execute(q2)
                    location_data = cursor.fetchall()
        return render_template("checkout.html", pdata = product_data[id], user=current_user, ldata=location_data)

    


@views.route("/login/", methods=("GET", "POST"), strict_slashes=False)
def login():
    form = login_form()

    if form.validate_on_submit():
        try:
            user = User.query.filter_by(email=form.email.data).first()
            if check_password_hash((user.password), form.password.data):
                login_user(user)
                return redirect(url_for('views.shop'))
            else:
                flash("Invalid Username or password!", "danger")
        except Exception as e:
            flash(e, "danger")

    return render_template("auth.html",
        form=form,
        text="Login",
        title="Login",
        btn_action="Login"
        )


# Register route
@views.route("/register/", methods=("GET", "POST"), strict_slashes=False)
def register():
    form = register_form()
    if form.validate_on_submit():
        try:
            fname = form.fname.data
            lname = form.lname.data
            email = form.email.data
            phone = form.phone.data
            address = form.address.data
            password = form.password.data
            
            
            newuser = User(
                email=email,
                fname=fname,
                lname=lname,
                phone=phone,
                address=address,
                unpaid_balance = 0,
                num_rentals = 0,
                registration_date = datetime.datetime.now(),
                password=bcrypt.generate_password_hash(password).decode('utf8'),
            )
    
            db.session.add(newuser)
            db.session.commit()
            flash("Account Successfully created", "success")
            return redirect(url_for("views.login"))

        except InvalidRequestError:
            db.session.rollback()
            flash(f"Something went wrong!", "danger")
        except IntegrityError:
            db.session.rollback()
            flash(f"User already exists!.", "warning")
        except DataError:
            db.session.rollback()
            flash(f"Invalid Entry", "warning")
        except InterfaceError:
            db.session.rollback()
            flash(f"Error connecting to the database", "danger")
        except DatabaseError:
            db.session.rollback()
            flash(f"Error connecting to the database", "danger")
        except BuildError:
            db.session.rollback()
            flash(f"An error occured !", "danger")
    return render_template("auth.html",
        form=form,
        text="Create account",
        title="Register",
        btn_action="Register account"
        )

@views.route("/logout")
@login_required
def logout():
    logout_user()
    return redirect(url_for('views.login'))



