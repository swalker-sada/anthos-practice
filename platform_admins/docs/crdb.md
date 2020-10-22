### Create namespaces for CRDB

```
mkdir -p ${HOME}/crdb && cd ${HOME}/crdb

echo -e "export GKE_CRDB_NS=gke-crdb" >> ${WORKDIR}/vars.sh
echo -e "export EKS_CRDB_NS=eks-crdb" >> ${WORKDIR}/vars.sh
source ${WORKDIR}/vars.sh

kubectl create namespace ${EKS_CRDB_NS} --context=${EKS_PROD_1} 
kubectl create namespace ${GKE_CRDB_NS} --context=${GKE_PROD_1}

kubectl label namespace ${EKS_CRDB_NS} istio-injection=enabled --context=${EKS_PROD_1}
kubectl label namespace ${GKE_CRDB_NS} istio-injection=enabled --context=${GKE_PROD_1}
```

### Deploy sleep and httpbin to EKS and GKE clusters

```
kubectl apply -f ~/istio-1.6.8-asm.9/samples/sleep/sleep.yaml -n ${EKS_CRDB_NS} --context=${EKS_PROD_1}
kubectl apply -f ~/istio-1.6.8-asm.9/samples/httpbin/httpbin.yaml -n ${GKE_CRDB_NS} --context=${GKE_PROD_1}

kubectl apply -f ~/istio-1.6.8-asm.9/samples/sleep/sleep.yaml -n ${GKE_CRDB_NS} --context=${GKE_PROD_1}
kubectl apply -f ~/istio-1.6.8-asm.9/samples/httpbin/httpbin.yaml -n ${EKS_CRDB_NS} --context=${EKS_PROD_1}
```

### Get GKE and EKS istio-ingress IP and hostname

```
export GKE_PROD_1_INGRESS=$(kubectl get svc --selector=app=istio-ingressgateway -n istio-system -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' --context=${GKE_PROD_1})

export EKS_PROD_1_INGRESS=$(kubectl get svc --selector=app=istio-ingressgateway -n istio-system -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}' --context=${EKS_PROD_1})
```

### Create serviceentries in EKS and GKE to reach the other httpbin pod

```
cat <<EOF > ${HOME}/crdb/serviceentry--httpbin-eks.yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: httpbin-${GKE_CRDB_NS}
spec:
  hosts:
  - httpbin.${GKE_CRDB_NS}.global
  location: MESH_INTERNAL
  ports:
  - name: http1
    number: 8000
    protocol: http
  resolution: DNS
  addresses:
  - 240.0.0.2
  endpoints:
  - address: ${GKE_PROD_1_INGRESS}
    ports:
      http1: 15443
EOF

cat <<EOF > ${HOME}/crdb/serviceentry--httpbin-gke.yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: httpbin-${EKS_CRDB_NS}
spec:
  hosts:
  - httpbin.${EKS_CRDB_NS}.global
  location: MESH_INTERNAL
  ports:
  - name: http1
    number: 8000
    protocol: http
  resolution: DNS
  addresses:
  - 240.0.0.2
  endpoints:
  - address: ${EKS_PROD_1_INGRESS}
    ports:
      http1: 15443
EOF

kubectl --context=${EKS_PROD_1} -n ${EKS_CRDB_NS} apply -f serviceentry--httpbin-eks.yaml
kubectl --context=${GKE_PROD_1} -n ${GKE_CRDB_NS} apply -f serviceentry--httpbin-gke.yaml

SLEEP_POD_EKS=$(kubectl get pods -n ${EKS_CRDB_NS} -l app=sleep --context=${EKS_PROD_1} -ojsonpath="{.items[].metadata.name}")
SLEEP_POD_GKE=$(kubectl get pods -n ${GKE_CRDB_NS} -l app=sleep --context=${GKE_PROD_1} -ojsonpath="{.items[].metadata.name}")
```

### From EKS to GKE

