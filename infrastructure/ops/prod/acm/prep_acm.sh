# Get Cloudbuild SA
export TF_CLOUDBUILD_SA=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@cloudbuild.gserviceaccount.com

# Create an SSH key pair
ssh-keygen -t rsa -b 4096 \
-C "${TF_CLOUDBUILD_SA}" \
-N '' \
-f csr-key

# Check if there is already a csr key present
if [[ $(gsutil ls gs://$PROJECT_ID/ssh-key &> /dev/null || echo $?) ]]; then
  gsutil cp -r csr-key gs://$PROJECT_ID/ssh-key/csr-key
  gsutil cp -r csr-key.pub gs://$PROJECT_ID/ssh-key/csr-key.pub
else
  echo "SSH Key pairs already exist."
  gsutil cp -r gs://$PROJECT_ID/ssh-key/csr-key csr-key
  gsutil cp -r gs://$PROJECT_ID/ssh-key/csr-key.pub csr-key.pub
fi

