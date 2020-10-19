output "stage-ingress-lb-ip-address" {
  value = module.stage-istio-ingressgateway-gclb.ingress-lb-ip-address
}

output "stage-ingress-lb-url-map" {
  value = module.stage-istio-ingressgateway-gclb.ingress-lb-url-map
}