```
kubectl exec -it ${SLEEP_POD_EKS} -c sleep -n ${EKS_CRDB_NS} --context=${EKS_PROD_1} -- curl httpbin.${GKE_CRDB_NS}.global:8000/headers
```
Output (Do not copy)
```
{
  "headers": {
    "Accept": "*/*",
    "Content-Length": "0",
    "Host": "httpbin.gke-crdb.global:8000",
    "User-Agent": "curl/7.69.1",
    "X-B3-Parentspanid": "8d3bc2785604c2fd",
    "X-B3-Sampled": "0",
    "X-B3-Spanid": "d456f286251ad393",
    "X-B3-Traceid": "77daaa187ee7bbd08d3bc2785604c2fd",
    "X-Envoy-Attempt-Count": "1",
    "X-Forwarded-Client-Cert": "By=spiffe://cluster.local/ns/gke-crdb/sa/httpbin;Hash=84e79075588270517ae5548c2b3d9eee7e2bfa2956667def2baf6b6166bd2ea2;Subject=\"\";URI=spiffe://cluster.local/ns/eks-crdb/sa/sleep"
  }
}
```

### From GKE to EKS

```
kubectl exec -it ${SLEEP_POD_GKE} -c sleep -n ${GKE_CRDB_NS} --context=${GKE_PROD_1} -- curl httpbin.${EKS_CRDB_NS}.global:8000/headers
```
Output (Do not copy)
```
{
  "headers": {
    "Accept": "*/*",
    "Content-Length": "0",
    "Host": "httpbin.eks-crdb.global:8000",
    "User-Agent": "curl/7.69.1",
    "X-B3-Parentspanid": "75234317f9490753",
    "X-B3-Sampled": "0",
    "X-B3-Spanid": "bcdaa790c91206eb",
    "X-B3-Traceid": "1757e73226e7587275234317f9490753",
    "X-Envoy-Attempt-Count": "1",
    "X-Forwarded-Client-Cert": "By=spiffe://cluster.local/ns/eks-crdb/sa/httpbin;Hash=77208b0a31b4b10f96af0ecbefddec3a5b1fb95b9c07f3450587911fd0f38704;Subject=\"\";URI=spiffe://cluster.local/ns/gke-crdb/sa/sleep"
  }
}
```

## CockroachDB

### `cockroach` CLI

```
wget -qO- https://binaries.cockroachdb.com/cockroach-v20.1.7.linux-amd64.tgz | tar xvz
cp -i cockroach-v20.1.7.linux-amd64/cockroach $HOME/.local/bin

curl -OOOOOOOOO https://raw.githubusercontent.com/cockroachdb/cockroach/master/cloud/kubernetes/multiregion/{README.md,client-secure.yaml,cluster-init-secure.yaml,cockroachdb-statefulset-secure.yaml,dns-lb.yaml,example-app-secure.yaml,external-name-svc.yaml,setup.py,teardown.py}
```

Make certs

```
mkdir certs
mkdir ca-keys

cockroach cert create-ca --certs-dir certs --ca-key ca-keys/ca.key
cockroach cert create-client root --certs-dir certs --ca-key ca-keys/ca.key

kubectl create secret generic cockroachdb.client.root --from-file certs --context=${EKS_PROD_1} -n default
kubectl create secret generic cockroachdb.client.root --from-file certs --context=${GKE_PROD_1} -n default

kubectl create secret generic cockroachdb.client.root --from-file certs -n ${GKE_CRDB_NS} --context=${GKE_PROD_1}
kubectl create secret generic cockroachdb.client.root --from-file certs -n ${EKS_CRDB_NS} --context=${EKS_PROD_1}
```

## Node cert for each cluster

