## Introduction to Anthos

[Anthos](https://cloud.google.com/anthos) is a hybrid and multi-cloud platform that allows enterprises to build, deliver and manage the life cycle of modern applications in a fast, scalable, reliable and secure way. In addition to [modern applications](https://cloud.google.com/solutions/cloud-native-app-development), Anthos also integrates to existing applications and application infrastructure which allows enterprises to modernize in place, in the cloud and at their own pace. Anthos platform is cloud agnostic. It can run in an on-premises data center, GCP or any cloud environment. Anthos platform is composed of a number of components that provide the following functionality:

- Container management (via Anthos GKE)
- Policy management and enforcement (via Anthos Configuration Management)
- Services management (via Anthos Service Mesh)
- Application and software life cycle management (CI/CD)
- Observability and platform management (via Cloud Operations)

## Anthos multi-cloud workshop

The purpose of this workshop is to learn, build and manage Anthos platform in a multi-cloud environment. Instead of a technology (or product) focused approach, the workshop takes a persona-focused approach. The labs in the workshop each align to a user story. There are three main personae that interact with Anthos:

1. **Application Developers or Owners** - Application developers are primarily responsible for writing and debugging application code.
1. **Application or Service Operators** - Also sometimes affectionately known as [SRE](https://landing.google.com/sre/), are responsible for running applications/services, monitoring the health and status of live deployments, and rolling out updates.
1. **Platform Administrators** - Platform admins are part of a centralized platform team responsible for creating and managing resources for application teams and managing the organization’s central infrastructure.

The labs in the workshops are designed with these user personae and their user journeys in mind.

The workshop is divided into two main sections:

1. **Foundation** - Aimed at the platform admin persona, the foundation focuses on _building_ the Anthos platform. The foundation goes through tooling, build pipelines, automation, best practices and management of components of Anthos in GCP and AWS. The foundation covers a canonical approach of building and managing Anthos platform in a multi-cloud environment.
1. **User Stories** - After the foundation, you can start _using_ the Anthos platform. This section is a series of labs that go various user stories. These section is designed to be iterative and ever growing. The idea behind splitting the foundation from the user stories is so that anyone can build upon the foundation for a particular story. We will continue to add more and more stories in time and as we hear more use cases. Some examples of user stories that are part of this workshop are as follows:

- _I, application owner and operator, want to deploy my applications across multiple clusters in multiple cloud environments_
- _I, application operator, want to move/migrate services between clusters in a multi-cloud environment._
- _I, application owner and operator, want to run the same service in multiple cluster and in multiple cloud environments._
- _I, application operator, want to use Cloud Monitoring to monitor metrics from all services running in all clusters in multiple cloud environments_
- _I, platform administrator, want to add a new cluster to my multi-cloud environment_

## Workshop repository

The workshop is currently being maintained at the following repository.
https://gitlab.com/anthos-multicloud/anthos-multicloud-workshop
