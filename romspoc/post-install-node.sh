#!/bin/bash
if ! [ -e /opt/intel/compilers_and_libraries_2017.4.196 ]; then
    sudo mkdir -p /opt/intel
    sudo chown hpcuser: /opt
    sudo chown hpcuser: /opt/intel
    ln -s /data/software/intel/compilers_and_libraries_2017.4.196 /opt/intel/compilers_and_libraries_2017.4.196
fi
