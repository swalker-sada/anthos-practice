## Objectives

1. Deploy a microservices based application in all environments split across multiple clusters.

## Deploying Online Boutique application

1. Deploy the [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) sample application in all environments by running the following scripts.

```
${WORKDIR}/anthos-multicloud-workshop/platform_admins/tests/ob_prod.sh
${WORKDIR}/anthos-multicloud-workshop/platform_admins/tests/ob_stage.sh
${WORKDIR}/anthos-multicloud-workshop/platform_admins/tests/ob_dev.sh
```

Online Boutique is a microservices based application composed of 11 microservices.
These script deploy the Online Boutique application in all environments with microservices split across all clusters within each environment.
Services are deployed on all clusters. Deployments are only created in one cluster within an environment for every microservice.
The script ensures all Deployments are _Ready_ before exiting.

```
Output excerpt (Do not copy)
...
*** Access Online Boutique app in namespace ob-prod by navigating to the following address: ***

35.34.33.32
```

You can access Online Boutique application through the `frontend` Service. The `frontend` Service is exposed via the `istio-ingressgateway` Service using a TCP L4 load balancer.
The public IP address of the `istio-ingressgateway` Service is outputted by each script.

1. Copy and paste the public IP address of the `istio-ingressgateway` Service for each environment into a browser tab.
1. You should see the homepage of the Online Boutique application.

<img src="/platform_admins/docs/img/ob-frontend.png" width=70% height=70%>

1. Navigate around the application to ensure complete functionality. You should be able to browse items, place them in cart, add additional items to the cart and checkout.

1. Inspect the **Workloads** for each environment through Cloud Console. Navigate to the **Kubernetes Admin > Workloads** page in Cloud Console.

<img src="/platform_admins/docs/img/gke-workloads-menu.png" width=30% height=30%>

1. Online Boutique application is installed in different namespaces for different environments. The namespaces are names `ob-<env>`. For example, in `prod` environment, Online Boutique is installed in the namespace `ob-prod`. From the **Namespace** dropdown, select the `ob-prod` namespace and click **OK**.

<img src="/platform_admins/docs/img/gke-namespace-dropdown.png" width=20% height=20%>

1. You can now see Deployments for all clusters (GKE and EKS) in the `prod` environment. Click `Cluster` in the table to sort by cluster. You can see that every Deployment is running on one (of four) clusters.

<img src="/platform_admins/docs/img/gke-workloads-ob-prod.png" width=70% height=70%>

For Online Boutique to function, all microservices must be *Ready* and be able to communicate across to other Services. See [Online Boutique Architecture](https://github.com/GoogleCloudPlatform/microservices-demo#service-architecture) for details on service to service connectivity. Anthos Service Mesh ([ASM](https://cloud.google.com/anthos/service-mesh)) allows you to create multi-cloud service mesh between Anthos and Anthos attached clusters running anywhere. In this case, ASM creates a multi-cloud service mesh between GKE and EKS clusters. 

Anthos Service Mesh is designed to be *ambient*, meaning it operates transparently at the platform layer without interfering with the Services. This allows you to simply move a worklod (a Deployment) from one cluster to another even across clouds wihtout any additional configuration.

Up next, you can manually migrate one of the Deployments from one cloud to another.

#### [Back to Labs](/README.md#labs)