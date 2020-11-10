## Objective

1. Deploy a CockroachDB database on GKE ($GKE_PROD_1) and EKS ($EKS_PROD_1) clusters. You deploy a 6 [node](https://www.cockroachlabs.com/docs/v20.1/architecture/overview.html#terms) cluster with 3 nodes in each cluster running as [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/StatefulSet/).

## Prerequisite

1. Initial workshop build completed successfully (using the `build.sh` script).
1. Gitlab is deployed with the `config`, `shared-cd` and `cockroachdb` repositories.
1. `config` repository is initialized and `nomos status` shows `SYNCED` for all clusters (except Gitlab). This is done in the [Multicluster CD](/platform_admins/docs/multicluster-cd.md) user journey.
1. `shared-cd` respository is initialized, which contains the CD pipeline jobs used to deploy cockroachdb. This is done in the [Multicluster CD](/platform_admins/docs/multicluster-cd.md) user journey.

## `cockroachdb` repository

1. Run the following set of commands to initialize the `cockroachdb` repository in Gitlab. Committing to this repository will initiate the CD pipeline which deploys cockroackdb cluster on the two Kubernetes clusters.

```
cd ${WORKDIR}
git clone git@gitlab.endpoints.${GOOGLE_PROJECT}.cloud.goog:databases/cockroachdb.git
cd ${WORKDIR}/cockroachdb
cp -r ${WORKDIR}/anthos-multicloud-workshop/platform_admins/starter_repos/cockroachdb/. .
git add .
git commit -m "initial commit"
git branch -m master main
git push -u origin main
```

## Verify installation

1. Ensure the cockroachdb StatefulSets are _Running_ (it might take a while).

```
kubectl --context=${GKE_PROD_1} -n db-crdb get pods
kubectl --context=${EKS_PROD_1} -n db-crdb get pods
```

Confirm the outputs below.

```
# Output (Do not copy)
# From GKE
NAME                 READY   STATUS      RESTARTS   AGE
cluster-init-54lgx   0/1     Completed   0          59m
gke-crdb-0           2/2     Running     0          62m
gke-crdb-1           2/2     Running     0          62m
gke-crdb-2           2/2     Running     0          62m

# From EKS
NAME         READY   STATUS    RESTARTS   AGE
eks-crdb-0   2/2     Running   0          62m
eks-crdb-1   2/2     Running   0          62m
eks-crdb-2   2/2     Running   0          62m
```

## CockroachDB Admin UI

1. Log into the cockroachdb admin UI.

```
kubectl --context=${GKE_PROD_1} -n db-crdb port-forward gke-crdb-0 9080:8080 &
```

1. In Cloud Shell, click on **Web Preview** and **Change port** to `9080`. Click **Change and Preview**.

<img src="/platform_admins/docs/img/crdb-ui-main.png" width=50% height=50%>

1. Click on **Network Latency** from the left hand navbar. You can see latency to/from all 6 nodes. This step confirms that all nodes can communicate with each other.

<img src="/platform_admins/docs/img/crdb-ui-network-latency.png" width=50% height=50%>

## Import test data from Bank of Anthos PostgreSQL

[Bank of Anthos](https://github.com/GoogleCloudPlatform/bank-of-anthos) is a sample application used for demoing the Anthos platform. There are two PostgreSQL DBs as part of this application. These databases contain sample data. The `cockroachdb` repository contains SQL dumps from the Bank of Anthos databases using [pg_dump](https://www.cockroachlabs.com/docs/stable/migrate-from-postgres.html#dump-the-entire-database). You can import this data to cockroachdb.

1. Copy the SQL dump files to one of the cockroachdb nodes.

```
kubectl ctx ${GKE_PROD_1}
kubectl ns db-crdb
kubectl exec -it gke-crdb-0 -- mkdir -p /cockroach/cockroach-data/extern
kubectl cp ${WORKDIR}/cockroachdb/templates/dump-accounts-db.sql gke-crdb-0:/cockroach/cockroach-data/extern/dump-accounts-db.sql
kubectl cp ${WORKDIR}/cockroachdb/templates/dump-postgresdb.sql gke-crdb-0:/cockroach/cockroach-data/extern/dump-postgresdb.sql
```

1. Log in to the `gke-crdb-0` node.

```
kubectl exec -it gke-crdb-0 -- bash
cockroach sql --insecure --host=crdb
```

1. Create two databases. Bank of Anthos app uses two databases named `accountsdb` and `postgresdb`.

```
CREATE DATABASE accountsdb;
CREATE DATABASE postgresdb;
```

1. Import data using the SQL dump files.

```
-- Import DBs,
USE accountsdb;
IMPORT PGDUMP 'nodelocal://1/dump-accounts-db.sql';
SHOW TABLES;
SELECT * FROM contacts;
SELECT * FROM users;

USE postgresdb;
IMPORT PGDUMP 'nodelocal://1/dump-postgresdb.sql';
SHOW TABLES;
SELECT * FROM transactions;
```

1. Exit out of the node.

```
\q
exit
```

#### [Back to Bank of Anthos application deployment](platform_admins/docs/multicluster-cd-bank-of-anthos.md)

#### [Back to Labs](/README.md#labs)

