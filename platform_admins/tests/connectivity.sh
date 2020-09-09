#!/usr/bin/env bash

# Define vars
export GKE1=gke-r1a-prod-1
export EKS1=eks-r1ab-prod-1
export GKE2=gke-r1b-prod-2
export EKS2=eks-r1ab-prod-2

# Create namespaces
mkdir -p ~/asm-test && cd ~/asm-test
cat > 03_namespace-app1.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: app1
  labels:
    istio-injection: enabled
EOF

cat > 03_namespace-app2.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: app2
  labels:
    istio-injection: enabled
EOF

cat > 03_namespace-app3.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: app3
  labels:
    istio-injection: enabled
EOF

cat > 03_namespace-app4.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: app4
  labels:
    istio-injection: enabled
EOF

# Download httpbin and sleep YAMLs
wget -O 04_app-httpbin.yaml https://gitlab.com/ameer00/istioplayground/raw/master/policy1/httpbin-ns.yaml
wget -O 04_app-sleep.yaml https://gitlab.com/ameer00/istioplayground/raw/master/policy1/sleep-ns.yaml
wget -O 04_app-helloworld.yaml https://raw.githubusercontent.com/istio/istio/release-1.3/samples/helloworld/helloworld.yaml
wget -O 05_app-httpbin-svc.yaml https://gitlab.com/ameer00/istioplayground/raw/master/policy1/httpbin-service-ns.yaml

# Create manifests
sed s/"namespace: default"/"namespace: app1"/g 04_app-httpbin.yaml | tee 04_app-httpbin-in-app1.yaml
sed s/"namespace: default"/"namespace: app2"/g 04_app-httpbin.yaml | tee 04_app-httpbin-in-app2.yaml
sed s/"namespace: default"/"namespace: app3"/g 04_app-httpbin.yaml | tee 04_app-httpbin-in-app3.yaml
sed s/"namespace: default"/"namespace: app4"/g 04_app-httpbin.yaml | tee 04_app-httpbin-in-app4.yaml

sed s/"namespace: default"/"namespace: app1"/g 04_app-sleep.yaml | tee 04_app-sleep-in-app1.yaml
sed s/"namespace: default"/"namespace: app2"/g 04_app-sleep.yaml | tee 04_app-sleep-in-app2.yaml
sed s/"namespace: default"/"namespace: app3"/g 04_app-sleep.yaml | tee 04_app-sleep-in-app3.yaml
sed s/"namespace: default"/"namespace: app4"/g 04_app-sleep.yaml | tee 04_app-sleep-in-app4.yaml

sed s/"namespace: default"/"namespace: app1"/g 05_app-httpbin-svc.yaml | tee 05_app-httpbin-svc-in-app1.yaml
sed s/"namespace: default"/"namespace: app2"/g 05_app-httpbin-svc.yaml | tee 05_app-httpbin-svc-in-app2.yaml
sed s/"namespace: default"/"namespace: app3"/g 05_app-httpbin-svc.yaml | tee 05_app-httpbin-svc-in-app3.yaml
sed s/"namespace: default"/"namespace: app4"/g 05_app-httpbin-svc.yaml | tee 05_app-httpbin-svc-in-app4.yaml

# Deploy namespaces
kubectl --context=${GKE1} apply -f 03_namespace-app1.yaml
kubectl --context=${GKE2} apply -f 03_namespace-app1.yaml
kubectl --context=${EKS1} apply -f 03_namespace-app1.yaml
kubectl --context=${EKS2} apply -f 03_namespace-app1.yaml

kubectl --context=${GKE1} apply -f 03_namespace-app2.yaml
kubectl --context=${GKE2} apply -f 03_namespace-app2.yaml
kubectl --context=${EKS1} apply -f 03_namespace-app2.yaml
kubectl --context=${EKS2} apply -f 03_namespace-app2.yaml

kubectl --context=${GKE1} apply -f 03_namespace-app3.yaml
kubectl --context=${GKE2} apply -f 03_namespace-app3.yaml
kubectl --context=${EKS1} apply -f 03_namespace-app3.yaml
kubectl --context=${EKS2} apply -f 03_namespace-app3.yaml

kubectl --context=${GKE1} apply -f 03_namespace-app4.yaml
kubectl --context=${GKE2} apply -f 03_namespace-app4.yaml
kubectl --context=${EKS1} apply -f 03_namespace-app4.yaml
kubectl --context=${EKS2} apply -f 03_namespace-app4.yaml

# Deploy httpbin services in all clusters
kubectl --context=${GKE1} apply -f 05_app-httpbin-svc-in-app1.yaml
kubectl --context=${GKE2} apply -f 05_app-httpbin-svc-in-app1.yaml
kubectl --context=${EKS1} apply -f 05_app-httpbin-svc-in-app1.yaml
kubectl --context=${EKS2} apply -f 05_app-httpbin-svc-in-app1.yaml

kubectl --context=${GKE1} apply -f 05_app-httpbin-svc-in-app2.yaml
kubectl --context=${GKE2} apply -f 05_app-httpbin-svc-in-app2.yaml
kubectl --context=${EKS1} apply -f 05_app-httpbin-svc-in-app2.yaml
kubectl --context=${EKS2} apply -f 05_app-httpbin-svc-in-app2.yaml

kubectl --context=${GKE1} apply -f 05_app-httpbin-svc-in-app3.yaml
kubectl --context=${GKE2} apply -f 05_app-httpbin-svc-in-app3.yaml
kubectl --context=${EKS1} apply -f 05_app-httpbin-svc-in-app3.yaml
kubectl --context=${EKS2} apply -f 05_app-httpbin-svc-in-app3.yaml

kubectl --context=${GKE1} apply -f 05_app-httpbin-svc-in-app4.yaml
kubectl --context=${GKE2} apply -f 05_app-httpbin-svc-in-app4.yaml
kubectl --context=${EKS1} apply -f 05_app-httpbin-svc-in-app4.yaml
kubectl --context=${EKS2} apply -f 05_app-httpbin-svc-in-app4.yaml

# Deploy httpbin deployments
kubectl --context=${GKE1} apply -f 04_app-httpbin-in-app1.yaml
kubectl --context=${GKE2} apply -f 04_app-httpbin-in-app2.yaml
kubectl --context=${EKS1} apply -f 04_app-httpbin-in-app3.yaml
kubectl --context=${EKS2} apply -f 04_app-httpbin-in-app4.yaml

# Deploy sleep
kubectl --context=${GKE1} apply -f 04_app-sleep-in-app1.yaml
kubectl --context=${GKE2} apply -f 04_app-sleep-in-app2.yaml
kubectl --context=${EKS1} apply -f 04_app-sleep-in-app3.yaml
kubectl --context=${EKS2} apply -f 04_app-sleep-in-app4.yaml

