import pyodbc
import pandas as pd
server = "esba-pbi01d.ekon.es"
db= "CorporateDESA"
user = 'vpablo'
passw = '8ZkCMGtNv!yC'
host = 'esba-pbi01d.ekon.es'
port = 1433
db = 'CorporateDESA'
import sqlalchemy
from sqlalchemy import create_engine
print(pyodbc.drivers())
engine = create_engine('mssql+pyodbc://'+user+':'+passw+'@'+host+':'+str(port)+'/'+db+'?driver=ODBC Driver 17 for SQL Server',echo=True)
conn = engine.connect()
print(pd.read_sql_query("SELECT * FROM [CorporateDESA].[dbo].[GP_clients]", conn).head(5))



