FROM python:3.7.16-slim

# install airflow
ENV AIRFLOW_HOME="/root/airflow"
ENV AIRFLOW__WORKER__NAME="worker_node"

ENV AIRFLOW__MASTER__IP="192.168.0.197"
ENV AIRFLOW__POSTGRESQL__HOST=${AIRFLOW__MASTER__IP}:5432
ENV AIRFLOW__REDIS__HOST=${AIRFLOW__MASTER__IP}:6379
ENV AIRFLOW__CORE__EXECUTOR="CeleryExecutor"
ENV AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="postgresql+psycopg2://airflow:airflow@${AIRFLOW__POSTGRESQL__HOST}/airflow"
ENV AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://airflow:airflow@${AIRFLOW__POSTGRESQL__HOST}/airflow"
ENV AIRFLOW__CELERY__RESULT_BACKEND="db+postgresql://airflow:airflow@${AIRFLOW__POSTGRESQL__HOST}/airflow"
ENV AIRFLOW__CELERY__BROKER_URL="redis://:@${AIRFLOW__REDIS__HOST}/0"
ENV AIRFLOW__LOGGING__BASE_LOG_FOLDER="${AIRFLOW_HOME}/log"
ENV AIRFLOW__SCHEDULER__CHILD_PROCESS_LOG_DIRECTORY="${AIRFLOW_HOME}/log/scheduler"
ENV AIRFLOW__LOGGING__DAG_PROCESSOR_MANAGER_LOG_LOCATION="${AIRFLOW_HOME}/log/dag_processor_manager/dag_processor_manager.log"
ENV AIRFLOW__CORE__HOSTNAME_CALLABLE="airflow.utils.net.get_host_ip_address"
ENV AIRFLOW__CORE__FERNET_KEY="a5U_Gv6kfzh3_CfevpRZxaoMTHk8Tn-XOpMO0pqwPag="
ENV AIRFLOW__WEBSERVER__SECRET_KEY="HOST_SECRET_KEY"
ENV AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION="true"
ENV AIRFLOW__CORE__LOAD_EXAMPLES="false"
ENV AIRFLOW__API__AUTH_BACKENDS="airflow.api.auth.backend.basic_auth"
ENV _pip_ADDITIONAL_REQUIREMENTS="${_pip_ADDITIONAL_REQUIREMENTS:-apache-airflow-providers-google}"

# pip update
RUN apt-get update && apt-get install -y python3-distutils python3-setuptools
RUN python3 -m pip install pip --upgrade pip
# RUN apt-get install python3.7-dev libmysqlclient-dev gcc -y
RUN python3 -m pip install cffi

# install airflow
RUN pip install apache-airflow[celery]==2.5.0
RUN pip install psycopg2-binary
RUN pip install Redis
RUN airflow db init
RUN mkdir -p ./airflow/dags
RUN mkdir ./airflow/plugins

# healthcheck
HEALTHCHECK --interval=10s --timeout=10s --retries=5 CMD airflow jobs check --job-type SchedulerJob --hostname "$${HOSTNAME}"
