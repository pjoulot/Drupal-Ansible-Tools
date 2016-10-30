#!/bin/bash

#LXC name (use in lxc url)
DOMAIN=$1
if [ -z "$1" ]; then
    read -p "Enter the name of your lxc                         : " DOMAIN
fi
#PHP pakage
TEMPLATE=$2
if [ -z "$2" ]; then
    read -p "Enter the template of your lxc(exemple: debian): " TEMPLATE
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

DRUPAL_PROFILE=$7
if [ -z "$7" ]; then
    read -p "What drupal profile do you want? minimal or standard (default: minimal): " DRUPAL_PROFILE
fi

if [ "$DRUPAL_PROFILE" != "standard" ]; then
    DRUPAL_PROFILE="minimal"
fi

VARNISH_ENABLE=$8
if [ -z "$8" ]; then
    read -p "Do you want to install Varnish? Y or N (default: yes): " VARNISH_ENABLE
fi

if [ "$VARNISH_ENABLE" == "N" ] || [ "$VARNISH_ENABLE" == "n" ] || [ "$VARNISH_ENABLE" == "no" ]; then
    APACHE_PORT=80
else
    VARNISH_PORT=80
    APACHE_PORT=81
fi

USER_NAME=$9
if [ -z "$9" ]; then
    read -p "Enter the user name that you want for developping (default: drupal): " USER_NAME
fi
if [ -z "$USER_NAME" ]; then
    USER_NAME="drupal"
fi

echo "LXC URL: $URL"
#Deploy LXC with smile package and add it to ansible inventory to be managed
sudo lxc-create -n $DOMAIN -t $TEMPLATE
sudo lxc-start -n $DOMAIN &
echo "Wait that the lxc container is ready..."
# Todo Correct me and listen when the container is started
sleep 5
sudo bash install-keys.sh $DOMAIN

echo "Clean in case an lxc with the same name has already been created before"
sed "/$URL/d" ./inventory/dev/hosts > ./inventory/dev/hosts
#Erase the file, find why
#sudo sh -c "sed '/$URL/d' /etc/hosts > /etc/hosts"
ssh-keygen -f "/home/`whoami`/.ssh/known_hosts" -R $URL

# Add an alias to be more user friendly than the  IP Address

IP_LXC="$(sudo lxc-info -n $DOMAIN | grep ^IP | awk '{print $2}')"
echo "The container is running on: ${IP_LXC}"
sudo sh -c "echo \"# Alias for the lxc $DOMAIN\" >> /etc/hosts && echo \"${IP_LXC} $DOMAIN.lxc\" >> /etc/hosts"

echo "$URL ansible_connection=ssh ansible_user=root" >> ./inventory/dev/hosts && echo "Your project $DOMAIN can now be manage by ansible"

# Install python into the container in order to launch ansible
ssh -p 22 "root@$URL" "apt-get update; apt-get install python -y;"

# Launch ansible
ansible-playbook -i inventory/dev  site.yml --extra-vars "project=$DOMAIN project_url=$URL project_vhost=$VHOST gitpath=$GIT project_integ=test project_name=$PROJECT_NAME drupal_dbname=$DRUPAL_DBNAME drupal_dbuser=$DRUPAL_DBUSER drupal_dbpass=$DRUPAL_DBPASS drupal_profile=$DRUPAL_PROFILE varnish_port=$VARNISH_PORT apache_port=$APACHE_PORT user_name=$USER_NAME"

