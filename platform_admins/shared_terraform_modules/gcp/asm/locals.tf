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
  revision: ASM_REV_LABEL
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
  gke_meshconfig        = <<EOT
  meshConfig:
    accessLogFile: "/dev/stdout"
    defaultConfig:
      proxyMetadata:
        # istiocoredns deprecation
        ISTIO_META_DNS_CAPTURE: "true"
        ISTIO_META_PROXY_XDS_VIA_AGENT: "true"
EOT
  eks_meshconfig        = <<EOT
  meshConfig:
    accessLogFile: "/dev/stdout"
    defaultConfig:
      proxyMetadata:
        # istiocoredns deprecation
        ISTIO_META_DNS_CAPTURE: "true"
        ISTIO_META_PROXY_XDS_VIA_AGENT: "true"      
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
    global:
      podDNSSearchNamespaces:
        - global
      meshID: MESH_ID
      multiCluster:
        clusterName: GKE
      network: GCP_NET
EOT
  eks_values            = <<EOT
  values:
    telemetry:
      enabled: true
      v2:
        enabled: true
        stackdriver:
          enabled: true  # This enables Stackdriver metrics       
    global:
      podDNSSearchNamespaces:
        - global
      meshID: MESH_ID
      multiCluster:
        clusterName: EKS
      network: EKS-net
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
  cluster_network_gateway = <<EOT
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: cross-network-gateway
  namespace: istio-system
spec:
  selector:
    istio: eastwestgateway
  servers:
  - port:
      number: 15443
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
  istiod_service = <<EOT
apiVersion: v1
kind: Service
metadata:
  name: istiod
  namespace: istio-system
  labels:
    istio.io/rev: ASM_REV_LABEL
    app: istiod
    istio: pilot
    release: istio
spec:
  ports:
    - port: 15010
      name: grpc-xds # plaintext
      protocol: TCP
    - port: 15012
      name: https-dns # mTLS with k8s-signed cert
      protocol: TCP
    - port: 443
      name: https-webhook # validation and injection
      targetPort: 15017
      protocol: TCP
    - port: 15014
      name: http-monitoring # prometheus stats
      protocol: TCP
  selector:
    app: istiod
    istio.io/rev: ASM_REV_LABEL
EOT
}