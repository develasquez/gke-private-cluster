git clone https://github.com/GoogleCloudPlatform/anthos-service-mesh-samples
cd anthos-service-mesh-samples/docs/canary-service

kubectl create namespace onlineboutique

kubectl label namespace onlineboutique istio-injection=enabled istio.io/rev-

kubectl apply \
-n onlineboutique \
-f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/main/release/kubernetes-manifests.yaml

kubectl patch deployments/productcatalogservice -p '{"spec":{"template":{"metadata":{"labels":{"version":"v1"}}}}}' \
-n onlineboutique

kubectl get pods -n onlineboutique -w

