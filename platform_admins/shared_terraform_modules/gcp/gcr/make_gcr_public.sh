#!/usr/bin/env bash

# From https://stackoverflow.com/questions/33792803/how-do-i-create-a-public-image-in-google-container-registry-gcr
# Make all future objects in the bucket public
gsutil defacl ch -u AllUsers:R gs://artifacts.${PROJECT_ID}.appspot.com

# Make all current objects in the bucket public (eg, the image you just pushed)
gsutil acl ch -r -u AllUsers:R gs://artifacts.${PROJECT_ID}.appspot.com

# Make the bucket itself public (not handled by -r)
gsutil acl ch -u AllUsers:R gs://artifacts.${PROJECT_ID}.appspot.com
