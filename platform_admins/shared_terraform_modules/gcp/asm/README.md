# Terraform Anthos Service Mesh (ASM) Module
This module creates a service mesh [(ASM)](https://cloud.google.com/anthos/service-mesh) between GKE and EKE Kubernetes clusters deployedf in this workshop. 

This module is intended to be used in lab/workshop environments only. 

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| asm\_version |  | string | n/a | yes |
| eks\_eip\_list |  | string | n/a | yes |
| eks\_ingress\_ip\_list |  | string | n/a | yes |
| eks\_list |  | string | n/a | yes |
| gke\_list |  | string | n/a | yes |
| gke\_location\_list |  | string | n/a | yes |
| gke\_net |  | string | n/a | yes |
| project\_id |  | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->