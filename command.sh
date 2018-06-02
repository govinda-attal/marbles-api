#!/bin/bash

make_cmd=$1
gcloud_project= $2
gcloud_sa_key_path=$3

gcloud gcloud auth activate-service-account test-service-account@google.com --key-file=$gcloud_sa_key_path --project=$gcloud_project

cd $(ls | head -n1)

make_cmd=$1

make $make_cmd
