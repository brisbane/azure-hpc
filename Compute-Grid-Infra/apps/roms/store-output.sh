#!/bin/bash
# Change to echo to print what I would do
export NOOP='echo'

usage() {
   echo -e "Usage $0: {options}"
   echo -e "Options:"
   echo -e "\t-u: user name for the Azure stroage account to use, eg securelinx_ext@marine.ie"
   echo -e "\t-a: Name of storage account, eg romssoftware"
   echo -e "\t-f: Filename in Azure blob storage, e.g roms-output.tar"  
   echo -e "\t-o: Output files location on local disk (default /data/software/ne_atlantic/Data/OUTPUT)"
   echo -e "\t-c: storage directory container name (default poc)"
}

install_azcli () {
   echo "Required to install azcli. Please run the following command"
   curl -L https://aka.ms/InstallAzureCli | bash
   echo "Then run exec -l \$SHELL"
   echo "Then re-run this script"
   exit 1
}

upload_storage() {
$NOOP az  login -u $4
export blob_name=$(basename ${1})
export destination_file=$(basename $1)
export container_name=$2
export file_to_upload=$1
export AZURE_STORAGE_ACCOUNT=$3


echo "Creating the container..."
$NOOP az storage container create --name $container_name

echo "Uploading the file..."
$NOOP az storage blob upload --container-name $container_name --file $file_to_upload --name $blob_name

echo "Listing the blobs..."
$NOOP az storage blob list --container-name $container_name --output table


echo "Done"

}
user=''
password=''
storageaccount=''
outputlocation=/data/software/ne_atlantic/Data/OUTPUT
filename=roms-output.tar
containername=poc

while getopts ":u:a:o:f:c:" opt; do
  case $opt in
    u)
      user="$OPTARG"
      ;;
    a)
      storageaccount="$OPTARG"
      ;;
    o)
      outputlocation="$OPTARG"
      ;;
    f)
      filename="$OPTARG"
      ;;
    c) 
      containername="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    h)
      usage
      exit 0
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
if [ -z "$user" ] || [ -z "$storageaccount" ] || [ -z $outputlocation ] || [ -z "$filename" ]; then
	echo $user
	usage
	exit 1
fi
echo "Running with: "
echo "User=$user"
echo "storageaccount=$storageaccount"
echo "outputlocation=$outputlocation"
echo "filename=$filename"
echo "containername=$containername"
echo "" 

tarlocation=/data
filelocation="$tarlocation/$filename"

which az || install_azcli
$NOOP cd "$outputlocation"
$NOOP tar cf /data/$filename  ./
upload_storage "$filelocation" "$containername" "$storageaccount" "$user" 

