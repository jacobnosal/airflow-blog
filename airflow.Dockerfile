FROM apache/airflow:2.2.2 AS spark-package
RUN pip install --no-cache-dir apache-airflow-providers-apache-spark==2.0.2

FROM spark-package AS java-package
USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
         default-jre \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER airflow