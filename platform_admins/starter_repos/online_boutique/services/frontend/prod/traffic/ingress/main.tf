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

# Cloud endpoints for DNS
module "online-boutique-cloud-ep-dns" {
  source      = "terraform-google-modules/endpoints-dns/google"
  project     = var.project_id
  name        = "obfrontend"
  external_ip = data.terraform_remote_state.prod_gcp_gclb.outputs.prod-ingress-lb-ip-address
}

# Managed certificate
resource "google_compute_managed_ssl_certificate" "online-boutique-ingress" {
  provider = google-beta
  project  = var.project_id

  name = "online-boutique-ingress-ssl-certificate"

  managed {
    domains = ["${module.online-boutique-cloud-ep-dns.endpoint}."]
  }
}

# Target HTTPS proxy
resource "google_compute_target_https_proxy" "online-boutique-ingress" {
  project          = var.project_id
  name             = "${var.env}-istio-ingressgateway-https-proxy"
  url_map          = data.terraform_remote_state.prod_gcp_gclb.outputs.prod-ingress-lb-url-map
  ssl_certificates = [google_compute_managed_ssl_certificate.online-boutique-ingress.self_link]
}

# Forwarding rule - HTTPS
resource "google_compute_global_forwarding_rule" "ingress" {
  project    = var.project_id

  name       = "${var.env}-istio-ingressgateway-fwd-rule-https"
  ip_address = data.terraform_remote_state.prod_gcp_gclb.outputs.prod-ingress-lb-ip-address
  target     = google_compute_target_https_proxy.online-boutique-ingress.self_link
  port_range = "443"
}
