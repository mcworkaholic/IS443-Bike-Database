from flask_login import current_user
import cx_Oracle
import oracledb
import pandas as pd
import datetime
from dotenv import load_dotenv
import os 

cx_Oracle.init_oracle_client(lib_dir="C:\\Users\\Weston\\Desktop\\instantclient-basic-windows.x64-21.7.0.0.0dbru\\instantclient_21_7")
pd.set_option('display.width', 1000)
pd.options.display.max_columns = None
pd.options.display.max_rows = None

load_dotenv()
un = os.getenv('ADMIN')
pw = os.getenv('PASSWORD')
host = os.getenv('HOST')
port = os.getenv('PORT')
sid = os.getenv('SID')
sid = cx_Oracle.makedsn(host, port, sid=sid)

pool = cx_Oracle.SessionPool(user=un, password=pw, dsn=sid, min=2, max=8, increment=1, encoding="UTF-8")

def select_products_detail():
    with pool.acquire() as connection:
        cursor = connection.cursor() 
        sql = """SELECT * FROM bike INNER JOIN category ON bike.category_id = category.category_id INNER JOIN manufacturer ON bike.manufacturer_id = manufacturer.manufacturer_id ORDER BY bike_id"""
        for result in cursor.execute(sql):
            result = cursor.fetchall()
            return result

def select_location_detail():
    with pool.acquire() as connection:
        cursor = connection.cursor() 
        sql = """SELECT location_id, city, state FROM location"""
        for result in cursor.execute(sql):
            result = cursor.fetchall()
            return result

def getDate():
    date_str = '09-19-2018'

    date_object = datetime.datetime.strptime(date_str, '%m-%d-%Y').date
    print(type(date_object))
    print(date_object)  # printed in default formatting

def paymentAccepted():
    with pool.acquire() as connection:
        cursor = connection.cursor() 
        statement = """UPDATE customer SET customer.unpaid_balance = :1 WHERE customer.member_id = :2"""
        cursor.execute(statement, (0.00, 1))
        return
def insertDetail():
    with pool.acquire() as connection:
        cursor = connection.cursor() 
        statement = """INSERT INTO rental_detail (rental_id, exp_return, location_from) VALUES(:1, :2, :3)"""
        cursor.execute(statement, (1, ))
        return

print(select_location_detail())
print(select_products_detail()) 
print(paymentAccepted()) 