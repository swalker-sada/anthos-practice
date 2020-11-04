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


# From https://stackoverflow.com/questions/33792803/how-do-i-create-a-public-image-in-google-container-registry-gcr
# Make all future objects in the bucket public
gsutil defacl ch -u AllUsers:R gs://artifacts.${PROJECT_ID}.appspot.com

# Make all current objects in the bucket public (eg, the image you just pushed)
gsutil acl ch -r -u AllUsers:R gs://artifacts.${PROJECT_ID}.appspot.com

# Make the bucket itself public (not handled by -r)
gsutil acl ch -u AllUsers:R gs://artifacts.${PROJECT_ID}.appspot.com
