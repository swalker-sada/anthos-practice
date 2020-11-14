## Objective

Use, explore and manage the distributed relational database [CockroachDB](https://www.cockroachlabs.com) running [Bank of Anthos](https://github.com/GoogleCloudPlatform/bank-of-anthos).

## Prerequisites

Ensure that Bank of Anthos is deployed by following the instructions [here](/platform_admins/docs/multicluster-cd-bank-of-anthos.md).

## Overview

Throughout this lab you will perform a variety of tasks that will get your familiar with the distributed database used by Bank Of Anthos. The main tasks you'll be performing are

- creating a transaction using the Bank Of Anthos application
- connecting to the database and reviewing the transaction using a command line interface
- using a GUI-based IDE to review the same transaction
- verifying that the transaction is actually present in Google Cloud and AWS
- reviewing the state of CockroachDB using their admin console
- simulating a node crash and observing that the database remains operational
- backing up the database, and restoring it after a data change
- developing a backup strategy and understanding the relationship between backup frequency and RPO

Before exploring CockroachDB it is briefly introduced next.

## What is CockroachDB?

CockroachDB is a distributed relational database management system implemeting PostgreSQL semantics. It is an active-active database system that ensures transactional consistency of any transaction across its instances: independent of the instance a transaction is executed, all other instances are transactional updated and consistent.

In context of the Anthos Multicloud Workshop 6 CockroachDB instances are deployed, 3 in the Google Cloud cluster, and 3 in the EKS cluster. All form a single CockroachDB cluster and the database that hosts the data of Bank Of Anthos spans all 6 nodes across the two clusters in the two clouds.

TBD Chris to discuss
- benefit: reliability/consistency
- downside: latency/slowdown
- app does not have to know about primary/standby, locations, etc. distributed management is transparent
- optimization: geolocation

## Creating a transaction using Bank Of Anthos

Start the Bank Of Anthos user interface by running this command in gcloud and clicking on the resulting link:

```
echo -e "https://bank.endpoints.${GOOGLE_PROJECT}.cloud.goog"
```

Once the user interface is up and running, make a deposit and remember the amount, e.g., 5432.00 USD. Later you will lookup this amount in the database directly using a database client.


## Connecting to the database using the CLI

Determine the pods running CockroachDB on GKE by executing this command in gcloud:

```
kubectl --context=${GKE_PROD_1} -n db-crdb get pods
```

Open a command line to pod _gke-crdb-1_ as follows in glcloud:

```
kubectl exec -it gke-crdb-1 -- bash
cockroach sql --insecure --host=crdb
```

Now you can run database commands. To show all databases run

```
show databases;
```

Select database _postgresdb_:

```
use postgresdb;
```

Show all tables in that database:

```
show tables;
```

Show the schema of table _transactions_:

```
\d transactions;
```

The result shows you the columns of the table, including the data types for each column.

And finally, find the transaction that you executed in the user interface. First, select the 10 most recent transactions:

```
select * from transactions order by timestamp desc limit 10;
```

Unless you created other transactions in the meanwhile, the amount you added in the user interface earlier should be the first in the list.

As you can see, the amount is stored in USD times 100. So to find your transaction run

```
select * from transactions where amount = 543200;
```

In case you want to verify the time (as the database might run in a different time zone from you) run

```
select now();
```

The time shows the current time and your interface interaction might have been a few minutes earlier.

To exit out of the command line interface run

```
exit
```

And to exit out of the shell run _exit_ again.

## Connecting to the database using the CLI (again)

CockroachDB is an active-active system and so all pods have the same data as those are synchronized transactionally. To explore this, log into a different pod:

```
kubectl exec -it gke-crdb-2 -- bash
cockroach sql --insecure --host=crdb
```

and select your transaction:

```
use postgresdb;
select * from transactions where amount = 543200;
```

This demonstrated that every pod has all data fully synchronized.

## Connecting to the database using an IDE

In many cases you might prefer using an IDE like [DBeaver](https://dbeaver.io/) to access a database instead of using a command line interface. The IDE runs on your laptop and the following instructions show how you can access CockroachDB with DBeaver.

Open a terminal on your laptop and execute the following commands.

Set the project ID as follows by providing your project id

```
gcloud config set project PROJECT_ID
```

Authenticate with the project (use the same account that you use to run Bank of Anthos)

```
gcloud auth login
```

Establish a port forward like this:

```
PROJECT_ID=$(gcloud config get-value core/project 2>/dev/null)
gcloud container clusters get-credentials gke-prod-us-west2a-1 --zone us-west2-a --project $PROJECT_ID \
 && kubectl port-forward --namespace db-crdb $(kubectl get pod --namespace db-crdb --selector="app=cockroachdb" --output jsonpath='{.items[0].metadata.name}') 5432:26257
```

The port 5432 is the customary PostgreSQL port.

At this point you have a connection from your laptop to one of the pods that run CockroachDB. Based on this connect you can create a database connection in the IDE. Use the following configuration values to create a database connection

```
database name: postgresdb
database user: admin
database password: password
database host: 127.0.0.1
database port: 5432
```

In context of CockroachDB these are the IDEs mentioned on the CockroachDB site [here](https://www.cockroachlabs.com/docs/v20.1/third-party-database-tools.html#graphical-user-interfaces-guis).

## Verifying that the database is synchronized between Google Cloud and AWS

TBD Chris
- with IDE connection to both clouds, observe that changes are happening in both clouds

TBD Debug:

```
└─⪧ kubectl --context=${EKS_PROD_1} -n db-crdb get pods
NAME         READY   STATUS    RESTARTS   AGE
eks-crdb-0   2/2     Running   0          3d6h
eks-crdb-1   2/2     Running   0          3d6h
eks-crdb-2   2/2     Running   0          3d6h

└─⪧ kubectl --context=${EKS_PROD_1} exec -it eks-crdb-0 -- bash
Error from server (NotFound): pods "eks-crdb-0" not found
```

## Using the administration UI of CockroachDB

TBD Chris
- guide student how to invoke
- point out interesting admin functionality, esp. latency

## Simulating a pod crash

TBD Chris
- guide student to crash a pod
- guide student to show that db continues to be accessible

## Simulating a cluster outage

TBD Chris
- bring down all pods in Google Cloud and show that AWS serves the whole traffic
- demonstrate that Bank Of Anthos continues to work

## Backing up and restoring the database

TBD Chris
- show how backup works
- show how restore works
- show how data loss looks like if backup did not contain latest changes
- use bucket

## Developing a backup strategy

TBD Chris
- discuss backup strategy
- what happens if one cluster fails?

## What's next

TBD Chris
- have student study CockroachDB more, esp. geolocation
