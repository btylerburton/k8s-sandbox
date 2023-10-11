.DEFAULT_GOAL := help

## set the release-name & namespace
export AIRFLOW_NAME="airflow-cluster"
export AIRFLOW_NAMESPACE="airflow-cluster"

up: ## Set up a Kubernetes using Helm
	## add this helm repository
	# @helm repo add airflow-stable https://airflow-helm.github.io/charts
	@helm repo add apache-airflow https://airflow.apache.org
	## update your helm repo cache
	@helm repo update
	## create the namespace
	@kubectl create ns ${AIRFLOW_NAMESPACE}

	## install using helm 3
	# @helm install \
	# ${AIRFLOW_NAME} \
	# airflow-stable/airflow \
	# --namespace ${AIRFLOW_NAMESPACE} \
	# --version "8.8.0" \
	# --values ./custom-values-k8s.yml
	@helm upgrade \
	--install ${AIRFLOW_NAME} \
	apache-airflow/airflow \
	--namespace ${AIRFLOW_NAMESPACE} \
	--create-namespace \
	--version "8.8.0" \
	--values ./custom-values-k8s.yml
	
	## wait until the above command returns and resources become ready 
	## (may take a while)

down: ## Tear down K8s 
	## uninstall the chart
	# @helm uninstall \
	# ${AIRFLOW_NAME} \
	# --namespace ${AIRFLOW_NAMESPACE}
	# ## delete the ${AIRFLOW_NAMESPACE}
	# @kubectl delete ns ${AIRFLOW_NAMESPACE}
	@helm delete ${AIRFLOW_NAME} -n ${AIRFLOW_NAMESPACE}
	@kubectl delete ns ${AIRFLOW_NAMESPACE}
	
webserver: ## forward ports and launch a webserver
	## port-forward the airflow webserver
	@kubectl port-forward svc/${AIRFLOW_NAME}-web 8080:8080 --namespace ${AIRFLOW_NAMESPACE}
	
	## open your browser to: http://localhost:8080 
	## (default login: `admin`/`admin`)

.PHONY: up down webserver
# Output documentation for top-level targets
# Thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)