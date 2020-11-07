## Objective

1. Use and manage the distributed relational database [CockroachDB](https://www.cockroachlabs.com) running [Bank of Anthos](https://github.com/GoogleCloudPlatform/bank-of-anthos).

## Prerequisites

1. Ensure that Bank of Anthos is deployed by following the instructions [here](/platform_admins/docs/multicluster-cd-bank-of-anthos.md).

## Overview

Throughout this lab you will perform a variety of tasks that will get your familiar with the distributed database used by Bank Of Anthos. The main tasks you'll be performing are

- creating a transaction using the Bank Of Anthos application
- connecting to the database and reviewing the transaction using a command line interface
- using a GUI-based IDE

# NOTES TO CHRIS - deleted as implemented
- command line connection
    - connect to service
    - connect to specific pod
- GUI-based IDE
    - DBeaver possible, port forward from kubectl directly for e.g. DBeaver to connect
    - ideally: web-based GUI so that it can be deployed as container as well (pdAdmin?)
    - maybe DBeaver or Beekeeper Studio [here](https://www.cockroachlabs.com/docs/v20.1/third-party-database-tools.html#graphical-user-interfaces-guis) if no web-based UI available

