# Terraform AWS EKS Module
This module creates an EKS cluster in AWS and deploys Anthos Config Management [(ACM)](https://cloud.google.com/anthos/config-management) with [Policy Controller](https://cloud.google.com/anthos-config-management/docs/how-to/installing-policy-controller) enabled on the cluster. 

This module is intended to be used in lab/workshop environments only. The module locks certain parameters that are not exposed to the user as variables, for example, number and type of nodes. The following opinions are baked into this module.
  - Kubernetes version is set to `1.17` release channel. 
  - EKS cluster is created in a single zone.
  - EKS cluster name is autogenerated based on environment, region, zone and a suffix (see inputs for details)
  - The Pod and Service IP ranges are inferred from the `subnet_name` and the `suffix` input values (see input for details).
  - A single node-pool is created with `3` nodes of `t3.2xlarge` type.
  - A `git-creds` secret is created from the SSH private key in the `config-management-system` namespace for ACM. More details can be found [here](https://cloud.google.com/anthos-config-management/docs/how-to/installing#git-creds-secret).
  - The following labels are added to the cluster:
  ```
    "infra"     : "aws"
    "environ"   : "${ENV}"
    "mesh_id"   : "proj-${ENV}-${PROJECT_NUMBER}"
  ```

### Pod and Service IP ranges
The Pod and Service IP ranges are inferred from the `subnet` variable. A `subnet` object is provided as an input variable. The `subnet` object contains a list of `secondary_ranges`. The first object is the `secondary_ranges` list is always used as the Pod IP CIDR range. All GKE clusters in the same subnet share the same Pod IP CIDR range. The Service IP CIDR range is inferred from the `suffix` variable. The `suffix` variable refers to the index in the `secondary_ranges` list to be used. In a subnet,
  - `suffix` numbers must be different between clusters.  
  - `suffix` cannot be larger than the length of the `secondary_ranges` list.

### Cluster name
EKS cluster names are autogenerated based on environment, region, zone and a suffix. It takes the following form.
```bash
"eks-${local.env}-${local.region}${local.zone}-${local.suffix}"
```

## Compatibility
This module is meant for use with Terraform 0.12.

## Usage
Following example is taken from the [/infrastructure/prod/aws/eks](/infrastructure/prod/aws/eks) folder.
```bash
module "eks-prod-1" {
  source           = "../../../../platform_admins/shared_terraform_modules/aws/eks/"
  eks_cluster_name = var.eks1_cluster_name
  vpc_id           = data.terraform_remote_state.prod_aws_vpc.outputs.id
  private_subnets  = data.terraform_remote_state.prod_aws_vpc.outputs.private_subnets
  project_id       = data.terraform_remote_state.prod_gcp_vpc.outputs.project_id
  env              = var.env
  repo_url         = "git@gitlab.endpoints.${data.terraform_remote_state.prod_gcp_vpc.outputs.project_id}.cloud.goog:platform-admins/anthos-config-management.git"
}
```

## Inputs
| **Name** | **Description** | **Type** | **Default** | **Required** |
| ---      | ---             | ---      | ---         | ---          |
| `eks_cluster_name` | EKS Cluster Name | string | "" | yes |
| `vpc_id` | AWS VPC ID | string | "" | yes |
| `private_subnets` | Private Subnet | string | "" | yes |
| `project_id` | Project ID | string | "" | yes |
| `env` | Environment (dev, stage or prod) | string | "" | yes |
| `repo_url` | SSH link of the `anthos-config-management` repo | string | "" | yes |

## Outputs
| **Name** | **Description** |
| --- | --- |
| name | Cluster name |
| endpoint | Cluster API endpoint |
| security_group_id | Security group ids attached to the cluster control plane |
| kubectl_config | kubectl config as generated by the module |
| config_map_aws_auth | A kubernetes configuration to authenticate to this EKS cluster |

## Requirements
### Software Dependencies
#### Kubectl
- [kubectl](https://github.com/kubernetes/kubernetes/releases) 1.9.x
#### Terraform and Plugins
- [Terraform](https://www.terraform.io/downloads.html) 0.12
- [Terraform Provider for GCP][terraform-provider-google] v2.9

### IAM Permissions and Credentials
[Minimum IAM permissions needed to setup EKS Cluster](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md)

- Set GCP and AWS credentials. Get the value of the GCP Project ID, AWS Access Key ID and AWS Secret Access
  Key from Qwiklabs and replace the values with your values below.

```
export GOOGLE_PROJECT=[GCP PROJECT ID]
export AWS_ACCESS_KEY_ID=[AWS_ACCESS_KEY_ID]
export AWS_SECRET_ACCESS_KEY=[AWS_SECRET_ACCESS_KEY]
```
