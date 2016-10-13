#!/bin/sh

# Check variables.
if [ -z $WWW_PATH ] || [ -z $ENV ] || [ -z $APACHE_SERVICE ]
then
    echo "$0 : missing parameters"
    exit 1
fi

# Drupal module specific actions.
if [ -d "$WWW_PATH/modules/contrib/robotstxt" ]
then
    rm -f $WWW_PATH/robots.txt
fi

# Launch drush databases update.
drush @$ENV updatedb -y
if [ -n $FEATURES ] && [ $FEATURES = 1 ]
then
    drush @$ENV cr drush
    drush @$ENV fra -y
fi
drush @$ENV locale-check
drush @$ENV locale-update

# Reload config.
if [ -x "$(command -v sudo)" ]
then
    sudo service $APACHE_SERVICE graceful
else
    service $APACHE_SERVICE graceful
fi
