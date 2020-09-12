# Terraform GCP VPC Module
This module builds a GCP VPC. This module is built on top of the official GCP VPC module which can be found [here](https://github.com/terraform-google-modules/terraform-google-network). 

## Compatibility
This module is meant for use with Terraform 0.12.

## Usage
Following example is taken from the [/infrastructure/prod/gcp/vpc](/infrastructure/prod/gcp/vpc) folder.
```bash
module "prod_gcp_vpc_01" {
    source = "../../../../platform_admins/shared_terraform_modules/gcp/vpc/"
    project_id   = var.project_id
    network_name = var.network_name
    subnets = var.subnets
```

## Inputs
| **Name** | **Description** | **Type** | **Default** | **Required** |
| ---      | ---             | ---      | ---         | ---          |
| `project_id` | Project ID | string | "" | yes |
| `network_name` | Name of the VPC | string | "" | yes |
| `subnets` | Names, regions and IP addresses of all subnets in the VPC | list(object) | "" | yes |

### Subnets
The `subnets` input is loosely based on the [GCP VPC Subnetwork API Spec](https://cloud.google.com/compute/docs/reference/rest/v1/subnetworks).

```bash
variable "subnets" {
    type = list(object({
        subnet_name = string
        subnet_ip = string
        subnet_region = string
        secondary_ranges = list(object({
            range_name = string
            ip_cidr_range = string
        }))
    }))
}
```

Example of the `subnets` variable with a single subnet and 5 secondary IP address ranges.
```bash
variable "subnets" {
    default = [
        {
            subnet_name = "prod-gcp-vpc-01-us-west2-subnet-01"
            subnet_ip = "10.4.0.0/22"
            subnet_region = "us-west2"
            secondary_ranges = [
                {
                    range_name = "prod-gcp-vpc-01-us-west2-subnet-01-secondary-range-01-pod"
                    ip_cidr_range = "10.0.0.0/14"
                },
                {
                    range_name = "prod-gcp-vpc-01-us-west2-subnet-01-secondary-range-02-svc"
                    ip_cidr_range = "10.5.0.0/20"
                },
                {
                    range_name = "prod-gcp-vpc-01-us-west2-subnet-01-secondary-range-03-svc"
                    ip_cidr_range = "10.5.16.0/20"
                },
                {
                    range_name = "prod-gcp-vpc-01-us-west2-subnet-01-secondary-range-04-svc"
                    ip_cidr_range = "10.5.32.0/20"
                },
                {
                    range_name = "prod-gcp-vpc-01-us-west2-subnet-01-secondary-range-05-svc"
                    ip_cidr_range = "10.5.48.0/20"
                },
            ]
        },
    ]
}
```

## Outputs
| **Name** | **Description** | 
| ---      | ---             | 
| `network` | VPC network link | 
| `project_id` | Project ID |
| `network_name` | VPC network name |
| `subnets` | A map with keys of form subnet_region/subnet_name and values being the outputs of the google_compute_subnetwork resources used to create corresponding subnets. |
| `subnets_ips` | The IPs and CIDRs of the subnets being created |
| `subnets_names` | The names of the subnets being created |
| `subnets_regions` | The region where the subnets will be created |
| `subnets_secondary_ranges` | The secondary ranges associated with these subnets |

## Requirements
### Software
- [Terraform](https://www.terraform.io/downloads.html) ~> 0.12.6
- [Terraform Provider for GCP](https://github.com/terraform-providers/terraform-provider-google) ~> 2.19
- [Terraform Provider for GCP Beta](https://github.com/terraform-providers/terraform-provider-google-beta) ~>
  2.19
- [gcloud](https://cloud.google.com/sdk/gcloud/) >243.0.0

### Configure a Service Account
In order to execute this module you must have a Service Account with the following roles:

- roles/compute.networkAdmin on the organization or folder

### Enable API's
In order to operate with the Service Account you must activate the following API on the project where the Service Account was created:

- Compute Engine API - compute.googleapis.com