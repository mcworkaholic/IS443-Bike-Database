from wtforms import (
    StringField,
    PasswordField,
    BooleanField,
    IntegerField,
    DateField,
    TextAreaField,
)

from flask_wtf import FlaskForm
from wtforms.validators import Length, EqualTo, Email, Regexp ,Optional
import email_validator
from flask_login import current_user
from wtforms import ValidationError,validators
from .models import User


class login_form(FlaskForm):
    email = StringField(validators=[ Email(), Length(1, 64)])
    password = PasswordField(validators=[ Length(min=8, max=72)])
    # Placeholder labels to enable form rendering


class register_form(FlaskForm):
    email = StringField(validators=[Email(), Length(1, 64)])
    fname = StringField(validators=[ Length(1, 50)])
    lname = StringField(validators=[ Length(1, 50)])
    phone = StringField(validators=[ Length(8, 20)])
    address = StringField(validators=[ Length(1, 150)])
    password = PasswordField(validators=[ Length(8, 200)])
    cpwd = PasswordField(
        validators=[
            Length(8, 72),
            EqualTo("password", message="Passwords must match !"),
        ]
    )


    def validate_email(self, email):
        if User.query.filter_by(email=email.data).first():
            raise ValidationError("Email already registered!")

    