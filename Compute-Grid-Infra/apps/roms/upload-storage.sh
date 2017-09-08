#!/bin/bash
# A simple Azure Storage example script

# ensure az is available
#curl -L https://aka.ms/InstallAzureCli | bash

export AZURE_STORAGE_ACCOUNT=romssoftware

export container_name=poc
export blob_name=$(basename ${1})
export file_to_upload=$1
export destination_file=$(basename $1)

#echo "Creating the container..."
az storage container create --name $container_name

echo "Uploading the file..."
az storage blob upload --container-name $container_name --file $file_to_upload --name $blob_name

echo "Listing the blobs..."
az storage blob list --container-name $container_name --output table

#echo "Downloading the file..."
#az storage blob download --container-name $container_name --name $blob_name --file $destination_file --output table

echo "Done"
