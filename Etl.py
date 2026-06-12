import kagglehub
from kagglehub import KaggleDatasetAdapter
import pandas as pd
import struct
from azure.identity import DefaultAzureCredential
from sqlalchemy import create_engine, event
DATASET = "kaisersafdf/messy-e-ccomerce-dataset"
SERVER = "jtaservidor2.database.windows.net"
DATABASE = "NewOutletdb_development"

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
    credential = DefaultAzureCredential()
    connection_string = (
        f"mssql+pyodbc://@{SERVER}/{DATABASE}"
        f"?driver=ODBC+Driver+18+for+SQL+Server"
    )
    engine = create_engine(connection_string)

    @event.listens_for(engine, "do_connect")
    def provide_token(dialect, conn_rec, cargs, cparams):
        cargs[0] = cargs[0].replace(";Trusted_Connection=Yes", "")
        raw_token = credential.get_token(TOKEN_URL).token.encode("utf-16-le")
        token_struct = struct.pack(f"<I{len(raw_token)}s", len(raw_token), raw_token)
        cparams["attrs_before"] = {SQL_COPT_SS_ACCESS_TOKEN: token_struct}

    df.to_sql("ecommerce_raw", engine, if_exists="replace", index=False)
    print("  Done. Table 'ecommerce_raw' loaded into Azure SQL.")

if __name__ == "__main__":
    df = extract_data()
    load_to_sql(df)