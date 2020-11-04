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

# Static IP for ingress
resource "google_compute_global_address" "ingress" {
  project = var.project_id
  name    = "${var.env}-istio-ingressgateway-address"
}

# Firewall rule
resource "google_compute_firewall" "ingress-lb" {
  name    = "${var.env}-istio-ingressgateway-lb"
  project = var.project_id
  network = var.network_name

  allow {
    protocol = "tcp"
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
}

# Health check
resource "google_compute_health_check" "ingress" {
  project            = var.project_id
  name               = "${var.env}-istio-ingressgateway-healthcheck"
  check_interval_sec = 10

  tcp_health_check {
    port = "8080"
  }
}

# BackendService
resource "google_compute_backend_service" "ingress" {
  project       = var.project_id
  name          = "${var.env}-istio-ingressgateway-backend-svc"
  health_checks = [google_compute_health_check.ingress.self_link]
  protocol      = "HTTP"
}

# URL map - HTTPS
resource "google_compute_url_map" "ingress" {
  project         = var.project_id
  name            = "${var.env}-istio-ingressgateway-url-map"
  default_service = google_compute_backend_service.ingress.self_link
}

# Target HTTP proxy
resource "google_compute_target_http_proxy" "ingress" {
  project = var.project_id
  name    = "${var.env}-istio-ingressgateway-http-proxxy"
  url_map = google_compute_url_map.ingress.self_link
}

# Target HTTPS proxy
# resource "google_compute_target_https_proxy" "ingress" {
#   project          = var.project_id
#   name             = "${var.env}-istio-ingressgateway-https-proxy"
#   url_map          = google_compute_url_map.ingress.self_link
#   # ssl_certificates = [google_compute_managed_ssl_certificate.ingress.self_link]
# }

# Forwarding rule - HTTP
resource "google_compute_global_forwarding_rule" "ingress-http" {
  project    = var.project_id

  name       = "${var.env}-istio-ingressgateway-fwd-rule-http"
  ip_address = google_compute_global_address.ingress.address
  target     = google_compute_target_http_proxy.ingress.self_link
  port_range = "80"
}


# Forwarding rule - HTTPS
# resource "google_compute_global_forwarding_rule" "ingress" {
#   project    = var.project_id

#   name       = "${var.env}-istio-ingressgateway-fwd-rule-https"
#   ip_address = google_compute_global_address.ingress.address
#   target     = google_compute_target_https_proxy.ingress.self_link
#   port_range = "443"
# }