```
cockroach cert create-node --certs-dir certs --ca-key ca-keys/ca.key localhost 127.0.0.1 cockroachdb-public cockroachdb-public.default cockroachdb-public.${GKE_CRDB_NS} cockroachdb-public.${GKE_CRDB_NS}.svc.cluster.local *.cockroachdb *.cockroachdb.${GKE_CRDB_NS} *.cockroachdb.${GKE_CRDB_NS}.svc.cluster.local *.devshell.appspot.com *.cloud.goog

kubectl create secret generic cockroachdb.node -n ${GKE_CRDB_NS} --from-file certs --context=${GKE_PROD_1}

rm -rf certs/node.*

cockroach cert create-node --certs-dir certs --ca-key ca-keys/ca.key localhost 127.0.0.1 cockroachdb-public cockroachdb-public.default cockroachdb-public.${EKS_CRDB_NS} cockroachdb-public.${EKS_CRDB_NS}.svc.cluster.local *.cockroachdb *.cockroachdb.${EKS_CRDB_NS} *.cockroachdb.${EKS_CRDB_NS}.svc.cluster.local *.devshell.appspot.com *.cloud.goog

kubectl create secret generic cockroachdb.node -n ${EKS_CRDB_NS} --from-file certs --context=${EKS_PROD_1}
```

## Create SVC in default ns

```
sed s/YOUR_ZONE_HERE/${EKS_CRDB_NS}/g external-name-svc.yaml > external-name-svc-${EKS_CRDB_NS}.yaml
kubectl apply -f external-name-svc-${EKS_CRDB_NS}.yaml --context=${EKS_PROD_1} -n default

sed s/YOUR_ZONE_HERE/${GKE_CRDB_NS}/g external-name-svc.yaml > external-name-svc-${GKE_CRDB_NS}.yaml
kubectl apply -f external-name-svc-${GKE_CRDB_NS}.yaml --context=${GKE_PROD_1} -n default
```

### Verify

```
kubectl get svc cockroachdb-public --context=${EKS_PROD_1} -n default
kubectl get svc cockroachdb-public --context=${GKE_PROD_1} -n default
```

### Create internal service entries

```
cat <<EOF > ${HOME}/crdb/serviceentry--${EKS_CRDB_NS}-internal.yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb-0-headless-service-entry
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
     - cockroachdb-0.cockroachdb.${EKS_CRDB_NS}.svc.cluster.local
  location: MESH_INTERNAL
  ports:
  - number: 26257
    name: crdbheadless1
    protocol: TCP
  - number: 8080
    name: crdbheadless2
    protocol: HTTP
  resolution: DNS

---

apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb-1-headless-service-entry
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
     - cockroachdb-1.cockroachdb.${EKS_CRDB_NS}.svc.cluster.local
  location: MESH_INTERNAL
  ports:
  - number: 26257
    name: crdbheadless1
    protocol: TCP
  - number: 8080
    name: crdbheadless2
    protocol: HTTP
  resolution: DNS

---

apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb-2-headless-service-entry
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
     - cockroachdb-2.cockroachdb.${EKS_CRDB_NS}.svc.cluster.local
  location: MESH_INTERNAL
  ports:
  - number: 26257
    name: crdbheadless1
    protocol: TCP
  - number: 8080
    name: crdbheadless2
    protocol: HTTP
  resolution: DNS
EOF

cat <<EOF > ${HOME}/crdb/serviceentry--${GKE_CRDB_NS}-internal.yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb-0-headless-service-entry
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
     - cockroachdb-0.cockroachdb.${GKE_CRDB_NS}.svc.cluster.local
  location: MESH_INTERNAL
  ports:
  - number: 26257
    name: crdbheadless1
    protocol: TCP
  - number: 8080
    name: crdbheadless2
    protocol: HTTP
  resolution: DNS

---

apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb-1-headless-service-entry
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
     - cockroachdb-1.cockroachdb.${GKE_CRDB_NS}.svc.cluster.local
  location: MESH_INTERNAL
  ports:
  - number: 26257
    name: crdbheadless1
    protocol: TCP
  - number: 8080
    name: crdbheadless2
    protocol: HTTP
  resolution: DNS

---

apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb-2-headless-service-entry
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
     - cockroachdb-2.cockroachdb.${GKE_CRDB_NS}.svc.cluster.local
  location: MESH_INTERNAL
  ports:
  - number: 26257
    name: crdbheadless1
    protocol: TCP
  - number: 8080
    name: crdbheadless2
    protocol: HTTP
  resolution: DNS
EOF


kubectl apply -f serviceentry--${EKS_CRDB_NS}-internal.yaml --context=${EKS_PROD_1}
kubectl apply -f serviceentry--${GKE_CRDB_NS}-internal.yaml --context=${GKE_PROD_1}
```


