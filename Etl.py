import io
import os
import uuid
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient, ContainerClient, BlobBlock, BlobClient, StandardBlobTier
import kagglehub
from kagglehub import KaggleDatasetAdapter
import pandas as pd


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
             

   



if __name__ == "__main__":
    tables = extract_data()
    load_to_blob(tables)

    """tables = extract_data()
    print(tables["data"].head())"""