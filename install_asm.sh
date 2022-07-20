export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
export REGION=us-central1
export ZONE=a
export CLUSTER_NAME=k8s

gcloud container clusters get-credentials $CLUSTER_NAME \
    --project=$PROJECT_ID \
    --zone="$REGION-$ZONE"

kubectl config set-context k8s

export MY_IP=$(curl ipinfo.io/ip)
gcloud container clusters update "k8s" \
    --enable-master-authorized-networks \
    --master-authorized-networks $MY_IP/32 \
    --zone $REGION-$ZONE
 

curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.13 > asmcli
chmod +x asmcli

./asmcli install \
  --project_id $PROJECT_ID \
  --cluster_name $CLUSTER_NAME \
  --cluster_location "$REGION-$ZONE" \
  --enable_all \
  --output_dir . \
  --ca mesh_ca




export REVISION=$(kubectl get deploy -n istio-system -l app=istiod -o   jsonpath={.items[*].metadata.labels.'istio\.io\/rev'}'{"\n"}')

kubectl label namespace istio-system istio-injection=enabled istio.io/rev-
kubectl apply -n istio-system \
  -f ./samples/gateways/istio-ingressgateway

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')

gcloud compute firewall-rules create allow-gateway-http --network k8s-vpc --allow "tcp:15017"
gcloud compute firewall-rules create allow-gateway-https --network k8s-vpc--allow "tcp:9443"



