#!/bin/bash

make_cmd=$1
gcloud_project= $2
gcloud_sa_key=$3
gcloud_sa_key_path=key.json

cat > key.json <<EOF
$gcloud_sa_key
EOF

cat key.json

gcloud auth activate-service-account test-service-account@google.com --key-file=$gcloud_sa_key_path --project=$gcloud_project

cd $(ls | head -n1)

make_cmd=$1

make $make_cmd
