## Objective

1. Deploy a microservice based application to multiple clusters in multiple cloud environments using a CI/CD pipeline.

## Videos

- [📽️ Video Walk Through I: Prerequisites and starting pipeline](https://app.threadit.area120.com/thread/p6x3vqj8teqz14uq7yzw?utm_medium=referral-link)
- [📽️ Video Walk Through II: Accessing the application](https://app.threadit.area120.com/thread/xzyd9mrwfeiaqy0jj8vf?utm_medium=referral-link)
- [📽️ Video Walk Through III: Inspecting CI/CD pipeline](https://app.threadit.area120.com/thread/qrfyuy161o9jdofhfwfm?utm_medium=referral-link)
- [📽️ Video Walk Through IV: Migrating workloads using CI/CD pipelines and inspecting metrics](https://app.threadit.area120.com/thread/m996p5nfkxh9aokg3yh6?utm_medium=referral-link)

## Prerequisites

1. Initialize the `shared-cd` repository. Follow the steps [here](/platform_admins/docs/init-shared-cd-repo.md). `shared-cd` repository contains the CI/CD jobs/stages required to deploy Online Boutique to the platform.
1. Initialize the `config` repository. Follow the steps [here](/platform_admins/docs/init-config-repo.md). `config` repository ensures that the Online Boutique namespaces are created in all clusters in the `prod` environment.
1. Initialize the `redis` repository. Follow the steps [here](/platform_admins/docs/redis.md). `redis` repository contains the CI/CD jobs/stages required to deploy a multicloud Redis cluster.

## Multicloud Continuous Delivery

You intend to deploy an application called Online Boutique in your multicloud platform. [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) is a sample e-commerce application that simulates an online store. The applications lets users browsers items, get details about items, place items in a shopping cart, checkout or purchase items that are in their shopping cart and get recommendations based on their purchase and browsing history. The application is composed of 10 services that each run as containers and connect to each other over REST and GRPC API. There is an 11th service called `loadenerator` which (as the name suggests) is used to simulate user load to the application. This is helpful when verifying functionality as well as looking at telemetry of the application.

You use Git to deploy the application. The source code for each service as well as the configuration needed to deploy and run the service are stored in Git repositories. In this workshop, you use Gitlab, however, you may use any Git solution for example Gitlab or Cloud Source Repositories. Once the source code and the services' configuration are stored in Git, CI workers (containers with the required tooling and access to the platform) are used to perform a series of steps to ensure that the application and its configuration is deployed in a consistent and repeatable manner. These series of steps can be automatically triggered by a user event. With Git, these events are when a user _commits_ something to the repository, when a user creates a _pull request_ or a _merge request_ and when that _pull/merge request_ is accepted. Different steps can be taken for each of these events depending upon the intent. This setup allows developers and application owners to continuously deploy applications without the need to coordinate with operations or by conducting any manual steps. These series of steps are themselves stored as code and are sometimes called CI/CD pipelines. CI (Continuous Integration) refers to the **building** of a deployable artifact. And CD (Continuous Delivery) refers to the **deployment** of the artifact along with its configuration. In this lab, you focus on CD. The artifacts for each service are containers that are already created and stored in a container repository.

Your goal is to deploy the containerized services along with their configuration to the multicloud platform.

At a high level you perform the following steps:

1. Initialize `config` and `shared-cd` repositories. See [Prerequisites](#prerequisites) for details.
1. `online-boutique` repository. Online boutique is the application you aim to deploy in your multicloud platform. This repository contains the source code (in the `/src` folder) and the service configuration files (in the `/services` folder) required to deploy all services.
1. Run the Gitlab CI pipeline in the `online-boutique` repo which generates hydrated Kubernetes manifest files for each service and commits them to the `config` repo in the appropriate service namespace.
1. Verify all Deployments are _Ready_.
1. Ensure Online Boutique is functioning by browsing through the app and performing all user actions.

## `online-boutique` Repository

`online-boutique` repository is the application repository. This repository contains the source code (in the `/src` folder) as well as configuration files (in the `/services` folder) for all services.

### Deployment Pipeline

The deployment pipeline is defined in the `.gitlab-ci.yml` file. It consists of four stages:

1. **Build** Stage. This stage creates the _hydrated_ Kubernetes manifest files for all twelve services. Hydrated Kubernetes configuration is a single file (called `${SVC}-hydrated.yaml`) that contains all resources required to run the service (deployment, service, ingress, service account etc.). This stage also creates a Cloud Ops [dashboard](https://cloud.google.com/monitoring/charts/dashboards) for the [golden signals](https://landing.google.com/sre/sre-book/chapters/monitoring-distributed-systems/) for each service. The script to create the dashboard as well as the dashboard template are located in the `/services/${SVC}/prod/monitoring` folder.
1. **Commit** Stage. In this stage, the hydrated Kubernetes manifest files (created and outputted in the **Build** stage) are committed to the `config` repository. There are twelve services in the Online Boutique application. Each service gets deployed to its own namespace. The name of the namespace is the same as the service name prefixed by `ob-` for example the `frontend` service is deployed in the `ob-frontend` namespace. Each service namespace folder is under the `/namespaces/online-boutique` folder in the `config` repository. The hydrtaed Kubernetes manifests files for each service is copied to the respective service namespace folders. For example, the `frontend-hydrated.yaml` file is copied to the `/namespaces/online-boutique/frontend` folder.
1. **WorkloadIdentity** Stage. Each service runs with a [Kubernetes Service Account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/). The service account name is the same as the service name. For example, the `frontend` service runs in the `ob-frontend` namespace with the `frontend` service account. You can think of the Kubernetes Service Account as the service identity. Each service writes metrics to [Cloud Ops](https://cloud.google.com/products/operations). You need to authenticate and authorize services to write metrics data to Cloud Ops. Services running in GKE (on GCP) can use [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity). With Workload Identity, you can configure a Kubernetes service account to act as a Google service account. As part of the workshop build pipeline, a GCP service account called `cloud-ops` is created with proper IAM roles to write metrics data to Cloud Ops. All services running on GKE (on GCP) use Workload Identity with the `cloud-ops` service account. This allows GKE services to write metrics data to Cloud Ops.
1. **SecureIngress** Stage. You access Online Boutique via the `frontend` service. This stage securely exposes the `frontend` service so that you can access it over HTTPS. For HTTPS access to the frontend, you require a domain name and a certificate signed by a well-known CA (recognized by common browsers). You use [Cloud Endpoints](https://cloud.google.com/endpoints/docs/openapi/cloud-goog-dns-configure) to get a free DNS name for your application. With the Cloud Endpoints DNS name, you can use Google-managed SSL certificates service to get a free certificate for the frontend. By default, `frontend` Pods are deployed on all four clusters (two GKE and two EKS clusters). You use [GCLB](https://cloud.google.com/load-balancing) to send all incoming traffic via the DNS name to the two `istio-ingressgateway` proxy Pods running on the two GKE clusters. `istio-ingressgateway` proxies are aware of all four `frontend` Pods and load balance traffic to all `frontend` Pods. The default load balancing mode is `ROUND ROBIN`. This is defined in the `destinationrule--frontend.yaml` (located in the `/services/frontend/templates` folder). The default split between Pods running in GKE and EKS is 50/50. This is defined in the `virtualservice--subset-patch.yaml` and `virtualservice--ingress-subset-patch.yaml` (located in the `/services/frontend/prod/traffic` folder). _DestinationRule_ and _VirtualService_ are [CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) used by Anthos Service Mesh [ASM](https://cloud.google.com/anthos/service-mesh). You can learn more about them [here](https://istio.io/latest/docs/reference/config/networking/virtual-service/).

The `.gitlab-ci.yml` pipeline runs every time a commit is made to the `online-boutique` repository.

1. Initialize the `config`, `shared-cd` and `redis` repositories. See the [Prerequisites](#prerequisites) section above for details.

1. Run the following commands to initialize the `online-boutique` repository.

```bash
cd ${WORKDIR}
git clone git@gitlab.endpoints.${GOOGLE_PROJECT}.cloud.goog:online-boutique/online-boutique.git
cd $WORKDIR/online-boutique
cp -r ${WORKDIR}/anthos-multicloud-workshop/platform_admins/starter_repos/online_boutique/. .
git add .
git commit -m "initial commit"
git branch -m master main
git push -u origin main
```

## Deployment Pipeline

Every time you commit to the `online-boutique` repository, you can view the pipeline by accessing the following link. You can also navigate to the same link by clicking on the **CI/CD > Pipelines** link from the left hand nav bar.

```bash
echo -e "https://gitlab.endpoints.${GOOGLE_PROJECT}.cloud.goog/online-boutique/online-boutique/-/pipelines"
```

Wait until the pipeline successfully completes.

> If the pipeline fails, for instance on the `SecureIngress` job, just retry the pipeline job.

<img src="/platform_admins/docs/img/ob-multicluster-cd-pipeline-success.png" width=70% height=70%>

You can click on individual jobs to view details.

## Viewing Workloads

After the pipeline successfully completes, click on the following link to get the workloads (i.e. Deployments) for the Online Boutique application.

```bash
echo -e "https://console.cloud.google.com/kubernetes/workload?cloudshell=false&project=${GOOGLE_PROJECT}&pageState=(%22savedViews%22:(%22i%22:%22848de3cf75db4b5389286a0e967df1bf%22,%22c%22:%5B%5D,%22n%22:%5B%22ob-ad%22,%22ob-cart%22,%22ob-checkout%22,%22ob-currency%22,%22ob-email%22,%22ob-frontend%22,%22ob-loadgenerator%22,%22ob-payment%22,%22ob-productcatalog%22,%22ob-recommendation%22,%22ob-redis%22,%22ob-shipping%22%5D))"
```

Each service for the Online Boutique gets deployed in its own namespace. The link above creates a view in the **Kubernetes Engine > Workloads** page with all of the Online Boutique services' namespaces selected.

<img src="/platform_admins/docs/img/online-boutique-workloads.png" width=70% height=70%>

Ensure all workloads are _Ready_. Refresh the screen until all workloads are healthy.

## Secure Ingress

The **SecureIngress** stage creates an implementation of multi-cloud ingress for the Online Boutique application. This creates a DNS name for the `frontend` service (using Cloud Endpoints) and a Google-managed certificate.

1. Check that the managed certificate is proivisioned and `ACTIVE` by running the following command:
```bash
gcloud compute ssl-certificates list
```

The output looks like the following:
```
Output (Do not copy)
NAME                         TYPE     CREATION_TIMESTAMP             EXPIRE_TIME  MANAGED_STATUS
obfrontend-managed-ssl-cert  MANAGED  2020-10-31T17:12:30.862-07:00               ACTIVE
    shop.endpoints.gcp_project_id.cloud.goog: ACTIVE
```

2. Once the certificate is `ACTIVE`, you can access the Online Boutique application by navigating to the following link:
```bash
echo -e "https://shop.endpoints.${GOOGLE_PROJECT}.cloud.goog"
```

You can now navigate through the application and perform actions like browing through items, getting item details, placing them in your shopping cart and checking out.

> If you get the error `ERR_SSL_VERSION_OR_CIPHER_MISMATCH` when accessing the frontend, wait a few moments and then try again.

The traffic flow is diagrammed below:

```mermaid
%%{init: { 'theme': 'default' } }%%
graph TD
classDef eks fill:#F2ECE8,stroke:#333,stroke-width:1px;
classDef ns fill:#99C4C8,color:#fff,stroke:#333,stroke-width:1px;
classDef gke fill:#C3E5E9,stroke:#333,stroke-width:1px;
classDef pod fill:#E7ECEF,stroke:#333,stroke-width:1px;

client[Client]
gclb[GCLB]
istio1[istio-ingressgateway Pod]
istio2[istio-ingressgateway Pod]
frontendgke1[frontend Pod]
frontendgke2[frontend Pod]
frontendeks1[frontend Pod]
frontendeks2[frontend Pod]

client -->|HTTPS using managed certificates|gclb
gclb -->|all client traffic flows through the istio-ingressgateway in the GKE clusters| istio1
gclb -->|all client traffic flows through the istio-ingressgateway in the GKE clusters| istio2
istio1 -.->|mTLS| frontendgke1
istio1 -.->|mTLS| frontendeks1
istio1 -.->|mTLS| frontendgke2
istio1 -.->|mTLS| frontendeks2
istio2 -.->|mTLS| frontendgke1
istio2 -.->|mTLS| frontendeks1
istio2 -.->|mTLS| frontendgke2
istio2 -.->|mTLS| frontendeks2

subgraph GKE1[GKE Prod 1]
    subgraph istio-system1[istio-system namespace]
        istio1
    end
    subgraph ob-prod-gke1[ob-frontend namespace]
        frontendgke1
    end
end

subgraph GKE2[GKE Prod 2]
    subgraph istio-system2[istio-system namespace]
        istio2
    end
    subgraph ob-prod-gke2[ob-frontend namespace]
        frontendgke2
    end
end

subgraph EKS1[EKS Prod 1]
    subgraph ob-prod-eks1[ob-frontend namespace]
        frontendeks1
    end
end

subgraph EKS2[EKS Prod 2]
    subgraph ob-prod-eks2[ob-frontend namespace]
        frontendeks2
    end
end

class GKE1,GKE2 gke;
class EKS1,EKS2 eks;
%%class istio-system1,ob-prod-gke1,ob-prod-eks1 ns;
class istio1,frontendgke1,frontendeks1,istio2,frontendgke2,frontendeks2 pod;

```

1. Client accesses Online Boutique via a DNS name. In this workshop, the DNS name is provided by Cloud Endpoints, however, you can use any DNS name of a domain you own.
1. A Google-managed SSL certificate is used for HTTPS access to Online Boutique.
1. GCLB sends the traffic to the two `istio-ingressgateway` proxy Pods running in the two GKE clusters. You can control how much load goes to each backend (i.e. `istio-ingressgateway`) using the [RATE](https://cloud.google.com/load-balancing/docs/https#load_distribution_algorithm) setting.
1. Each `istio-ingressgateway` is aware of all `frontend` Pods. By default, `frontend` Pods are deployed to all four clusters. `frontend` is divided into two subsets - one for GCP and one for AWS. Subsets group workloads based on labels. All workloads (Pods) running GKE contain the label `provider: gcp` while all workloads running in EKS contain the label `provider: aws`. Using label selectors, the two subsets (one for Pods running in GCP and the other for Pods running in AWS) are created as part of the **Build** pipeline. You can then use a `VirtualService` CRD to control how much traffic you want to send to each subset. by default, the traffic is equally split between the two subsets.
1. From `client` to `frontend`, all traffic is encrypted. TLS between client and `istio-ingressateway` and mTLS between `istio-ingressgateway` and the `frontend` Pods.

Congratulations. You have successfully deployed a microservice-based application to the Anthos multi-cloud platform using a simple Continuous Delivery (CD) pipeline.

#### [Back to Labs](/README.md#labs)
