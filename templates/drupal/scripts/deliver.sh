#!/bin/bash

repourl=""

git clone $repourl /tmp/source
cd /tmp/source
git checkout master


releasename=release-{{ project }}

#PIC ssh key must be on server
mkdir -p /tmp/releases/${releasename}/drupal
cp -R /tmp/source/* /tmp/releases/${releasename}/drupal/
cd /tmp/releases/${releasename}/drupal
composer update

rm -f /tmp/releases/${releasename}/drupal/web/*.txt
#rm -rf /tmp/releases/release-$env-$BUILD_ID/drupal/sites/routing

cd /tmp/releases/

rm -rf /tmp/releases/${releasename}/drupal/composer.lock
rm -rf /tmp/releases/${releasename}/drupal/LICENSE
rm -rf /tmp/releases/${releasename}/drupal/phpunit.xml.dist
rm -rf /tmp/releases/${releasename}/drupal/README.md

rm -rf /tmp/releases/${releasename}/drupal/web/sites/default

tar -zcf ${releasename}.tgz ${releasename}

rm -rf ${releasename}
rm -rf /tmp/source/
echo "The archive is ready to be transfered."

DELIVERY_USER="philippe"
DELIVERY_SERVER="193.70.0.251"
DELIVERY_PORT=22
DELIVERY_FOLDER="{{ project }}"

if [ $DELIVERY_USER = "root" ]
then
  DELIVERY_PATH_PACKAGE="/root"
else
  DELIVERY_PATH_PACKAGE="/home/$DELIVERY_USER"
fi

while ! scp -P $DELIVERY_PORT /tmp/releases/${releasename}.tgz $DELIVERY_USER@$DELIVERY_SERVER:${DELIVERY_PATH_PACKAGE}/releases/; do
  sleep 15
done
commands="cd $DELIVERY_PATH_PACKAGE/releases;"
commands="$commands tar -zxf $releasename.tgz;"
commands="$commands rm -rf /var/www/$DELIVERY_FOLDER/*;"
commands="$commands cp -R $releasename/drupal/* /var/www/$DELIVERY_FOLDER/;"
commands="$commands ln -s /var/www/shared/$DELIVERY_FOLDER /var/www/$DELIVERY_FOLDER/web/sites/$DELIVERY_FOLDER;"
commands="$commands ln -s /var/www/shared/$DELIVERY_FOLDER /var/www/$DELIVERY_FOLDER/web/sites/default;"
commands="$commands chown -R $DELIVERY_USER:www-data /var/www/$DELIVERY_FOLDER;"
commands="$commands rm -f $releasename.tgz;"
commands="$commands rm -rf $releasename;"
commands="$commands cd /var/www/$DELIVERY_FOLDER/web;"
commands="$commands drush cr drush;"
commands="$commands drush updb -y;"
commands="$commands drush cr drush;"
commands="$commands drush entity-updates -y"
commands="$commands drush fra -y; drush cr"
commands="$commands drush locale-check; drush locale-update; drush cr"
ssh $DELIVERY_USER@$DELIVERY_SERVER $commands

echo "Delivered with success."