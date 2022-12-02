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
                if request.form['submit_button'] == 'Return': # return button
                    return_location = request.form.get("store") # from select field
                    return_date = request.form.get("returndate") # As DD-MM-YYYY format
                    split_date = return_date.split('-')
                    new_date_str = [split_date[0], months[f"{split_date[1]}"], split_date[2]]
                    oracle_date = '-'.join(new_date_str)
                    days = None
                    with pool.acquire() as connection:
                        cursor = connection.cursor()
                        update_cust_rentals = """UPDATE customer SET customer.num_rentals = (SELECT num_rentals -1 FROM customer WHERE customer.member_id =:1)""" 
                        update_bike_status = """UPDATE bike SET bike.status = 'in' WHERE bike.bike_id = :1""" 
                        update_bike_location = """UPDATE bike SET bike.location_id = :1 WHERE bike.bike_id = :2""" 
                        update_act_return = """UPDATE rental_detail SET act_return =:1 WHERE rental_id = (SELECT rental_id FROM rental_bike WHERE bike_id = :2 AND member_ID = :3 AND rental_status = 'incomplete')"""
                        update_location_return = """UPDATE rental_detail SET location_return = :1 WHERE rental_id = (SELECT rental_id FROM rental_bike WHERE bike_id = :2 AND member_id = :3 AND rental_status = 'incomplete')"""
                        update_balance = """UPDATE customer SET unpaid_balance = (SELECT unpaid_balance FROM customer WHERE customer.member_id = :1) + (SELECT late_fee from rental_detail WHERE rental_id = (SELECT rental_id FROM rental_bike WHERE bike_id = :2 AND member_id = :3 AND rental_status = 'incomplete'))""" 
                        update_rental_status = """UPDATE rental_bike SET rental_status = 'complete' WHERE rental_id = (SELECT rental_id FROM rental_bike WHERE bike_id = :1 AND member_id = :2 AND rental_status = 'incomplete')"""
                        cursor.execute("ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS'") 
                        cursor.execute(update_act_return, [oracle_date, int(bike_id[-1])+1, current_user.member_id]) 
                        cursor.execute(update_location_return,[return_location, int(bike_id[-1])+1, current_user.member_id])
                        cursor.execute(update_bike_location, [return_location, int(bike_id[-1])+1]) 
                        cursor.execute(update_cust_rentals, [current_user.member_id]) 
                        cursor.execute(update_balance, [current_user.member_id, int(bike_id[-1])+1, current_user.member_id]) 
                        cursor.execute(update_bike_status, [int(bike_id[-1])+1]) 
                        cursor.execute(update_rental_status, [int(bike_id[-1])+1, current_user.member_id])
                        connection.commit()
                elif request.form['submit_button'] == 'Checkout':
                    days = request.form.get("quantity") # days 
                    with pool.acquire() as connection:
                        cursor = connection.cursor() 
                        cursor.execute("ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS'")
                        insert_rental = """INSERT INTO rental_bike (member_id, bike_id, rented_out, days_out, rental_status) VALUES(:1, :2, :3, :4, :5)"""
                        add_rental = """UPDATE customer set num_rentals = (SELECT num_rentals + 1 FROM customer WHERE member_id =:1)"""
                        try:
                            cursor.execute(add_rental, [current_user.member_id])
                            cursor.execute(insert_rental, [current_user.member_id, int(bike_id[-1])+1, datetime.datetime.now(), days, 'incomplete'])
                            connection.commit()
                        except oracledb.IntegrityError:
                            db.session.rollback()
                            flash(f"Maximum number of rentals reached.", "warning")
                            return redirect(url_for('views.checkout', id=int(bike_id[-1])))
                        except oracledb.DatabaseError as e:
                            error_obj, = e.args  
                            flash("Maximum account balance reached.", "warning")
                            db.session.rollback()
                            return redirect(url_for('views.checkout', id=int(bike_id[-1])))
                if days != None:
                    return redirect(url_for('views.shop'))
                    # return render_template("blank.html", p = " num_rentals: " + str(customer_data[0][0])  + " days: " + str(days) + " member_id: " + str(member_id) + " bike_id: " + str(int(bike_id[-1])+1))
                
                else:
                    return redirect(url_for('views.shop'))
                    # return render_template("blank.html", p =  str(customer_data[0])+ "  " +  "return_date: " + str(oracle_date) + " return_location: " + str(return_location)+ " member_id: " + str(member_id)+ " bike_id: "  + str(int(bike_id[-1])+1))
    elif request.method == "GET":
        q1 = """SELECT * FROM bike INNER JOIN category ON bike.category_id = category.category_id INNER JOIN manufacturer ON bike.manufacturer_id = manufacturer.manufacturer_id ORDER BY bike_id"""
        q2 = """SELECT location_id, city, state FROM location"""
        with pool.acquire() as connection:
            with connection.cursor() as cursor:
                    cursor.execute(q1)
                    product_data = cursor.fetchall()
                    cursor.execute(q2)
                    location_data = cursor.fetchall()
        return render_template("checkout.html", pdata = product_data[id], isCheckout=True, user=current_user, ldata=location_data)

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
            flash("User not found.", "danger")
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
            flash(f"User already exists!", "warning")
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

@views.route("/account", methods=("GET", "POST"), strict_slashes=False)
@login_required
def account():
    if request.method == "POST":
        update_account = """UPDATE customer SET unpaid_balance = 0 WHERE member_id=:1"""
        if request.form['submit_button'] == 'Balance':
            with pool.acquire() as connection:
                with connection.cursor() as cursor:
                    cursor.execute(update_account, [current_user.member_id])
    return render_template('account.html', isAccount=True)

@views.route('/api/data/user', methods=("GET", "POST"))
@login_required
def userData():
    if request.method == "GET":
     with pool.acquire() as connection:
        with connection.cursor() as cursor:
            customer_data = cursor.execute("""SELECT * FROM customer WHERE customer.member_id=:member_id""", member_id = current_user.member_id).fetchall()

    # response
    return {
        'data': customer_data,
        'total': 1,
    }



