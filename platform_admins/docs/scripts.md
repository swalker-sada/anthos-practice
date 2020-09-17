# Platform Administration Scripts

## bootstrap.sh

The `bootstrap.sh` script, in tandem with some helper scripts, accomplishes the following:

- Installs the required tools in Cloud Shell
- Creates an `infrastructure` repository in Cloud Source Repository(CSR) that contains the code to deploy the Anthos resources in GCP and AWS.
- Creates a **Cloud Build** trigger for a push to the `infrastructure` repository's `main` branch.
- Commits the code to the `infrastructure` repository to trigger the build.

### Flow

1. Verify the `OSTYPE` environment variable is `linux-gnu`.
1. Create the logging directory, variables file(`vars.sh`), and a log file(`logs/bootstrap-$(date +%s).log`) for the script.
1. Source the [`functions.sh`](#functionssh) helper script.
1. Set the `ASM_VERSION` based on the value in `vars.sh` or defaults to`1.6.8-asm.9`.
1. Invoke the [`tools.sh`](#toolssh) script.
1. Verify the `GOOGLE_PROJECT`, `AWS_ACCESS_KEY_ID`, and `AWS_SECRET_ACCESS_KEY` environment variables are set.
1. Sources the `vars.sh` file.
1. Set the GCP project to `GOOGLE_PROJECT`.
1. Enable the required APIs:
   - `cloudresourcemanager.googleapis.com`
   - `cloudbilling.googleapis.com`
   - `iam.googleapis.com`
   - `compute.googleapis.com`
   - `container.googleapis.com`
   - `serviceusage.googleapis.com`
   - `sourcerepo.googleapis.com`
   - `monitoring.googleapis.com`
   - `logging.googleapis.com`
   - `cloudtrace.googleapis.com`
   - `meshca.googleapis.com`
   - `meshtelemetry.googleapis.com`
   - `meshconfig.googleapis.com`
   - `gkeconnect.googleapis.com`
   - `gkehub.googleapis.com`
   - `cloudbuild.googleapis.com`
   - `servicemanagement.googleapis.com`
   - `secretmanager.googleapis.com`
   - `anthos.googleapis.com`
1. Create a service account(`<project number>@cloudbuild.gserviceaccount.com`) for Cloud Build.
   - Assign the service account `role/owner` for the project.
   - Assign the service account `roles/container.admin` for the project.
1. Create a Google Storage bucket(`${GOOGLE_PROJECT}`) to store the [Terraform state file](https://www.terraform.io/docs/state/index.html).
1. Enable versioning on the bucket
1. Create a Cloud Source Repository named `infrastructure/`.
1. Create a Cloud Build push trigger on the `infrastructure` repository's `main` branch using the [`platform_admins/builds/cloudbuild.yaml`](../builds/cloudbuild.yaml) configuration file.
1. Create a global Cloud KMS keyring named `aws-creds` to store the AWS credentials.
1. Create a global key named `aws-access-id` in the `aws-creds` keyring to store the AWS Access Key ID.
1. Create a global key named `aws-secret-access-key` in the `aws-creds` keyring to store the AWS Secret Access Key.
1. Generate the `cloudbuild-prod.yaml` configuration file using the [`cloudbuild-prod.yaml_tmpl`](../builds/cloudbuild-prod.yaml_tmpl) file.
1. Generate the `cloudbuild-stage.yaml` configuration file using the [`cloudbuild-stage.yaml_tmpl`](../builds/cloudbuild-stage.yaml_tmpl) file.
1. Prepare the Terraform files for each environment and cloud using the respective templates in [`infrastructure`](../../infrastructure)`/<environment>/variables` directory and the [`shared_terraform_modules/templates`](../shared_terraform_modules/templates) directory.
1. Commit the files and push changes to the `infrastructure` repository's `main` branch, which triggers the build.

## functions.sh

The `functions.sh` file is a set of bash helper functions.

## tools.sh

The `tools.sh` is installs the tools required for the workshop.

### Flow

1. Verify the `OSTYPE` environment variable is `linux-gnu`.
1. Create the logging directory, bash configuration file(`.gcp-workshop.bash`), and a log file(`logs/tools-$(date +%s).log`) for the script.
1. Source the [`functions.sh`](#functionssh) helper script.
1. Sources the `vars.sh` file.
1. Install [`kustomize`](https://kubernetes-sigs.github.io/kustomize/)
1. Set the `PATH` environment variable in the `.gcp-workshop.bash` file
1. Install [`pv`](https://man7.org/linux/man-pages/man1/pv.1.html)
1. Install the [`krew`](https://krew.sigs.k8s.io/) `kubectl` plugin.
1. Install the [`ctx`](https://github.com/ahmetb/kubectx) `kubectl` plugin using `krew`.
1. Install the [`ns`](https://github.com/ahmetb/kubectx) `kubectl` plugin using `krew`.
1. Install `awscli`.
1. Install `aws-iam-authenticator`.
1. Install [`kubectl_aliases`](https://github.com/ahmetb/kubectl-aliases).
1. Enable `kubectl` autocompletion.
1. Install [`istioctl`](https://istio.io/latest/docs/reference/commands/istioctl/).
1. Install [`nomos`](https://cloud.google.com/anthos-config-management/docs/how-to/nomos-command).
1. Customize the bash prompt using the [krompt.bash](../scripts/krompt.bash) file.
