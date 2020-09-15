# ASM for GKE (Multi-cluster) module
Requires service account running it to have clusteradmin role to GKE clusters.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| clusters | Map cluster indices to list of clusters to add ASM to. | object | n/a | yes |
| project\_id | The project in which the resource belongs. | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->