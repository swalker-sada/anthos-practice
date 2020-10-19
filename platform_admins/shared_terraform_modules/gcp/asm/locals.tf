locals {
  header                = <<EOT
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  addonComponents:
    kiali:
      enabled: true
    grafana:
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
      mtls:
        enabled: true
      multiCluster:
        clusterName: GKE
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
      mtls:
        enabled: true
      multiCluster:
        clusterName: EKS
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
}
