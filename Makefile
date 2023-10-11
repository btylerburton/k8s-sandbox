.DEFAULT_GOAL := help

CLUSTER_NAME=datagov-airflow-test
# kind-up: ## Set up a Kubernetes test environment using KinD
# 	# Creating a temporary Kubernetes cluster to test against with KinD
# 	@kind create cluster --config kind/kind-config.yaml --name datagov-broker-test
# 	# Grant cluster-admin permissions to the `system:serviceaccount:default:default` Service.
# 	# (This is necessary for the service account to be able to create the cluster-wide
# 	# Solr CRD definitions.)
# 	@kubectl create clusterrolebinding default-sa-cluster-admin --clusterrole=cluster-admin --serviceaccount=default:default --namespace=default
# 	# Install a KinD-flavored ingress controller (to make the Solr instances visible to the host).
# 	# See (https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx for details.
# 	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.1/deploy/static/provider/kind/deploy.yaml
# 	@kubectl wait --namespace ingress-nginx \
#       --for=condition=ready pod \
#       --selector=app.kubernetes.io/component=controller \
#       --timeout=270s
# 	@kubectl apply -f kind/persistent-storage.yml
# 	# Install the ZooKeeper and Solr operators using Helm
# 	kubectl create -f https://solr.apache.org/operator/downloads/crds/v0.5.0/all-with-dependencies.yaml
# 	@helm install --namespace kube-system --repo https://solr.apache.org/charts --version 0.5.0 solr solr-operator
# 	@helm upgrade --install airflow airflow --namespace airflow --create-namespace --repo https://airflow.apache.org -f ./airflow-helm-overrides.yml

up: ## Set up a Kubernetes test environment using KinD
	# Creating a temporary Kubernetes cluster to test against with KinD
	@kind create cluster --config ./kind-config.yaml --name ${CLUSTER_NAME}
	@helm upgrade --install airflow . -n airflow --create-namespace -f values.yml
down: ## Tear down the Kubernetes test environment in KinD
	# Delete the kind cluser
	# @kind delete cluster --name ${CLUSTER_NAME}
	# Delete the airflow release
	@helm uninstall airflow --namespace=airflow
	# Delete the airflow namespace
	@kubectl delete namespace airflow


webserver: ## forward ports and launch a webserver
	@kubectl port-forward svc/airflow-webserver 8080:8080 --namespace airflow

.PHONY: kind-up kind-down webserver
# Output documentation for top-level targets
# Thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)