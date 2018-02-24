#!/bin/bash

#LXC name (use in lxc url)
DOMAIN=$1
if [ -z "$1" ]; then
    read -p "Enter the name of the lxc to destroy                  : " DOMAIN
fi

sudo lxc-stop -n $DOMAIN
sudo lxc-destroy -n $DOMAIN 
sudo sed -i "/$DOMAIN.lxc/d" /etc/hosts
sudo sed -i "/lxc $DOMAIN/d" /etc/hosts