output "ingress-lb-ip-address" {
  value = google_compute_global_address.ingress.address
}

output "ingress-lb-url-map" {
  value = google_compute_url_map.ingress.self_link
}
