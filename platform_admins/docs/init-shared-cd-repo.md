## Objective

1. Initialize the `shared-cd` repository which contains the jobs required for the CI/CD pipelines to deploy applications. 
> You only need to do this once. If you have already deployed another application for example [Bank of Anthos](/platform_admins/docs/multicluster-cd-bank-of-anthos.md), then may have already done this.

## `shared-cd` Repository

The `shared-cd` repository contains Gitlab CI/CD [jobs](https://docs.gitlab.com/ee/ci/introduction/#how-gitlab-cicd-works) required to deploy applications to the Anthos multi-cloud platform. These jobs can be used in application repositories' CI/CD pipelines to deploy the application. In this lab, the `online-boutique` repo's CI/CD pipeline uses jobs defined in the `shared-cd` repo. This approach has the following benefits:

- Allows the platform admins to define CI/CD best practices to be shared by the application owners. Having a separate repository ensures proper access control.
- Allows consistent deployment methodology shared by all application teams. Applications do not have to maintain their own individual pipelines.
- Avoids code duplication (which increases chance of errors and mistakes).

1. Run the following commands to initialize the `shared-cd` repository.

```bash
cd ${WORKDIR}
git clone git@gitlab.endpoints.${GOOGLE_PROJECT}.cloud.goog:platform-admins/shared-cd.git
cd ${WORKDIR}/shared-cd
cp -r ${WORKDIR}/anthos-multicloud-workshop/platform_admins/starter_repos/shared_cd/. .
git add .
git commit -m "initial commit"
git branch -m master main
git push -u origin main
```
