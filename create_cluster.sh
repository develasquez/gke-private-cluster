gcloud config set compute/zone us-central1-a

export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
export REGION=us-central1
export ZONE=a
export SUBNET_RANGE=10.128.0.0/20 

gcloud compute networks create k8s-vpc \
--project=$PROJECT_ID \
--subnet-mode=custom \
--mtu=1460 \
--bgp-routing-mode=regional

gcloud compute networks subnets create k8s-subnet \
--project=$PROJECT_ID \
--range=$SUBNET_RANGE \
--network=k8s-vpc \
--region=$REGION


gcloud services enable container.googleapis.com

gcloud container clusters create "k8s" \
--zone "$REGION-$ZONE" \
--machine-type "n2-standard-2" \
--disk-size "10" \
--num-nodes "3" \
--enable-private-nodes \
--master-ipv4-cidr "172.16.0.0/28" \
--enable-ip-alias \
--network "projects/$PROJECT_ID/global/networks/k8s-vpc" \
--subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/k8s-subnet" \
--node-locations "$REGION-$ZONE" \
--workload-pool=$PROJECT_ID.svc.id.goog \
--enable-shielded-nodes \
--shielded-secure-boot \
--shielded-integrity-monitoring

 

