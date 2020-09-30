## Objective

1. Add a new Google Kubernetes Engine (GKE) and an Amazon Elastic Kubernetes Service (EKS) cluster to multi-cloud environment

## Prerequisite

1. Initial workshop build completed successfully (using the `build.sh` script).
1. Familiarity with Terraform
1. Familiarity with this repository

## Adding a new cluster

Adding a new cluster requires additions in a few places, this lab provides guidance regarding required modifications.

In this lab, you add a GKE and an EKS cluster to the `stage` environment. After the initial build, `stage` environment contains one GKE and one EKS cluster. Upon completion of this lab you should:

1. Have two GKE clusters in the GCP VPC. GKE cluster is created in the same subnet as the other GKE cluster.
1. Have two EKS clusters in the AWS VPC. EKS cluster is created in the same subnet as the other EKS cluster. The new EKS cluster is registered to Anthos Hub.
1. ACM configured on the new GKE and EKS clusters pointing to the `anthos-config-management` repo in Gitlab.
1. ASM configured on the new GKE and EKS clusters and clusters added to the `stage` service mesh.

> Note: you can follow similar steps to add clusters to any environment.

In order to add a cluster to the `stage` environment, you need to edit the terraform files in the `infrastructure/stage/gcp/gke` (for a new GKE cluster) or the `infrastructure/stage/aws/eks` (for a new EKS cluster) folder.
Choose one of the two methods below:

- **Manually editing terraform files** - You can manually edit and configure the terraform files using either `vi` or `nano`.
  OR
- **Using pre-created terraform files** - There are pre-created terraform file templates in the appropriate folders with new cluster configurations added.

### Add a GKE cluster to `stage` environment

Choose one of the following two methods to add a GKE cluster to the `stage` environment.

<details>
<summary> <b> Manually editing terraform file </b> </summary><br/>

1. In Cloud Shell, navigate to the GKE folder for the `stage` environment.

```
cd $WORKDIR/anthos-multicloud-workshop/infrastructure/stage/gcp/gke/
```

1. Edit the `main.tf` file (using `vi` or `nano`) and add a module to add a new GKE cluster.

```terraform
# GKE Stage 2
module "gke_stage_2" {
  source             = "../../../../platform_admins/shared_terraform_modules/gcp/gke/"
  subnet             = data.terraform_remote_state.stage_gcp_vpc.outputs.subnets["${var.gke1_subnet_name}"]
  suffix             = var.gke2_suffix
  zone               = var.gke2_zone
  env                = var.env
  acm_ssh_auth_key   = data.terraform_remote_state.prod_gcp_ssh_key.outputs.private_key
  acm_sync_repo      = "git@gitlab.endpoints.${data.terraform_remote_state.stage_gcp_vpc.outputs.project_id}.cloud.goog:platform-admins/anthos-config-management.git"
  hub_sa_private_key = data.terraform_remote_state.prod_gcp_hub_gsa.outputs.private_key
}
```

> Note: In this lab, you use the same subnet as the other GKE cluster.

1. Edit the `output.tf` file and add the outputs for the new GKE cluster.

```terraform
output "gke_stage_2_name" { value = "${module.gke_stage_2.name}" }
output "gke_stage_2_location" { value = "${module.gke_stage_2.location}" }
output "gke_stage_2_endpoint" { value = "${module.gke_stage_2.endpoint}" }

# Add cluster name and cluster location to the gke_list and gke_location outputs as shown below
# This list is used to add clusters to the ASM service mesh
output "gke_list" { value = [
    "${module.gke_stage_1.name}",
    "${module.gke_stage_2.name}"]
    }
output "gke_location_list" { value = [
    "${module.gke_stage_1.location}",
    "${module.gke_stage_2.location}"]
    }
```

1. Edit the `gke_variables.tf` file and add the variables.

```terraform
# The gke_suffix needs to be different between clusters in the same environment
variable "gke2_suffix" {
  type    = number
  default = 2
}

# You can also change the zone
variable "gke2_zone" {
  type    = string
  default = "c"
}
```

The changes above will add a new GKE cluster to the `stage` environment, configure ACM and add it to the ASM `stage` service mesh.

</details>

<details>
<summary> <b> Using pre-created terraform files </b> </summary><br/>

1. In Cloud Shell, navigate to the GKE folder for the `stage` environment.

```bash
cd $WORKDIR/anthos-multicloud-workshop/infrastructure/stage/gcp/gke/
```

1. Copy the pre-created terraform config files. These files already have the module, variables and outputs for the new GKE cluster.

```bash
cp main-add-cluster.tf_tmpl main.tf
cp outputs-add-cluster.tf_tmpl outputs.tf
cp ../../variables/gke_variables-add-cluster.tf_tmpl ../../variables/gke_variables.tf
```

</details>

### Add an EKS cluster to the `stage` environment

Choose one of the following two methods to add an EKS cluster to the `stage` environment.

<details>
<summary> <b> Manually editing terraform file </b> </summary><br/>

