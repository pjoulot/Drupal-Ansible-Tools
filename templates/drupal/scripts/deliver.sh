#!/bin/sh

########## Init variables ##########

# Default variables initialization.
ENV=;
TAG=;

# CHECK OPTIONS
for VAR in "$@"
do
    case $VAR in
        info|help )
            echo "Usage: ./`basename $0` [options]";
            echo "";
            echo "  * option env :"
            echo "    env=[ENV]               Target environment"
            echo "";
            echo "  * option tag :"
            echo "    tag=[YYYYMMDD_HHMM]     Git tag"
            echo "";
            exit 0;;
        --env* )
            ENV=$(echo $VAR | cut -d "=" -f 2);;
        --tag* )
            TAG=$(echo $VAR | cut -d "=" -f 2);;
        * )
            echo "Unknown argument '$VAR'.";;
    esac
done

# Check variables.
if [ -z "$TAG" ]
then
    echo "missing argument 'tag'."
    exit 0
fi
if [ -z "$ENV" ]
then
    echo "missing argument 'env'."
    exit 0
fi

# Stop executing the script if any command fails.
# See http://stackoverflow.com/a/4346420/442022 for details.
set -e
set -o pipefail

echo "Changing to the environment branch"
git checkout $ENV

echo "Purging local modifications..."
git reset --hard HEAD

echo "Grabbing the latest code from the repository..."
git fetch --tags

echo "Switch to appropriate tag (${TAG})..."
git checkout tags/$TAG

# Create the folder with the files that need to be updated.
mkdir /home/{{ user_name }}/releases/$TAG
mkdir /home/{{ user_name }}/releases/$TAG/web
mkdir /home/{{ user_name }}/releases/$TAG/web/themes
mkdir /home/{{ user_name }}/releases/$TAG/web/modules
mkdir /home/{{ user_name }}/releases/$TAG/web/sites
mkdir /home/{{ user_name }}/releases/$TAG/web/sites/default
# Copy the custom modules
cp -R {{ project_path }}/src/modules/custom /home/{{ user_name }}/releases/$TAG/web/modules/
# Copy the custom themes
cp -R {{ project_path }}/src/themes/custom /home/{{ user_name }}/releases/$TAG/web/themes/
# Copy the composer.json
cp -f {{ project_path }}/conf/drupal/composer.json /home/{{ user_name }}/releases/$TAG/
# Copy the local settings and services files
cp -f {{ project_path }}/conf/drupal/default/settings.local.php /home/{{ user_name }}/releases/$TAG/web/sites/default/
cp -f {{ project_path }}/conf/drupal/default/local.services.yml /home/{{ user_name }}/releases/$TAG/web/sites/default/
