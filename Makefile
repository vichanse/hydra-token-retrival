# Makefile to automate Minikube setup

# Variables
HYDRA_CHART=ory/hydra
HYDRA_MAESTER_CHART=ory/hydra-maester
HELM_VERSION=0.49.0
MAESTER_VERSION=0.49.0
SYMFONY_IMAGE=hydra-token-retrieval:latest
KUBECTL = kubectl
MINIKUBE = minikube
HELMFILE = helmfile

# Start Minikube, build images, and deploy everything
start: minikube-start enable-ingress create-namespaces helm-init build-symfony deploy-hydra deploy-maester deploy-oauth2client deploy-symfony apply-ingress update-etc-hosts
	

# Stop Minikube and remove everything
stop:
	minikube stop

# Clean up all resources
clean:

	@echo "Stopping Minikube..."
	$(MINIKUBE) stop
	$(MINIKUBE) delete

	@echo "Removing /etc/hosts entries..."
	sudo sed -i '' '/hydra.localhost/d' /etc/hosts
	sudo sed -i '' '/symfony.localhost/d' /etc/hosts

	@echo "Clean up complete."


# Start Minikube
minikube-start:
	@echo "Starting Minikube..."
	minikube start --cpus 4 --memory 8192

# Enable NGINX Ingress addon in Minikube
enable-ingress:
	@echo "Enabling NGINX Ingress in Minikube..."
	minikube addons enable ingress
	

# Create required namespaces
create-namespaces:
	@echo "Creating namespaces..."
	kubectl get ns hydra || kubectl create namespace hydra

# Initialize Helm in Minikube
helm-init:
	@echo "Initializing Helm..."
	helm repo add ory https://k8s.ory.sh/helm/charts
	helm repo update

# Use Minikube's Docker environment
minikube-docker-env:
	@echo "Setting up Minikube Docker environment..."
	eval $(minikube -p minikube docker-env)

# Build the Symfony app image and load into Minikube
build-symfony: minikube-docker-env
	@echo "Building Symfony app image..."
	SERVER_NAME=http://localhost APP_SECRET=lc8Kn7pOvWfgQ05ceOdhxZubSKypaMzij1uSmUcRY CADDY_MERCURE_JWT_SECRET=HyIu73m78stsu5Po3PYz2UsO2MQdRyRcDTVI2wmFHw docker compose -f compose.yaml -f compose.prod.yaml build
	minikube image load $(SYMFONY_IMAGE)

# Deploy Hydra using Helm
deploy-hydra:
	@echo "Deploying Ory Hydra..."
	helm install hydra $(HYDRA_CHART) --version $(HELM_VERSION) -f helm/hydra-values.yaml

# Deploy Hydra Maester using Helm
deploy-maester:
	@echo "Deploying Hydra Maester..."
	helm install hydra-maester $(HYDRA_MAESTER_CHART) --version $(MAESTER_VERSION) -f helm/maester-values.yaml

# Deploy OAuth2Client resource
deploy-oauth2client:
	@echo "Deploying OAuth2Client resources..."
	kubectl apply -f helm/oauth2client.yaml

# Deploy the Symfony app in Kubernetes
deploy-symfony:
	@echo "Deploying Symfony app..."
	kubectl apply -f helm/symfony-deployment.yaml
	kubectl apply -f helm/hydra-token-retrieval-service.yaml

# Port forwarding for Hydra and Symfony
port-forward:
	@echo "Port forwarding for Hydra and Symfony..."
	(kubectl port-forward svc/hydra-public 4444:4444 &)   # Run Hydra port forward in background
	(kubectl port-forward svc/hydra-token-retrieval 8080:80 &)      # Run Symfony port forward in background

# Apply Ingress resources for Hydra and Symfony
apply-ingress:
	@echo "Applying Ingress resources for Hydra and Symfony..."
	kubectl apply -f helm/ingress-hydra.yaml
	kubectl apply -f helm/symfony-ingress.yaml

update-etc-hosts:
	@echo "Updating /etc/hosts..."
	@echo "127.0.0.1 hydra.localhost symfony.localhost" | sudo tee -a /etc/hosts