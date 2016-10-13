#!/bin/sh

# Load project environment variables.
ENV=dev
. `dirname $0`/env.sh

# Set permissions for all project.
chown -R $USER:$GROUP $PROJECT_PATH
chmod -R 644 $PROJECT_PATH/src
chmod -R +X $PROJECT_PATH/src
chmod -R 644 $PROJECT_PATH/conf
chmod -R +X $PROJECT_PATH/conf

# Set permissions for settings.
if [ -d "$PROJECT_PATH/conf/drupal" ]
then
    chown -R $USER:$APACHE_USER $PROJECT_PATH/conf/drupal
    chmod -R 640 $PROJECT_PATH/conf/drupal
    chmod -R +X $PROJECT_PATH/conf/drupal
fi

# Set permissions for scripts.
chmod +x $PROJECT_PATH/scripts/*
# chmod +x $PROJECT_PATH/conf/solr/*

# Set permissions for media.
if [ -d "$PROJECT_PATH/data/files" ]
then
    chown -R $USER:$APACHE_USER $PROJECT_PATH/data/files
    chmod -R 660 $PROJECT_PATH/data/files
    chmod -R +X $PROJECT_PATH/data/files
fi

# Set permissions for www.
chown -R $USER:$APACHE_USER $WWW_PATH
chmod -R 640 $WWW_PATH
chmod -R +X $WWW_PATH

# Set permissions for log.
if [ -f "/var/log/crontab.log" ]
then
    chown $USER:$APACHE_USER /var/log/crontab.log
    chmod 664 /var/log/crontab.log
fi
chmod -R +r /var/log/
chmod -R +X /var/log/
