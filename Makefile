default: dry-run

dry-run:
	helm upgrade \
		--install \
		--dry-run \
		-f values.yaml \
		--namespace airflow \
		airflow \
		apache-airflow/airflow 

plan:
	terraform plan -var "password=$SP_PASSWORD"

apply:
	tarreaform apply -var "password=$SP_PASSWORD"

add-repo:
	helm repo add apache-airflow https://airflow.apache.org

install:
	helm upgrade \
		--install \
		-f values.yaml \
		--namespace airflow \
		airflow \
		apache-airflow/airflow 