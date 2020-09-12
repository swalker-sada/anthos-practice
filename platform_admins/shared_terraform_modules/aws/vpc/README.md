<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| azs |  | string | n/a | yes |
| cidr |  | string | n/a | yes |
| eip\_count |  | string | n/a | yes |
| eks1\_cluster\_name |  | string | n/a | yes |
| eks2\_cluster\_name |  | string | n/a | yes |
| name |  | string | n/a | yes |
| private\_subnets | EKS requires minimum two AZs and 2 subnetshttps://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html | string | n/a | yes |
| public\_subnets |  | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| eip\_ids |  |
| eip\_public\_ips |  |
| id |  |
| name |  |
| private\_subnets |  |
| public\_subnets |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->