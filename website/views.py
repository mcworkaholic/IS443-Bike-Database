import datetime
import os
from datetime import timedelta

import cx_Oracle
import oracledb
from dotenv import load_dotenv
from flask import (Blueprint, flash, redirect, render_template, request,
                   session, url_for)
from flask_bcrypt import check_password_hash
from flask_login import current_user, login_required, login_user, logout_user
from oracledb import exceptions
from sqlalchemy.exc import (DatabaseError, DataError, IntegrityError,
                            InterfaceError, InvalidRequestError)
from werkzeug.routing import BuildError

from . import bcrypt, db, login_manager
from .forms import login_form, register_form
from .models import User

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
    with pool.acquire() as connection:
        with connection.cursor() as cursor:
            customer_data = cursor.execute("""SELECT num_rentals, unpaid_balance FROM customer WHERE customer.member_id=:member_id""", member_id = current_user.member_id).fetchall()
    if request.method == "POST":
                months = { '1': 'JAN', '2': 'FEB', '3': 'MAR', '4': 'APR', '5': 'MAY', '6': 'JUN', '7': 'JUL','8': 'AUG','9': 'SEP','10': 'OCT','11': 'NOV', '12': 'DEC' }
                member_id = current_user.member_id
                bike_id = request.url
                if request.form['submit_button'] == 'Return':
                    return_location = request.form.get("store") # from select field
                    date_str = request.form.get("returndate") # As DD-MM-YY format
                    split_date = date_str.split('-')
                    new_date_str = [split_date[0], months[f"{split_date[1]}"], split_date[2]]
                    date_object = datetime.datetime.strptime('-'.join(new_date_str), '%d-%b-%y').date()
                    days = None
                    with pool.acquire() as connection:
                        cursor = connection.cursor()
                        update_cust_rentals = """UPDATE customer SET customer.num_rentals = ((SELECT num_rentals FROM customer WHERE customer.member_id =:1) -1)"""
                        update_bike_status = """UPDATE bike SET bike.status = 'in' WHERE bike.bike_id = :1"""
                        update_bike_location = """UPDATE bike SET bike.location_id = :1 WHERE bike.bike_id = :2"""
                        update_balance = """UPDATE customer SET unpaid_balance = (SELECT unpaid_balance FROM customer WHERE customer.member_id = :1) +""" #work on
                        cursor.execute(update_bike_location, [return_location, int(bike_id[-1])+1])
                        cursor.execute(update_cust_rentals, [current_user.member_id])
                        cursor.execute(update_bike_status, [int(bike_id[-1])+1])
                        connection.commit()
                elif request.form['submit_button'] == 'Checkout':
                    days = request.form.get("quantity")
                    with pool.acquire() as connection:
                        cursor = connection.cursor() 
                        select_data = cursor.execute("""SELECT daily_fee FROM bike WHERE bike_id = :bike""",bike=int(bike_id[-1])+1)
                        daily_fee = select_data.fetchall()
                        # exp_return = """SELECT rented_out + :1 FROM rental_bike WHERE rental_bike.member_id = :2 AND rental_bike.bike_id = :3 AND TRUNC(rented_out) = TO_DATE('14-NOV-22', 'dd-MON-yy')""" #work on
                        insert_rental = """INSERT INTO rental_bike (member_id, bike_id, rented_out) VALUES(:1, :2, :3)"""
                        insert_rental_detail = """INSERT INTO rental_detail (rental_id, exp_return, location_from) VALUES(:1, :2, :3)"""
                        update_balance = """UPDATE customer SET customer.unpaid_balance = (SELECT unpaid_balance FROM customer WHERE customer.member_id = :1) + (:2 * :3) WHERE customer.member_id = :4"""
                        try:
                            cursor.execute(update_balance, [current_user.member_id, (daily_fee[0][0]),  days, current_user.member_id])
                            cursor.execute(insert_rental, [current_user.member_id, int(bike_id[-1])+1, datetime.datetime.now()])
                            connection.commit()
                        except oracledb.IntegrityError:
                            db.session.rollback()
                            if customer_data[0][0] == 2:
                                flash(f"Maximum number of rentals reached.", "warning")
                                return redirect(url_for('views.checkout', id=int(bike_id[-1])))
                            elif  customer_data[0][0] !=2:
                                flash(f"Maximum account balance reached.", "warning")
                                return redirect(url_for('views.checkout', id=int(bike_id[-1])))
                       
                if days != None:
                    return render_template("blank.html", p = "num_rentals: " + str(customer_data) + "daily_fee: " + str(daily_fee[0][0]) + "days: " + str(days) + " member_id: " + str(member_id) + " bike_id: " + str(int(bike_id[-1])+1))
                else:
                    return render_template("blank.html", p = "return_date: " + str(date_str) + " return_location: " + str(return_location)+ " member_id: " + str(member_id)+ " bike_id: "  + str(int(bike_id[-1])+1))


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
            flash("Account Creation Successful.", "success")
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



