#!/bin/bash
usage()
{
   echo usage: $0 {url to software tar}
}

blob=https://romssoftware.blob.core.windows.net/poc/roms_data_software.tgz
if [ $1 ]; then
	if [ $1 == '-h' ] || [ $1 == '--help' ];then
             usage
	     exit 0
	else
		blob=$1
	fi
fi
mkdir /data/software
cd /data/software
wget  -O roms_data_software.tgz "$blob"
tar xf roms_data_software.tgz -C /

