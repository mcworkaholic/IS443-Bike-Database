from flask import (
    Flask,
    Blueprint,
    render_template,
    redirect,
    flash,
    url_for,
    session,
)
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


from flask_bcrypt import Bcrypt,generate_password_hash, check_password_hash

from flask_login import (
    UserMixin,
    login_user,
    LoginManager,
    current_user,
    logout_user,
    login_required,
)

from . import db,login_manager,bcrypt
from .models import User
from .forms import login_form,register_form

views = Blueprint('views', __name__)


    

@login_manager.user_loader
def load_user(member_id):
    return User.query.get(int(member_id))

@views.before_request
def session_handler():
    session.permanent = True
    views.permanent_session_lifetime = timedelta(minutes=1)


@views.route("/login/", methods=("GET", "POST"), strict_slashes=False)
def login():
    form = login_form()

    if form.validate_on_submit():
        try:
            user = User.query.filter_by(email=form.email.data).first()
            if check_password_hash((user.password), form.password.data):
                login_user(user)
                return redirect(url_for('views.dashboard'))
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


