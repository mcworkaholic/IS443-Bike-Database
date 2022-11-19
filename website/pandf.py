from dotenv import load_dotenv
import os 
import cx_Oracle
import oracledb
import pandas as pd

load_dotenv()

un = os.getenv('ADMIN')
pw = os.getenv('PASSWORD')
host = os.getenv('HOST')
port = os.getenv('PORT')
sid = os.getenv('SID')
sid = cx_Oracle.makedsn(host, port, sid=sid)
connection = oracledb.connect(user=un, password = pw, dsn=sid)

def read_query(connection, query):
    cursor = connection.cursor()
    try:
        cursor.execute( query )
        names = [ x[0] for x in cursor.description]
        rows = cursor.fetchall()
        return pd.DataFrame( rows, columns=names).to_html()
    finally:
        if cursor is not None:
            cursor.close()


print(read_query(connection, """SELECT Fname AS firstName, Lname AS LastName, email, address, phone, num_rentals AS Rentals, unpaid_balance AS balance FROM customer WHERE member_id =1""" ))

