#!/usr/bin/env bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


SERVICES=(ad cart redis checkout currency email frontend loadgenerator payment productcatalog recommendation shipping)
CLUSTERS=(gke-prod-us-west2a-1 gke-prod-us-west2b-2 eks-prod-us-west2ab-1 eks-prod-us-west2ab-2)

for CLUSTER in ${CLUSTERS[@]}; do
  for SVC in ${SERVICES[@]}; do

    # Get Pod list
    podList=(`kubectl --context ${CLUSTER} -n ob-${SVC} get pods | awk '{ print $1 }'`)

    # Iterate through all Pods
    for IDX in ${!podList[@]}; do
      # Ignore IDX 0 since its NAME
      if [[ ! $IDX == 0 ]]; then 
        # Get the istio-proxy container status
        ISTIO_PROXY_STATUS=`kubectl --context ${CLUSTER} -n ob-${SVC} get pod ${podList[IDX]} -ojsonpath={.status.containerStatuses[?\(@.name==\"istio-proxy\"\)].state.terminated.reason}`
        # If status is Completed, Pod is stuck at Terminating...
        if [[ $ISTIO_PROXY_STATUS == "Completed" ]]; then 
          echo -e "Force deleting pod ${podList[IDX]} in cluster ${CLUSTER} in namespace ob-${SVC}..."
          # Delete the Pod
          kubectl --context ${CLUSTER} -n ob-${SVC} delete pod ${podList[IDX]} --force
        fi
      fi

    done

  done
done
