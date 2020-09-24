## Objective

1. Manually migrating a Service from a cluster in AWS (EKS) to a cluster in GCP (GKE)

## Prerequisite

1. Follow the steps in the [Lab 1: Multicloud Applications](/platform_admins/docs/multicluster-networking.md) before proceeding.
1. Afterwards, you should be able to access the Online Boutique application.

## Manually migrating a service from AWS to GCP

With Anthos platform, you can move the workloads (i.e. Kubernetes Deployments) from one cluster to another. There are multiple reasons you may want to do this.

* Migrating workloads from one environment to another while still being connected to services in the original environment.
* Moving workloads to a different tier. For example, you may want to move a workload from a cluster with standard instances to one with preemptible instances.

> The steps below show a manual process of moving a workload. In production, you would use an orchestrated process (and a pipeline) to perform a migration. This section is for educational purposes only.

Move `cartservice` Deployment from an EKS cluster to a GKE cluster in `prod` environment. You can use [Kiali](kiali.io) to view the topology and realtime service graph as you migrate the Deployment.

1. Enable the `kiali` dashboard in the ${GKE_PROD_1} production cluster.
```
source ${WORKDIR}/vars.sh
kubectl ctx ${GKE_PROD_1}
kubectl ns istio-system
istioctl dashboard kiali &
```

1. Click on the output link from the previous command. Cloud Shell does not automatically open the link in the browser.
```
Output (do not copy)
...
Failed to open browser; open http://localhost:37351/kiali in your browser.
```

1. Login to Kiali with `admin` as both username and password.

1. Click **Graph** from the left hand navbar. Click on the second dropdown and select **Service Graph**.
<img src="/platform_admins/docs/img/kiali-svc-dropdown.png" width=50% height=50%>

1. Click on the first dropdown and select the `ob-prod` namespace.
<img src="/platform_admins/docs/img/kiali-ns-dropdown.png" width=50% height=50%>

1. You see the service topology graph. You can change the view of the graph by clicking on icons labeled `1` and `2` next to the **LEGEND** label at the bottom of the graph. For example, if you click the `1` topology view, you should see the following.

<img src="/platform_admins/docs/img/kiali-svc-graph-original.png" width=50% height=50%>

The lines represent connections between services. The color green represent `HTTP 200` between services. You can see everything is green and the application is working.

1. Delete `cartservice` Deployment from the ${EKS_PROD_2} cluster.
```
kubectl ctx ${EKS_PROD_2}
kubectl ns ob-prod
kubectl delete deployment cartservice
```

1. Access the Online Boutique app by navigating to the `istio-ingressgateway` IP address of ${GKE_PROD_1} cluster.
```
kubectl --context ${GKE_PROD_1} get -n istio-system service istio-ingressgateway -o json | jq -r '.status.loadBalancer.ingress[0].ip'
```

1. You get an `HTTP 500` error. The description states `could not retrieve cart`.
<img src="/platform_admins/docs/img/cart-rm-eks2.png" width=50% height=50%>

1. After a few moments, switch to the Kiali tab and you can see errors showing for the `cartservice` in the service topology graph.
<img src="/platform_admins/docs/img/kiali-cart-error.png" width=50% height=50%>

1. Deploy `cartservice` to ${GKE_PROD_2} cluster. Note that you may pick any of the other three cluster.
```
kubectl ctx ${GKE_PROD_2}
kubectl ns ob-prod
kubectl apply -f ${WORKDIR}/anthos-multicloud-workshop/platform_admins/tests/ob/cart-deployment.yaml
```

1. Wait a few moments until the `cartservice` Pod is *Running*.
```
kubectl get pods
```

Output (do not copy)
```
NAME                                     READY   STATUS    RESTARTS   AGE
cartservice-85776f96ff-fqxt2             2/2     **Running**   0          32s
```

1. Access the Online Boutique application again. It should be functional.

1. After a few moments, you can validate functionality in Kiali. The service topology graph should be green.

1. You can exit Kiali by running the following command.
```
killall istioctl
```
Output (do not copy)
```
[1]  + 3145 terminated  istioctl dashboard kiali
```

You have successfully migrated a service from an EKS cluster to a GKE cluster. You can perform the same steps to migrate any workload running in any cluster to any other cluster.

#### [Back to Labs](/README.md#labs)
