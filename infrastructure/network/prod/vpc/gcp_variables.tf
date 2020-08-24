# vpc and project
variable "project_id" {}
variable "vpc_name" { default = "vpc01" }

# subnet_01
variable "subnet_01_name" { default = "subnet-01" }
variable "subnet_01_ip" { default = "10.4.0.0/22" }
variable "subnet_01_region" { default = "us-west2" }
variable "subnet_01_secondary_svc_1_name" { default = "subnet-01-svc-01" }
variable "subnet_01_secondary_svc_1_range" { default = "10.5.0.0/20" }
variable "subnet_01_secondary_svc_2_name" { default = "subnet-01-svc-02" }
variable "subnet_01_secondary_svc_2_range" { default = "10.5.16.0/20" }
variable "subnet_01_secondary_pod_name" { default = "subnet-01-pod-01" }
variable "subnet_01_secondary_pod_range" { default = "10.0.0.0/14" }

# subnet_02
variable "subnet_02_name" { default = "subnet-02" }
variable "subnet_02_ip" { default = "10.12.0.0/22" }
variable "subnet_02_region" { default = "us-central1" }
variable "subnet_02_secondary_svc_1_name" { default = "subnet-02-svc-01" }
variable "subnet_02_secondary_svc_1_range" { default = "10.13.0.0/20" }
variable "subnet_02_secondary_svc_2_name" { default = "subnet-02-svc-02" }
variable "subnet_02_secondary_svc_2_range" { default = "10.13.16.0/20" }
variable "subnet_02_secondary_pod_name" { default = "subnet-02-pod-01" }
variable "subnet_02_secondary_pod_range" { default = "10.8.0.0/14" }
