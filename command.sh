#!/bin/bash

source_dir=$1
make_cmd=$2
gcloud_project=$3
gcloud_sa=$4
gcloud_sa_key=$5
gke=$6
gke_zone=$7
gcloud_sa_key_path=key.json


mv $source_dir marbles-api

cd $source_dir

cat > key.json <<EOF
$gcloud_sa_key
EOF


gcloud auth activate-service-account $gcloud_sa --key-file=$gcloud_sa_key_path --project=$gcloud_project
echo gcloud container clusters get-credentials $gke --zone $gke_zone --project $gcloud_project
gcloud container clusters get-credentials $gke --zone $gke_zone --project $gcloud_project

make $make_cmd
