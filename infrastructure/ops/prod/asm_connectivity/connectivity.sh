#!/usr/bin/env bash

is_deployment_ready() {
kubectl --context $1 -n $2 get deploy $3 &> /dev/null
    export exit_code=$?
    while [ ! " ${exit_code} " -eq 0 ]
        do 
            sleep 5
            echo -e "Waiting for deployment $3 in cluster $1 to be created..."
            kubectl --context $1 -n $2 get deploy $3 &> /dev/null
            export exit_code=$?
        done
    echo -e "Deployment $3 in cluster $1 created."

    # Once deployment is created, check for deployment status.availableReplicas is greater than 0
    export availableReplicas=$(kubectl --context $1 -n $2 get deploy $3 -o json | jq -r '.status.availableReplicas')
    while [[ " ${availableReplicas} " == " null " ]]
        do 
            sleep 5
            echo -e "Waiting for deployment $3 in cluster $1 to become ready..."
            export availableReplicas=$(kubectl --context $1 -n $2 get deploy $3 -o json | jq -r '.status.availableReplicas')
        done
    
    echo -e "$3 in cluster $1 is ready with replicas ${availableReplicas}."
    return ${availableReplicas}
}

# Get kubeconfig for all clusters
gsutil cp -r gs://$PROJECT_ID/kubeconfig/config config
export KUBECONFIG=./config
gcloud container clusters get-credentials ${GKE1} --zone ${GKE1_LOCATION} --project ${PROJECT_ID}
gcloud container clusters get-credentials ${GKE2} --zone ${GKE2_LOCATION} --project ${PROJECT_ID}

kubectl config rename-context eks_${EKS1} ${EKS1}
kubectl config rename-context eks_${EKS2} ${EKS2}
kubectl config rename-context gke_${PROJECT_ID}_${GKE1_LOCATION}_${GKE1} ${GKE1}
kubectl config rename-context gke_${PROJECT_ID}_${GKE2_LOCATION}_${GKE2} ${GKE2}

# Create namespaces
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

# Verify Pods are ready
is_deployment_ready ${GKE1} app1 httpbin
is_deployment_ready ${GKE1} app1 sleep
is_deployment_ready ${GKE2} app2 httpbin
is_deployment_ready ${GKE2} app2 sleep
is_deployment_ready ${EKS1} app3 httpbin
is_deployment_ready ${EKS1} app3 sleep
is_deployment_ready ${EKS2} app4 httpbin
is_deployment_ready ${EKS2} app4 sleep

# Test connectivity
echo -e "\n"
echo -e "$GKE1 to $GKE2"
kubectl --context ${GKE1} exec -it -n app1 $(kubectl get pod --context ${GKE1} -n app1 | grep sleep | awk '{print $1}') -c sleep -- curl http://httpbin.app2:8000/get

echo -e "\n"
echo -e "$GKE1 to $EKS1"
kubectl --context ${GKE1} exec -it -n app1 $(kubectl get pod --context ${GKE1} -n app1 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app3:8000/get

echo -e "\n"
echo -e "$GKE1 to $EKS2"
kubectl --context ${GKE1} exec -it -n app1 $(kubectl get pod --context ${GKE1} -n app1 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app4:8000/get

echo -e "\n"
echo -e "$GKE2 to $GKE1"
kubectl --context ${GKE2} exec -it -n app2 $(kubectl get pod --context ${GKE2} -n app2 | grep sleep | awk '{print $1}') -c sleep -- curl http://httpbin.app1:8000/get

echo -e "\n"
echo -e "$GKE2 to $EKS1"
kubectl --context ${GKE2} exec -it -n app2 $(kubectl get pod --context ${GKE2} -n app2 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app3:8000/get

echo -e "\n"
echo -e "$GKE2 to $EKS2"
kubectl --context ${GKE2} exec -it -n app2 $(kubectl get pod --context ${GKE2} -n app2 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app4:8000/get

echo -e "\n"
echo -e "$EKS1 to $GKE1"
kubectl --context ${EKS1} exec -it -n app3 $(kubectl get pod --context ${EKS1} -n app3 | grep sleep | awk '{print $1}') -c sleep -- curl http://httpbin.app1:8000/get

echo -e "\n"
echo -e "$EKS1 to $GKE2"
kubectl --context ${EKS1} exec -it -n app3 $(kubectl get pod --context ${EKS1} -n app3 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app2:8000/get

echo -e "\n"
echo -e "$EKS1 to $EKS2"
kubectl --context ${EKS1} exec -it -n app3 $(kubectl get pod --context ${EKS1} -n app3 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app4:8000/get

echo -e "\n"
echo -e "$EKS2 to $GKE1"
kubectl --context ${EKS2} exec -it -n app4 $(kubectl get pod --context ${EKS2} -n app4 | grep sleep | awk '{print $1}') -c sleep -- curl http://httpbin.app1:8000/get

echo -e "\n"
echo -e "$EKS2 to $GKE2"
kubectl --context ${EKS2} exec -it -n app4 $(kubectl get pod --context ${EKS2} -n app4 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app2:8000/get

echo -e "\n"
echo -e "$EKS2 to $EKS1"
kubectl --context ${EKS2} exec -it -n app4 $(kubectl get pod --context ${EKS2} -n app4 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app3:8000/get
