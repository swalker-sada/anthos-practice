## Objective

1. Integration test the underlying platform utitlizing the labs.  This workflow will run through labs 1-3 & 6-7 deploying all the artifacts and test the components for availability.  This workflow can also be used to automatically prepare a deployed demo environment.

## Start the pipeline

1.  A pipeline has already been defined to deploy the applications and their dependencies.  Run the following commands to initialize the `test-harness` repository.

    ```bash
    source ${WORKDIR}/anthos-multicloud-workshop/user_setup.sh
    cd ${WORKDIR}
    # init git
    git config --global user.email "${GCLOUD_USER}"
    git config --global user.name "Cloud Shell"
    if [ ! -d ${HOME}/.ssh ]; then
      mkdir ${HOME}/.ssh
      chmod 700 ${HOME}/.ssh
    fi
    # pre-grab gitlab public key
    ssh-keyscan -t ecdsa-sha2-nistp256 -H gitlab.endpoints.${GOOGLE_PROJECT}.cloud.goog >> ~/.ssh/known_hosts
    git clone git@gitlab.endpoints.${GOOGLE_PROJECT}.cloud.goog:test-harness/test-harness.git
    cd test-harness/
    cp -R ~/anthos-multicloud/anthos-multicloud-workshop/platform_admins/tests/test_harness/. .
    git add .
    git commit -m 'test'
    git branch -m master main
    git push origin main 
    ```
    > If you are testing a specific branch, specify the appropriate `BRANCH` in the push command.

    ```bash
    git push origin main -o ci.variable="BRANCH=main"
    ```

## Observing the pipeline

1.  Check out the status of the pipeline using the link below.

    ```bash
    echo -e "https://gitlab.endpoints.${GOOGLE_PROJECT}.cloud.goog/test-harness/test-harness/-/pipelines"
    ```

    <img src="/platform_admins/docs/img/test-harness-pipeline.png" width=70% height=70%>

    > If the pipeline fails at any point in time, checkout the job details and retry as needed.  Sometimes you may need to retry the actual pipeline of the resource (i.e. redis, cockroachdb, bank-of-anthos etc)

    ```bash
    echo -e "https://gitlab.endpoints.${GOOGLE_PROJECT}.cloud.goog/dashboard/projects"
    ```

#### [Back to Labs](/README.md#labs)
