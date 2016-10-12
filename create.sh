#!/bin/bash

#LXC name (use in lxc url)
DOMAIN=$1
if [ -z "$1" ]; then
    read -p "Enter the name of your lxc                         : " DOMAIN
fi
#PHP pakage
TEMPLATE=$2
if [ -z "$2" ]; then
    read -p "Enter the template of your lxc(exemple: jessie-php): " TEMPLATE
fi
#URL use
URL="$DOMAIN.lxc"
if [ -z "$3" ]; then
    read -p "Url use to reach drupal (default: $URL)            : " URL_TMP
    if [ -n "$URL_TMP" ]; then
      URL="${URL_TMP}"
    fi
fi
GIT=""
if [ -z "$4" ]; then
    read -p "Enter git path                                     : " GIT
fi

VHOST="${URL}"
if [ -z "$5" ]; then
    read -p "Enter vhost name (default: $URL)                   : " VHOST
fi

PROJECT_NAME="${DOMAIN}"
if [ -z "$6" ]; then
    read -p "Enter project root dir (default: $DOMAIN)         : " PROJECT_NAME
fi

DRUPAL_DBNAME="${DOMAIN}"
if [ -z "$6" ]; then
    read -p "Enter the database name (default: $DOMAIN)          : " DRUPAL_DBNAME
    read -p "Enter the database user name (default: $DOMAIN)     : " DRUPAL_DBUSER
    read -p "Enter the database user password (default: $DOMAIN) : " DRUPAL_DBPASS
fi

VARNISH_ENABLE=$7
if [ -z "$7" ]; then
    read -p "Do you want to activate Varnish? Y or N (default: yes)         : " VARNISH_ENABLE
fi

if [ "$VARNISH_ENABLE" == "N" || "$VARNISH_ENABLE" == "n" || "$VARNISH_ENABLE" == "no" ]; then
    APACHE_PORT=80
else
    VARNISH_PORT=80
    APACHE_PORT=81
fi


echo "LXC URL: $URL"
#Deploy LXC with smile package and add it to ansible inventory to be managed
sudo cdeploy $DOMAIN $TEMPLATE && echo "$URL ansible_connection=ssh ansible_user=root" >> ./inventory/dev/hosts && echo "Your project $DOMAIN can now be manage by ansible"
#Copy the default ssh key into the container
if [ ! -d "/lxc/$DOMAIN/root/.ssh" ]; then
  sudo mkdir -p "/lxc/$DOMAIN/root/.ssh";
  sudo touch "/lxc/$DOMAIN/root/.ssh/authorized_keys"
fi
sudo sh -c 'cat ~/.ssh/id_rsa.pub >> "/lxc/testscript/root/.ssh/authorized_keys"'
ansible-playbook -i inventory/dev  site.yml --extra-vars "project=$DOMAIN project_url=$URL project_vhost=$VHOST gitpath=$GIT project_integ=test project_name=$PROJECT_NAME drupal_dbname=$DRUPAL_DBNAME drupal_dbuser=$DRUPAL_DBUSER drupal_dbpass=$DRUPAL_DBPASS varnish_port=$VARNISH_PORT apache_port=$APACHE_PORT"

