#!/bin/bash
nodes=$(pbsnodes -a | grep ^[0-9a-z])
sudo="sudo -u hpcuser "
if [ $(whoami) == hpcuser ]; then
    sudo=''
fi

for i in  $nodes; do 
    $sudo ssh $i /data/software/poc/post-install-node.sh
done

