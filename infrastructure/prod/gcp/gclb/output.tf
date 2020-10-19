output "prod-ingress-lb-ip-address" {
  value = module.prod-istio-ingressgateway-gclb.ingress-lb-ip-address
}

output "prod-ingress-lb-url-map" {
  value = module.prod-istio-ingressgateway-gclb.ingress-lb-url-map
}
