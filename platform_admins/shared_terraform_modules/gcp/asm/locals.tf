/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  header                = <<EOT
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: asm-multicloud
  addonComponents:
    kiali:
      enabled: true
    grafana:
      enabled: true
    istiocoredns:
      enabled: true
EOT
  eks_component         = <<EOT
  components:
    ingressGateways:
    - name: istio-ingressgateway
      enabled: true
      k8s:
        service_annotations:
          service.beta.kubernetes.io/aws-load-balancer-type: nlb
          service.beta.kubernetes.io/aws-load-balancer-eip-allocations: "EIP1,EIP2"
EOT
  gke_component         = <<EOT
  components:
    ingressGateways:
    - name: istio-ingressgateway
      enabled: true
      k8s:
        service_annotations:
          cloud.google.com/neg: '{"exposed_ports": {"80":{}}}'
          anthos.cft.dev/autoneg: '{"name":"ENV-istio-ingressgateway-backend-svc", "max_rate_per_endpoint":100}'
EOT
  eks_meshconfig        = <<EOT
  meshConfig:
    defaultConfig:
      proxyMetadata:
        ISTIO_METAJSON_PLATFORM_METADATA: |-
          {\"PLATFORM_METADATA\":{\"gcp_gke_cluster_name\":\"EKS\",\"gcp_project\":\"PROJECT_ID\",\"gcp_location\":\"CLUSTER_LOCATION\"}}
EOT
  gcp_values            = <<EOT
  values:
    telemetry:
      enabled: true
      v2:
        enabled: true
        stackdriver:
          enabled: true  # This enables Stackdriver metrics
    kiali:
      createDemoSecret: true
    global:
      podDNSSearchNamespaces:
        - global
      mtls:
        enabled: true
      multiCluster:
        clusterName: GKE
        enabled: true
      network: GCP_NET
      meshNetworks:
        GCP_NET:
          endpoints:
          # Always use Kubernetes as the registry name for the main cluster in the mesh network configuration
EOT
  eks_values            = <<EOT
  values:
    telemetry:
      enabled: true
      v2:
        enabled: true
        stackdriver:
          enabled: true  # This enables Stackdriver metrics       
    kiali:
      createDemoSecret: true
    global:
      podDNSSearchNamespaces:
        - global
      mtls:
        enabled: true
      multiCluster:
        clusterName: EKS
        enabled: true
      network: EKS-net
      meshNetworks:
        GCP_NET:
          endpoints:
          # Always use Kubernetes as the registry name for the main cluster in the mesh network configuration
EOT
  gcp_registry          = <<EOT
          - fromRegistry: GKE
EOT
  gateways_registry     = <<EOT
          gateways:
          - registry_service_name: istio-ingressgateway.istio-system.svc.cluster.local
            port: 443
EOT
  eks_self_network      = <<EOT
        EKS-net:
          endpoints:
          - fromRegistry: EKS
          gateways:
          - registry_service_name: istio-ingressgateway.istio-system.svc.cluster.local
            port: 443
EOT
  eks_remote_network    = <<EOT
        EKS-net:
          endpoints:
          - fromRegistry: EKS
          gateways:
          - address: ISTIOINGRESS_IP
            port: 443
EOT
  cluster_aware_gateway = <<EOT
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: cluster-aware-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: tls
      protocol: TLS
    tls:
      mode: AUTO_PASSTHROUGH
    hosts:
    - "*.local"
EOT
  gke_kubedns_configmap = <<EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
data:
  stubDomains: |
    {"global": ["COREDNS_IP"]}
EOT
  eks_coredns_configmap = <<EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           upstream
           fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
    global:53 {
        errors
        cache 30
        forward . COREDNS_IP:53
    }
EOT
}
