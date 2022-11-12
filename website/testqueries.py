import cx_Oracle
import oracledb
import pandas as pd
from datetime import datetime
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



def select_avail_products():
    with oracledb.connect(user=un, password=pw, dsn=sid) as connection:
        with connection.cursor() as cursor:
            sql = """SELECT * FROM bike INNER JOIN category ON bike.category_id = category.category_id INNER JOIN manufacturer ON bike.manufacturer_id = manufacturer.manufacturer_id ORDER BY bike_id"""
            cursor.execute(sql)
            product_data = cursor.fetchall()
            return product_data

def select_location_addresses():
    with oracledb.connect(user=un, password=pw, dsn=sid) as connection:
        with connection.cursor() as cursor:
            sql = """SELECT location_id, city, state FROM location"""
            cursor.execute(sql)
            location_data = cursor.fetchall()
            return location_data

def getDate():
    date_str = '09-19-2018'

    date_object = datetime.strptime(date_str, '%m-%d-%Y').date()
    print(type(date_object))
    print(date_object)  # printed in default formatting

print(select_avail_products())
