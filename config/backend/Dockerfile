FROM apache/airflow:3.1.1-python3.12

USER root
RUN apt update && apt install -y gcc python3-dev

USER airflow
COPY requirements.txt ${AIRFLOW_HOME}
RUN pip install --no-cache-dir -r ${AIRFLOW_HOME}/requirements.txt