default: dry-run

CLUSTER_NAME := airflow-demo
RESOURCE_GROUP := airflow-demo

add-service-principal:
	az ad sp create-for-rbac --skip-assignment

plan:
	terraform plan -var "cluster_name=$(CLUSTER_NAME)" -var "resource_group_name=$(RESOURCE_GROUP)"

apply:
	terraform apply -var "cluster_name=$(CLUSTER_NAME)" -var "resource_group_name=$(RESOURCE_GROUP)"

destroy:
	terraform destroy -var "cluster_name=$(CLUSTER_NAME)" -var "resource_group_name=$(RESOURCE_GROUP)"

add-repo:
	helm repo add apache-airflow https://airflow.apache.org

dry-run:
	helm upgrade \
		--install \
		--dry-run \
		-f values.yaml \
		--namespace airflow \
		airflow \
		apache-airflow/airflow 

install:
	helm upgrade \
		--install \
		-f values.yaml \
		--namespace airflow \
		--timeout 30m0s \
		--wait=false \
		airflow \
		apache-airflow/airflow 

uninstall: 
	helm delete --namespace airflow airflow

.PHONY: pipeline
pipeline: 

get-k8s-creds:
	az aks get-credentials --name $(CLUSTER_NAME) --resource-group $(RESOURCE_GROUP)

port-forward:
	kubectl port-forward svc/airflow-webserver 8080:8080 --namespace airflow