# Apply cross .global service entries

```
cat <<EOF > ${HOME}/crdb/serviceentry--${EKS_CRDB_NS}-for-${GKE_CRDB_NS}-global.yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb0-${GKE_CRDB_NS}-global
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
  # must be of form name.namespace.global
  - cockroachdb-0.cockroachdb.${GKE_CRDB_NS}.global
  # Treat remote cluster services as part of the service mesh
  # as all clusters in the service mesh share the same root of trust.
  location: MESH_INTERNAL
  ports:
  - name: tcp-cockroachdb
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS
  addresses:
  - 240.0.0.10
  endpoints:
  # This is the routable address of the ingress gateway in ${GKE_CRDB_NS} that
  # sits in front of ${EKS_CRDB_NS}.service.. Traffic from the sidecar will be
  # routed to this address.
  - address: ${GKE_PROD_1_INGRESS}
    ports:
      tcp-cockroachdb: 15443 # Do not change this port value
      cockroachdb-http: 15443 # Do not change this port value

---

apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb1-${GKE_CRDB_NS}-global
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
  # must be of form name.namespace.global
  - cockroachdb-1.cockroachdb.${GKE_CRDB_NS}.global
  # Treat remote cluster services as part of the service mesh
  # as all clusters in the service mesh share the same root of trust.
  location: MESH_INTERNAL
  ports:
  - name: tcp-cockroachdb
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS
  addresses:
  - 240.0.0.11
  endpoints:
  - address: ${GKE_PROD_1_INGRESS}
    ports:
      tcp-cockroachdb: 15443 # Do not change this port value
      cockroachdb-http: 15443 # Do not change this port value

---
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb2-${GKE_CRDB_NS}-global
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
  # must be of form name.namespace.global
  - cockroachdb-2.cockroachdb.${GKE_CRDB_NS}.global
  # Treat remote cluster services as part of the service mesh
  # as all clusters in the service mesh share the same root of trust.
  location: MESH_INTERNAL
  ports:
  - name: tcp-cockroachdb
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS
  addresses:
  - 240.0.0.12
  endpoints:
  - address: ${GKE_PROD_1_INGRESS}
    ports:
      tcp-cockroachdb: 15443 # Do not change this port value
      cockroachdb-http: 15443 # Do not change this port value

---
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb-public-${GKE_CRDB_NS}-global
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
  # must be of form name.namespace.global
  - cockroachdb-public.${GKE_CRDB_NS}.global
  # Treat remote cluster services as part of the service mesh
  # as all clusters in the service mesh share the same root of trust.
  location: MESH_INTERNAL
  ports:
  - name: cockroachdb-public-grpc
    number: 26257
    protocol: TCP
  - name: cockroachdb-public-http
    number: 8080
    protocol: http
  resolution: DNS
  addresses:
  - 240.0.0.13
  endpoints:
  - address: ${GKE_PROD_1_INGRESS}
    ports:
      cockroachdb-public-grpc: 15443 # Do not change this port value
      cockroachdb-public-http: 15443 # Do not change this port value
EOF

cat <<EOF > ${HOME}/crdb/serviceentry--${GKE_CRDB_NS}-for-${EKS_CRDB_NS}-global.yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb0-${EKS_CRDB_NS}-global
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
  # must be of form name.namespace.global
  - cockroachdb-0.cockroachdb.${EKS_CRDB_NS}.global
  # Treat remote cluster services as part of the service mesh
  # as all clusters in the service mesh share the same root of trust.
  location: MESH_INTERNAL
  ports:
  - name: tcp-cockroachdb
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS
  addresses:
  - 240.0.0.20
  endpoints:
  - address: ${EKS_PROD_1_INGRESS}
    ports:
      tcp-cockroachdb: 15443 # Do not change this port value
      cockroachdb-http: 15443 # Do not change this port value

---

apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb1-${EKS_CRDB_NS}-global
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
  # must be of form name.namespace.global
  - cockroachdb-1.cockroachdb.${EKS_CRDB_NS}.global
  # Treat remote cluster services as part of the service mesh
  # as all clusters in the service mesh share the same root of trust.
  location: MESH_INTERNAL
  ports:
  - name: tcp-cockroachdb
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS
  addresses:
  - 240.0.0.22
  endpoints:
  - address: ${EKS_PROD_1_INGRESS}
    ports:
      tcp-cockroachdb: 15443 # Do not change this port value
      cockroachdb-http: 15443 # Do not change this port value

---
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb2-${EKS_CRDB_NS}-global
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
  # must be of form name.namespace.global
  - cockroachdb-2.cockroachdb.${EKS_CRDB_NS}.global
  # Treat remote cluster services as part of the service mesh
  # as all clusters in the service mesh share the same root of trust.
  location: MESH_INTERNAL
  ports:
  - name: tcp-cockroachdb
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS
  addresses:
  - 240.0.0.23
  endpoints:
  - address: ${EKS_PROD_1_INGRESS}
    ports:
      tcp-cockroachdb: 15443 # Do not change this port value
      cockroachdb-http: 15443 # Do not change this port value

---
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb-public-${EKS_CRDB_NS}-global
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
  # must be of form name.namespace.global
  - cockroachdb-public.${EKS_CRDB_NS}.global
  # Treat remote cluster services as part of the service mesh
  # as all clusters in the service mesh share the same root of trust.
  location: MESH_INTERNAL
  ports:
  - name: cockroachdb-public-grpc
    number: 26257
    protocol: TCP
  - name: cockroachdb-public-http
    number: 8080
    protocol: http
  resolution: DNS
  addresses:
  - 240.0.0.21
  endpoints:
  - address: ${EKS_PROD_1_INGRESS}
    ports:
      cockroachdb-public-grpc: 15443 # Do not change this port value
      cockroachdb-public-http: 15443 # Do not change this port value
EOF

kubectl apply -f serviceentry--${EKS_CRDB_NS}-for-${GKE_CRDB_NS}-global.yaml -n ${EKS_CRDB_NS} --context=${EKS_PROD_1}
kubectl apply -f serviceentry--${GKE_CRDB_NS}-for-${EKS_CRDB_NS}-global.yaml -n ${GKE_CRDB_NS} --context=${GKE_PROD_1}
```

