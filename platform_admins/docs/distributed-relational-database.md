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

Before exploring CockroachDB it is briefly introduced next

## What is CockroachDB?

CockroachDB is a distributed relational database management system implemeting PostgreSQL semantics. It is an active-active database system that ensures transactional consistency of any transaction across its instances: independent of the instance a transaction is executed, all other instances are transactional updated and consistent.

In context of the Anthos Multicloud Workshop 6 CockroachDB instances are deployed, 3 in the Google Cloud cluster, and 3 in the EKS cluster. All form a single CockroachDB cluster and the database that hosts the data of Bank Of Anthos spans all 6 nodes across the two clusters in the two clouds.

## Creating a transaction using Bank Of Anthos

## Connecting to the database using the CLI

## Connecting to the database using an IDE

## Verifying that the database is synchronized between Google Cloud and AWS

## Using the administration UI of CockroachDB

## Simulating a node crash

## Simulating a cluster outage

## Backing up and restoring the database

## Developing a backup strategy

## What's next

# NOTES TO CHRIS - deleted as implemented
- command line connection
    - connect to service
    - connect to specific pod
- GUI-based IDE
    - DBeaver possible, port forward from kubectl directly for e.g. DBeaver to connect
    - ideally: web-based GUI so that it can be deployed as container as well (pdAdmin?)
    - maybe DBeaver or Beekeeper Studio [here](https://www.cockroachlabs.com/docs/v20.1/third-party-database-tools.html#graphical-user-interfaces-guis) if no web-based UI available
- try to bring down all pods in Google Cloud and show that AWS serves the whole traffic

