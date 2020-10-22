## Objective

1. Configure Cloud Monitoring to receive metrics from all services running in all clusters in all environments.
1. Create a metrics dashboard for Online Boutique app in all environments for `service request counts` and `service latency`.

## Prerequisite

1. Follow the steps in the [Lab 1: Multicloud Applications](/platform_admins/docs/multicluster-networking.md) before proceeding.
1. Afterwards, you should be able to access the Online Boutique application.

## Initializing Cloud Monitoring

1. From the lefthand navbar, click on **Monitoring > Overview**.
<img src="/platform_admins/docs/img/cloud-mon-init.png" width=30% height=30%>

Wait a few moments until Cloud Monitoring service sets up your [workspace](https://cloud.google.com/monitoring/workspaces) where you can organize metrics for your project.

1. From the lefthand navbar in the Cloud Monitoring page, click of **Metrics Explorer**.
<img src="/platform_admins/docs/img/cloud-mon-metrics-link.png" width=20% height=20%>

1. Type `istio server request count` in the search window in Metrics Explorer. Click on **Server Request Count**.
<img src="/platform_admins/docs/img/cloud-mon-server-request-count.png" width=20% height=20%>

1. Select **Kubernetes Container** as the **Resource Type**.

1. In the **Group By** field, search for `service name` and select **destination_service_name**.
<img src="/platform_admins/docs/img/cloud-mon-groupby-svc.png" width=20% height=20%>

1. In the **Group By** field, also search for and select **cluster_name**. Ensure **Aggregator** is set to `sum` and **Period** is set to `1 minute`.
<img src="/platform_admins/docs/img/cloud-mon-groupby-cluster.png" width=20% height=20%>

1. You can now see a line chart of server request counts per server grouped by cluster.
<img src="/platform_admins/docs/img/cloud-mon-chart-svc.png" width=50% height=50%>

1. Scroll through the table view and verify that you are getting metrics from all clusters in all environments.

## Creating a dashboard

1. Click on the **Save Chart** button on the top right. Select **New Dashboard** and give it a name like `Online Boutique App`. Click **Save**.
<img src="/platform_admins/docs/img/cloud-mon-dash-svc.png" width=40% height=40%>

1. Click on **Dashboards** from the lefhand navbar and select the **Online Boutique App** dashboard (refresh the page is the dashboard does not show up).
<img src="/platform_admins/docs/img/cloud-mon-dash-page.png" width=70% height=70%>

> You can change the Column layout by clicking the gear icon at the top and selecting the number of desired columns for example 1 Column.

## Adding additional charts to the dashboard

The easiest way to add a chat is to copy an existing chart to the same dashbard and then editing its attributes.

1. Click on the three-dots at the top left corner of the existing chart and select **Copy Chart**.

1. Select the same Dashboard, in this case the **Online Boutique App** and change the name of the chart to the new chart you intend to build. For example, you can build a chart called `Latency 99th Percentile` that shows 99th percentile latency grouped by service and cluster. Click **Copy**.
<img src="/platform_admins/docs/img/cloud-mon-chart-copy-99.png" width=30% height=30%>

You should see a second chart with the new title.

1. Click on the three-dots at the top left corner of the new chart and select **Edit**. This brings up the **Metrics Explorer** view.

1. Delete the `server_request_count` metric from the **Metrics** selector. Search for `istio latency`. Select **Server Response Latencies**. In the **Aggregator** dropdown, change the value from `sum` to `99th percentile`. Click **Save** at the bottom.
<img src="/platform_admins/docs/img/cloud-mon-lat-99.png" width=30% height=30%>

1. Copy the `Latency 99th Percentile` chart to the Online Boutique App dashboard twice. Edit and change the aggregator to `95th percentile` and `50th percentile` for each of the newly copied charts. You should now have four charts in your dashboard.
    * Server Request counts
    * Latency 99th Percentile
    * Latency 95th Percentile
    * Latency 50th Percentile

<img src="/platform_admins/docs/img/cloud-mon-dash-app.png" width=80% height=80%>

## Using filters

The current dashboard has four charts. Each charts is grouped by all services, across all clusters, across all environments. You can use **filters** to narrow down what you want to view.

In this example, lets assume you want to only see traffic flowing to the `frontend` service in the `prod` environment and all associated workloads.

1. In the **Filter** bar at the top, select `namespace_name` and click on `ob-prod`. This filter selects all services running in the `prod` environment.
<img src="/platform_admins/docs/img/cloud-mon-filter-ns.png" width=30% height=30%>

1. Add another filter for `destination_service_name` for the `frontend` service. You should now only see charts for the `frontend` service running in the `prod` environment. Click on the **Expand chart legend** button at the top right corner of the `Server Request Count` chart.
<img src="/platform_admins/docs/img/cloud-mon-filter-frontend.png" width=80% height=80%>

If you did [Lab 3: Introduction to Distributed Services](/platform_admins/docs/distributed-service-intro.md), you should see two line graphs. The legend shows the two clusters the `frontend` workloads (Depolyments) are running in. Otherwise, you should see a single line graph.

## Scripted Dashboard for Production
> If you skipped the steps above, you need to initialize the Cloud Ops Monitoring Workspace in the Google Cloud Console.

1. A pre-created created dashboard for production is available.

    ```
    ${WORKDIR}/anthos-multicloud-workshop/platform_admins/tests/ops/services-dashboard.sh \
      ${WORKDIR}/anthos-multicloud-workshop/platform_admins/tests/ops/services-dashboard-prod
    ```

    Output (do not copy)
    ```
    ... json ...
    https://console.cloud.google.com/monitoring/dashboards/custom/servicesdash?cloudshell=false&project=qwiklabs-gcp-01-01f4f219d79d
    ```

1. Select the link from the script output to open the dashboard directly.

1. A new tab with the dashboard will be opened.  Select the custom dashboard titled: `Services Dashboard - Production`

    <img src="/platform_admins/docs/img/cloud-mon-dash-list.png" width=80% height=80%>


#### [Back to Labs](/README.md#labs)















