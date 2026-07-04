import kagglehub

import pyodbc
from kagglehub import KaggleDatasetAdapter
import pandas as pd
from sqlalchemy import create_engine
DATASET = "kaisersafdf/messy-e-ccomerce-dataset"
SERVER = "jtaservidor2.database.windows.net"
DATABASE = "NewOutletdb_production"
USERNAME = "CloudSAfbe8fbdc"
PASSWORD =  "NewOutletdb_Pass7362738"  


SQL_COPT_SS_ACCESS_TOKEN = 1256
TOKEN_URL = "https://database.windows.net/"

def extract_data() -> pd.DataFrame:
    print(f"Downloading dataset: {DATASET}")
    df = kagglehub.dataset_load(
        KaggleDatasetAdapter.PANDAS,
        handle=DATASET,
        path="messy_ecommerce_operations.csv"
    )
    print(f"  Loaded: {df.shape[0]:,} rows, {df.shape[1]} columns")
    return df



def load_to_sql(df: pd.DataFrame):
    print("Connecting to Azure SQL...")
    
    connection_string = (
        f"DRIVER={{ODBC Driver 18 for SQL Server}};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"UID={USERNAME};"
        f"PWD={PASSWORD};"
        f"TrustServerCertificate=yes;"
        f"Encrypt=yes;"
    )

    engine = create_engine(
        "mssql+pyodbc://",
        creator=lambda: pyodbc.connect(connection_string)
    )

    print("Engine created, loading data...")
    df.to_sql("ecommerce_raw", engine, if_exists="replace", index=False)
    print("  Done. Table 'ecommerce_raw' loaded into Azure SQL.")
    
if __name__ == "__main__":
    df = extract_data()
    load_to_sql(df)
