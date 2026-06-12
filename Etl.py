import io
import os
import uuid
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient, ContainerClient, BlobBlock, BlobClient, StandardBlobTier
import kagglehub
from kagglehub import KaggleDatasetAdapter
import pandas as pd
import struct
from sqlalchemy import create_engine

DATASET = "kaisersafdf/messy-e-ccomerce-dataset"
account_url = "https://<jtaawstorage>.blob.core.windows.net"
credential = DefaultAzureCredential()
blob_service_client = BlobServiceClient(account_url=account_url,credential=credential)
container_name = "mycontainer"

def extract_data() -> dict[str, pd.DataFrame]:
    print(f"Downloading dataset: {DATASET}")
    df = kagglehub.dataset_load(
        KaggleDatasetAdapter.PANDAS,
        handle=DATASET,
        path="messy_ecommerce_operations.csv"   # filename inside the dataset
    )
    print(f"  Loaded: {df.shape[0]:,} rows, {df.shape[1]} columns")
    return {"data": df}

def load_to_blob(tables:dict[str,pd.DataFrame]):
        """Uploads each DataFrame as a JSON blob to Azure Blob Storage."""
        account_url = "https://jtaawstorage.blob.core.windows.net"
        credential = DefaultAzureCredential()
        blob_service_client = BlobServiceClient(account_url=account_url,credential=credential)
        container_name = "mycontainer"

        
        
        for table_name, df in tables.items():
             blob_name = f"raw/{table_name}.json"
             json_string = df.to_json(orient="records", indent=2, force_ascii=False)
             blob_client  = blob_service_client.get_blob_client(
                container= container_name ,blob=blob_name)
        
             blob_client .upload_blob(json_string, overwrite=True)
             print(f"  Uploaded: {blob_name}")
             

def read_blob() -> pd.DataFrame:
     account_url = "https://jtaawstorage.blob.core.windows.net"
     credential = DefaultAzureCredential()
     blob_service_client = BlobServiceClient(account_url=account_url,credential=credential)
     
     
     blob_client  = blob_service_client.get_blob_client(
                container= "mycontainer" ,blob=f"raw/data.json")
     json_string = blob_client.download_blob().readall().decode("utf-8")
     df = pd.read_json(json_string,orient="records")
     print(f"  Read from blob: {df.shape[0]:,} rows, {df.shape[1]} columns")
     return df

def load_to_sql(df: pd.DataFrame):
    """Loads DataFrame into Azure SQL as a raw table."""
    credential = DefaultAzureCredential()
    token = credential.get_token("https://database.windows.net/.default")
    token_bytes = token.token.encode("utf-16-le")
    token_struct = struct.pack(f"<I{len(token_bytes)}s", len(token_bytes), token_bytes)


    server_name = "jtaservidor2.database.windows.net"
    db_name = "NewOutletdb_development"
    connection_string = (
        f"mssql+pyodbc://@{server_name}/{db_name}"
        f"?driver=ODBC+Driver+18+for+SQL+Server"
    )
    engine = create_engine(
        connection_string,
        connect_args={"attrs_before": {1256: token_struct}}
    )

    df.to_sql("ecommerce_raw", engine, if_exists="replace", index=False)
    print("  Loaded into Azure SQL: table 'ecommerce_raw'")

if __name__ == "__main__":
    df = read_blob()
    load_to_sql(df)


    """tables = extract_data()
    print(tables["data"].head())"""