# Apply no-global service entries

```
cat <<EOF > ${HOME}/crdb/serviceentry--${EKS_CRDB_NS}-for-${GKE_CRDB_NS}-no-global.yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb0-${GKE_CRDB_NS}
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
  - cockroachdb-0.cockroachdb.${GKE_CRDB_NS}
  location: MESH_INTERNAL
  ports:
  - name: cockroachdb-grpc
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS

---
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb1-${GKE_CRDB_NS}
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
  - cockroachdb-1.cockroachdb.${GKE_CRDB_NS}
  location: MESH_INTERNAL
  ports:
  - name: cockroachdb-grpc
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS

---

apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb2-${GKE_CRDB_NS}
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
  - cockroachdb-2.cockroachdb.${GKE_CRDB_NS}
  location: MESH_INTERNAL
  ports:
  - name: cockroachdb-grpc
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS

---

apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb-public-${GKE_CRDB_NS}
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
  - cockroachdb-public.${GKE_CRDB_NS}
  location: MESH_INTERNAL
  ports:
  - name: cockroachdb-grpc
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS
EOF

cat <<EOF > ${HOME}/crdb/serviceentry--${GKE_CRDB_NS}-for-${EKS_CRDB_NS}-no-global.yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb0-${EKS_CRDB_NS}
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
  - cockroachdb-0.cockroachdb.${EKS_CRDB_NS}
  location: MESH_INTERNAL
  ports:
  - name: cockroachdb-grpc
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS

---
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb1-${EKS_CRDB_NS}
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
  - cockroachdb-1.cockroachdb.${EKS_CRDB_NS}
  location: MESH_INTERNAL
  ports:
  - name: cockroachdb-grpc
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS

---

apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb2-${EKS_CRDB_NS}
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
  - cockroachdb-2.cockroachdb.${EKS_CRDB_NS}
  location: MESH_INTERNAL
  ports:
  - name: cockroachdb-grpc
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS

---

apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: cockroachdb-public-${EKS_CRDB_NS}
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
  - cockroachdb-public.${EKS_CRDB_NS}
  location: MESH_INTERNAL
  ports:
  - name: cockroachdb-grpc
    number: 26257
    protocol: TCP
  - name: cockroachdb-http
    number: 8080
    protocol: http
  resolution: DNS
EOF

kubectl apply -f serviceentry--${EKS_CRDB_NS}-for-${GKE_CRDB_NS}-no-global.yaml --context=${EKS_PROD_1}
kubectl apply -f serviceentry--${GKE_CRDB_NS}-for-${EKS_CRDB_NS}-no-global.yaml --context=${GKE_PROD_1}
```