1. In Cloud Shell, navigate to the EKS folder for the `stage` environment.

```bash
cd $WORKDIR/anthos-multicloud-workshop/infrastructure/stage/aws/eks/
```

1. Edit the `main.tf` file (using `vi` or `nano`) and add a module to add a new EKS cluster.

```terraform
# EKS Stage 2
module "eks-stage-2" {
  source           = "../../../../platform_admins/shared_terraform_modules/aws/eks/"
  eks_cluster_name = var.eks2_cluster_name
  vpc_id           = data.terraform_remote_state.stage_aws_vpc.outputs.id
  private_subnets  = data.terraform_remote_state.stage_aws_vpc.outputs.private_subnets
  project_id       = data.terraform_remote_state.stage_gcp_vpc.outputs.project_id
  env              = var.env
  repo_url         = "git@gitlab.endpoints.${data.terraform_remote_state.stage_gcp_vpc.outputs.project_id}.cloud.goog:platform-admins/anthos-config-management.git"
}
```

> Note: In this lab, you use the same subnet as the other EKS cluster.

1. Edit the `output.tf` file and add the outputs for the new EKS cluster.

```terraform
# Add cluster id and to the eks_list outputs as shown below
# This list is used to add clusters to the ASM service mesh
output "eks_list" {
  value = [
    "${module.eks-stage-1.cluster_id}",
    "${module.eks-stage-2.cluster_id}"
  ]
}

output "eks2_cluster_id" {
  description = "eks2 cluster name"
  value       = module.eks-stage-2.cluster_id
}

output "eks2_cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks-stage-2.cluster_endpoint
}

output "eks2_cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks-stage-2.cluster_security_group_id
}

output "eks2_kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks-stage-2.kubeconfig
}

output "eks2_config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks-stage-2.config_map_aws_auth
}
```

1. Edit the `eks_variables.tf` file and verify that the `eks2_cluster_name` variable is present.

```terraform
variable "eks2_cluster_name" { default = "eks-stage-us-east1ab-2" }
```

> Note: The `eks2_cluster_name` variable is preconfigured for this workshop. EKS cluster name is required as tags for the subnets the cluster is in. These tags allow EKS clusters to create networking resources for example NLBs and ELBs. Learn more at the official [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html#vpc-tagging).

The changes above will add a new EKS cluster to the `stage` environment, configure ACM and add it to the ASM `stage` service mesh.

</details>

<details>
<summary> <b> Using pre-created terraform files </b> </summary><br/>

1. In Cloud Shell, navigate to the EKS folder for the `stage` environment.

```bash
cd $WORKDIR/anthos-multicloud-workshop/infrastructure/stage/aws/eks/
```

1. Copy the pre-created terraform config files. These files already have the module, variables and outputs for the new EKS cluster.

```bash
cp main-add-cluster.tf_tmpl main.tf
cp outputs-add-cluster.tf_tmpl outputs.tf
cp ../../variables/eks_variables-add-cluster.tf_tmpl ../../variables/eks_variables.tf
```

</details>

## Rebuild to apply changes

1. Run `build.sh` per setup instructions

```
cd ${WORKDIR}/anthos-multicloud-workshop/
./build.sh
```

1. Navigate to the **Cloudbuild** page from Cloud Console left hand navbar and wait until the `stage` pipeline finishes successfully.

## Logging in to the EKS cluster

1. Login to the new EKS cluster in Cloud Console. Download the EKS token from the GCS bucket and login via the Kubbernetes admin page.

```bash
gsutil cp -r gs://$GOOGLE_PROJECT/kubeconfig ${WORKDIR}/.
echo -e "export EKS_STAGE_2=eks-stage-us-east1ab-2" >> ${WORKDIR}/vars.sh
source ${WORKDIR}/vars.sh
echo "*** $EKS_STAGE_2 Token ***\n"
cat ${WORKDIR}/kubeconfig/$EKS_STAGE_2-ksa-token.txt && echo -e "\n"
```

Output (do not copy)

```
*** eks-stage-us-east1ab-2 Token ***

eyJkhNY2x2MGNacVVFU0EifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZhK6QkIlMIsM13mbfhovGBDRjGPjTTT3QDPGAaCUBSWVi8ITl93i72gPP-nAcxmC-VoQ9E844XETnLMDUdkjeJWxu74hKaZD1chiy5cQ4atypTMg1c6OV5Xm5ZNzklDk-gzt6z_zJfgwvzDNnICEt4wSYAqkAR4IEyF3lTptrFT8ydZWK2pMkoy1WpFdSeA1lArFJUpwlasYnneaxIW_2GjPLW1RUcWhkS8eByYSCiZZs3AjGTCTeee1SdCsIP3SUd0OmbA1c__Y_t7W7DmHaX22mThS1hcE81eVSiF5EGCo9CZK5JvmGSl_NILjq1M3iw
```

Congratulations! you successfully added a GKE and an EKS cluster to the Anthos platform.

#### [Back to Labs](/README.md#labs)
