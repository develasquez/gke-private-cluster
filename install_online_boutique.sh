kpt pkg get \
  https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages.git/samples/online-boutique \
  online-boutique

cd online-boutique

kubectl apply -f kubernetes-manifests/namespaces
kubectl apply -f kubernetes-manifests/deployments
kubectl apply -f kubernetes-manifests/services
kubectl apply -f istio-manifests/allow-egress-googleapis.yaml

export REVISION=$(kubectl get deploy -n istio-system -l app=istiod -o   jsonpath={.items[*].metadata.labels.'istio\.io\/rev'}'{"\n"}')

for ns in ad cart checkout currency email frontend loadgenerator \
  payment product-catalog recommendation shipping; do
    kubectl label namespace $ns istio.io/rev=$REVISION --overwrite
done;

for ns in ad cart checkout currency email frontend loadgenerator \
  payment product-catalog recommendation shipping; do
    kubectl rollout restart deployment -n ${ns}
done;

kubectl apply -f istio-manifests/frontend-gateway.yaml