# Apply virtual service

```
cat <<EOF > ${HOME}/crdb/virtualservice--${EKS_CRDB_NS}.yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: cockroachdb-0.cockroachdb.${GKE_CRDB_NS}
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
  - cockroachdb-0.cockroachdb.${GKE_CRDB_NS}
  http:
  - route:
    - destination:
        host: cockroachdb-0.cockroachdb.${GKE_CRDB_NS}.global
    rewrite:
      authority: cockroachdb-0.cockroachdb.${GKE_CRDB_NS}.global
---

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: cockroachdb-1.cockroachdb.${GKE_CRDB_NS}
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
  - cockroachdb-1.cockroachdb.${GKE_CRDB_NS}
  http:
  - route:
    - destination:
        host: cockroachdb-1.cockroachdb.${GKE_CRDB_NS}.global
    rewrite:
      authority: cockroachdb-1.cockroachdb.${GKE_CRDB_NS}.global
---

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: cockroachdb-2.cockroachdb.${GKE_CRDB_NS}
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
  - cockroachdb-2.cockroachdb.${GKE_CRDB_NS}
  http:
  - route:
    - destination:
        host: cockroachdb-2.cockroachdb.${GKE_CRDB_NS}.global
    rewrite:
      authority: cockroachdb-2.cockroachdb.${GKE_CRDB_NS}.global
---

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: cockroachdb-public.${GKE_CRDB_NS}
  namespace: ${EKS_CRDB_NS}
spec:
  hosts:
  - cockroachdb-public.${GKE_CRDB_NS}
  http:
  - route:
    - destination:
        host: cockroachdb-public.${GKE_CRDB_NS}.global
    rewrite:
      authority: cockroachdb-public.${GKE_CRDB_NS}.global
EOF

cat <<EOF > ${HOME}/crdb/virtualservice--${GKE_CRDB_NS}.yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: cockroachdb-0.cockroachdb.${EKS_CRDB_NS}
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
  - cockroachdb-0.cockroachdb.${EKS_CRDB_NS}
  http:
  - route:
    - destination:
        host: cockroachdb-0.cockroachdb.${EKS_CRDB_NS}.global
    rewrite:
      authority: cockroachdb-0.cockroachdb.${EKS_CRDB_NS}.global
---

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: cockroachdb-1.cockroachdb.${EKS_CRDB_NS}
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
  - cockroachdb-1.cockroachdb.${EKS_CRDB_NS}
  http:
  - route:
    - destination:
        host: cockroachdb-1.cockroachdb.${EKS_CRDB_NS}.global
    rewrite:
      authority: cockroachdb-1.cockroachdb.${EKS_CRDB_NS}.global
---

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: cockroachdb-2.cockroachdb.${EKS_CRDB_NS}
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
  - cockroachdb-2.cockroachdb.${EKS_CRDB_NS}
  http:
  - route:
    - destination:
        host: cockroachdb-2.cockroachdb.${EKS_CRDB_NS}.global
    rewrite:
      authority: cockroachdb-2.cockroachdb.${EKS_CRDB_NS}.global
---

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: cockroachdb-public.${EKS_CRDB_NS}
  namespace: ${GKE_CRDB_NS}
spec:
  hosts:
  - cockroachdb-public.${EKS_CRDB_NS}
  http:
  - route:
    - destination:
        host: cockroachdb-public.${EKS_CRDB_NS}.global
    rewrite:
      authority: cockroachdb-public.${EKS_CRDB_NS}.global
EOF

kubectl apply -f virtualservice--${EKS_CRDB_NS}.yaml --context=${EKS_PROD_1}
kubectl apply -f  virtualservice--${GKE_CRDB_NS}.yaml --context=${GKE_PROD_1}
```

