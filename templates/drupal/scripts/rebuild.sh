#!/bin/sh
########## Init variables ##########
# CHECK OPTIONS
for VAR in "$@"
do
    case $VAR in
        info|help )
            echo "Usage: ./`basename $0` [options]"
            echo ""
            echo "  * option 'install' :"
            echo "    Use this option for the first build with Drupal installation."
            echo ""
            echo "  * option '--db-url' :"
            echo "    Use with 'install' option to set database connection information."
            echo "    Example : --db-url=mysql://user:password@localhost/drupal_db"
            echo ""
            echo "  * option '--account-mail' :"
            echo "    Use with 'install' option to set the admin e-mail."
            echo "    Example : --account-mail=admin@example.com"
            echo ""
            exit 0;;
        install )
            INSTALL=1;;
        --db-url* )
            DRUPAL_DB_URL=$(echo $VAR | cut -d "=" -f 2);;
        --account-mail* )
            DRUPAL_ADMIN_MAIL=$(echo $VAR | cut -d "=" -f 2);;
        * )
            echo "Unknown argument '$VAR'.";;
    esac
done

# Load project environment variables.
ENV=dev
. `dirname $0`/env.sh

######### Build Drupal ##########

# Cleanup.
cd $WWW_PATH/..
sudo rm -rf $WWW_PATH

# Build Drupal project.
composer update drupal/core --with-dependencies
cd -

# Remove .txt files
find $WWW_PATH -name "*.txt" -type f -exec rm -rf {} \;

# Remove .htaccess files
find $WWW_PATH -name ".htaccess" -type f -exec rm -rf {} \;



########## Setup Drupal ##########

# Launch drupal install or update.

# Remove files directory (symlink is created later)
sudo rm -rf $WWW_PATH/sites/default/files

# Add Drupal symlinks.

if [ -f "$PROJECT_PATH/conf/drupal/default/settings.local.php" ]
then
    ln -s $PROJECT_PATH/conf/drupal/default/settings.local.php $WWW_PATH/sites/default/settings.local.php
fi

if [ -f "$PROJECT_PATH/conf/drupal/default/local.services.yml" ]
then
    ln -s $PROJECT_PATH/conf/drupal/default/local.services.yml $WWW_PATH/sites/default/local.services.yml
fi

# Fix perms.
sudo `dirname $0`/fix-perms.sh



########## Setup project ##########

# Add Project symlinks.
if [ -d "$PROJECT_PATH/src/modules/custom" ]
then
    ln -s $PROJECT_PATH/src/modules/custom $WWW_PATH/modules/custom
fi
if [ -d "$PROJECT_PATH/src/themes/custom" ]
then
    ln -s $PROJECT_PATH/src/themes/custom $WWW_PATH/themes/custom
fi

# Add Data symlinks.
if [ -d "$PROJECT_PATH/data/files" ]
then
    ln -s $PROJECT_PATH/data/files $WWW_PATH/sites/default/files
fi



########## Update project ##########
. `dirname $0`/update.sh
