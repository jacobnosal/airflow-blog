default: dry-run

CLUSTER_NAME := airflow-demo
RESOURCE_GROUP := airflow-demo

add-service-principal:
	az ad sp create-for-rbac --skip-assignment
# https://www.elastic.co/guide/en/cloud/current/ec-regions-templates-instances.html#ec-azure_regions
plan:
	terraform plan \
		-var "cluster_name=$(CLUSTER_NAME)" \
		-var "resource_group_name=$(RESOURCE_GROUP)"

apply:
	terraform apply \
		-var "cluster_name=$(CLUSTER_NAME)" \
		-var "resource_group_name=$(RESOURCE_GROUP)" \
		-auto-approve

destroy:
	terraform destroy \
		-var "cluster_name=$(CLUSTER_NAME)" \
		-var "resource_group_name=$(RESOURCE_GROUP)" \
		-auto-approve

cluster-setup:
	kubectl apply -f namespace.yaml
	kubectl apply -f elastic-secret.yaml

airflow-add-repo:
	helm repo add apache-airflow https://airflow.apache.org

airflow-dry-run:
	helm upgrade \
		--install \
		--dry-run \
		-f airflow-values.yaml \
		--namespace airflow \
		airflow \
		apache-airflow/airflow 

airflow-install:
	helm upgrade \
		--install \
		-f airflow-values.yaml \
		--namespace airflow \
		--timeout 30m0s \
		--wait=false \
		airflow \
		apache-airflow/airflow 

airflow-uninstall: 
	helm delete --namespace airflow airflow

fluentd-add-repo:
	helm repo add fluent https://fluent.github.io/helm-charts

fluentd-dry-run:
	helm upgrade \
		--install \
		--dry-run \
		-f fluentd-values.yaml \
		fluentd fluent/fluentd

fluentd-install:
	helm upgrade \
		--install \
		-f fluentd-values.yaml \
		fluentd fluent/fluentd

fluentd-uninstall:
	helm delete fluentd

metricbeat-add-repo:
	helm repo add elastic https://helm.elastic.co

metricbeat-dry-run:
	helm upgrade \
		--install \
		--dry-run \
		-f metricbeat-values.yaml \
		--version 7.15.0 \
		metricbeat elastic/metricbeat

metricbeat-install:
	helm upgrade \
		--install \
		-f metricbeat-values.yaml \
		--version 7.15.0 \
		metricbeat elastic/metricbeat

metricbeat-uninstall:
	helm delete metricbeat

filebeat-dry-run:
	helm upgrade \
		--install \
		--dry-run \
		-f filebeat-values.yaml \
		--version 7.15.0 \
		filebeat elastic/filebeat

filebeat-install:
	helm upgrade \
		--install \
		-f filebeat-values.yaml \
		--version 7.15.0 \
		filebeat elastic/filebeat

filebeat-uninstall:
	helm delete filebeat

ingress-add-repo:
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

ingress-dry-run:
	helm upgrade \
		--install \
		--dry-run \
		--set defaultBackend.enabled=true \
		-n airflow \
		nginx ingress-nginx/ingress-nginx

ingress-install:
	helm upgrade \
		--install \
		--set defaultBackend.enabled=true \
		-n airflow \
		nginx ingress-nginx/ingress-nginx

ingress-uninstall:
	helm delete -n airflow nginx

build-images:
	docker build -t jacobnosal/airflow:2.2.2-providers --target=providers -f airflow.Dockerfile .
	docker build -t jacobnosal/airflow:2.2.2-spark-worker --target=java-package  -f airflow.Dockerfile .

push-images:
	docker push jacobnosal/airflow:2.2.2-providers
	docker push jacobnosal/airflow:2.2.2-spark-worker

.PHONY: image-pipeline
image-pipeline: build-images push-images

get-k8s-creds:
	az aks get-credentials --name $(CLUSTER_NAME) --resource-group $(RESOURCE_GROUP)

port-forward:
	kubectl port-forward svc/airflow-webserver 8080:8080 --namespace airflow

airflow-worker-rolebinding:
	kubectl create clusterrolebinding airflow-worker-spark-role --clusterrole=edit --serviceaccount=airflow:airflow-worker --namespace=airflow
