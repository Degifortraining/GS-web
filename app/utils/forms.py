from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField, IntegerField, SelectField, SubmitField
from wtforms.validators import DataRequired, Email, Length, Optional, NumberRange

class QuoteRequestForm(FlaskForm):
    name = StringField("Name", validators=[DataRequired(), Length(max=120)])
    email = StringField("Email", validators=[DataRequired(), Email(), Length(max=180)])
    phone = StringField("Phone (optional)", validators=[Optional(), Length(max=50)])
    item = StringField("Item / Product / Service", validators=[DataRequired(), Length(max=200)])
    quantity = IntegerField("Quantity (optional)", validators=[Optional(), NumberRange(min=1)])
    message = TextAreaField("Message", validators=[DataRequired(), Length(max=3000)])
    submit = SubmitField("Submit Quote Request")

class ContactForm(FlaskForm):
    name = StringField("Name", validators=[DataRequired(), Length(max=120)])
    email = StringField("Email", validators=[DataRequired(), Email(), Length(max=180)])
    subject = StringField("Subject", validators=[DataRequired(), Length(max=200)])
    message = TextAreaField("Message", validators=[DataRequired(), Length(max=3000)])
    submit = SubmitField("Send Message")

class TrainingRegistrationForm(FlaskForm):
    name = StringField("Name", validators=[DataRequired(), Length(max=120)])
    email = StringField("Email", validators=[DataRequired(), Email(), Length(max=180)])
    course = SelectField("Course", choices=[
        ("Safety Basics", "Safety Basics"),
        ("Tool Handling", "Tool Handling"),
        ("Procurement 101", "Procurement 101"),
        ("Industrial Training", "Industrial Training"),
    ], validators=[DataRequired()])
    phone = StringField("Phone (optional)", validators=[Optional(), Length(max=50)])
    notes = TextAreaField("Notes (optional)", validators=[Optional(), Length(max=3000)])
    submit = SubmitField("Register")
