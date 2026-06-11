import kagglehub
from kagglehub import KaggleDatasetAdapter
import pandas as pd
DATASET = "kaisersafdf/messy-e-ccomerce-dataset"

def extract_data() -> dict[str, pd.DataFrame]:
    print(f"Downloading dataset: {DATASET}")
    df = kagglehub.dataset_load(
        KaggleDatasetAdapter.PANDAS,
        handle=DATASET,
        path="messy_ecommerce_operations.csv"   # filename inside the dataset
    )
    print(f"  Loaded: {df.shape[0]:,} rows, {df.shape[1]} columns")
    return {"data": df}

if __name__ == "__main__":
    tables = extract_data()
    print(tables["data"].head())