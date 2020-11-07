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