## Create statefulset manifests

```
JOINSTR="cockroachdb-0.cockroachdb.${EKS_CRDB_NS},cockroachdb-1.cockroachdb.${EKS_CRDB_NS},cockroachdb-2.cockroachdb.${EKS_CRDB_NS},cockroachdb-0.cockroachdb.${GKE_CRDB_NS},cockroachdb-1.cockroachdb.${GKE_CRDB_NS},cockroachdb-2.cockroachdb.${GKE_CRDB_NS}"

sed 's/JOINLIST/'"${JOINSTR}"'/g;s/LOCALITYLIST/zone='"${EKS_CRDB_NS}"'/g' cockroachdb-statefulset-secure.yaml > cockroachdb-statefulset-secure-${EKS_CRDB_NS}.yaml

sed 's/JOINLIST/'"${JOINSTR}"'/g;s/LOCALITYLIST/zone='"${GKE_CRDB_NS}"'/g' cockroachdb-statefulset-secure.yaml > cockroachdb-statefulset-secure-${GKE_CRDB_NS}.yaml

sed -i s~"hostname -f"~"hostname -f |sed 's/.svc.cluster.local//g'"~g cockroachdb-statefulset-secure-${EKS_CRDB_NS}.yaml
```

> NOTE: Remember to the change the service labels in the yaml according to [this article](https://medium.com/faun/connecting-multiple-kubernetes-clusters-on-vsphere-with-istio-service-mesh-a017a0dd9b2e)
> NOTE: Add the following ENVAR to the yamls `COCKROACH_SKIP_KEY_PERMISSION_CHECK=true`


### Apply 

```
kubectl apply -f cockroachdb-statefulset-secure-${EKS_CRDB_NS}.yaml -n ${EKS_CRDB_NS} --context=${EKS_PROD_1}
kubectl apply -f cockroachdb-statefulset-secure-${GKE_CRDB_NS}.yaml -n ${GKE_CRDB_NS} --context=${GKE_PROD_1}
```

Disable `istio-injection` by adding the following:
```
spec:
  template:
    metadata:
      annotations:
        sidecar.istio.io/inject: "false"
```

Apply

```
kubectl apply -f cluster-init-secure.yaml -n ${EKS_CRDB_NS} --context=${EKS_PROD_1}
```

### Client for testing

```
kubectl create -f client-secure.yaml --context ${GKE_PROD_1} -n ${GKE_CRDB_NS}

kubectl exec -it cockroachdb-client-secure --context ${GKE_PROD_1} --namespace ${GKE_CRDB_NS} -- ./cockroach sql --certs-dir=/cockroach/certs --host=cockroachdb-public

kubectl port-forward cockroachdb-0 8080:8080 --context ${GKE_PROD_1} --namespace ${GKE_CRDB_NS}
```
