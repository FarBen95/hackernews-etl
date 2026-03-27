import pendulum
from airflow.decorators import dag, task

# 1. Define the DAG using a decorator
@dag(
    dag_id="basic_example_dag",
    schedule="@daily",             # Runs once every day
    start_date=pendulum.datetime(2024, 1, 1, tz="UTC"),
    catchup=False,                 # Don't run historical tasks
    tags=["example"],
)
def basic_dag_pipeline():

    # 2. Define individual tasks
    @task()
    def extract():
        return {"data": "some_raw_value"}

    @task()
    def transform(raw_data: dict):
        # Process the data
        processed_value = raw_data["data"].upper()
        return {"processed_data": processed_value}

    @task()
    def load(final_data: dict):
        # Simulate loading data (e.g., to a database)
        print(f"Loading data: {final_data['processed_data']}")

    # 3. Define the flow (dependencies)
    data = extract()
    transformed_data = transform(data)
    load(transformed_data)

# 4. Instantiate the DAG
basic_dag_pipeline()
