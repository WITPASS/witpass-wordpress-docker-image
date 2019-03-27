#!/bin/bash

########### START - user variables #####################
#

# User is expected to pass GITHUB_USER and GITHUB_TOKEN variables as environment variables "if" git repos need to be downloaded.
# GITHUB_USER and GITHUB_TOKEN will never be setup in this script.


#
########### END - user variables #####################


########### START - system variables #####################
#

THEMES_SOURCE_DIR="/usr/src/themes"
PLUGINS_SOURCE_DIR="/usr/src/plugins"

THEMES_DOWNLOAD_FILE="${THEMES_SOURCE_DIR}/download.list"
PLUGINS_DOWNLOAD_FILE="${PLUGINS_SOURCE_DIR}/download.list"

THEMES_GIT_REPOS_FILE="${THEMES_SOURCE_DIR}/gitrepos.list"
PLUGINS_GIT_REPOS_FILE="${PLUGINS_SOURCE_DIR}/gitrepos.list"


APACHE_DOC_ROOT="/var/www/html"

THEMES_TARGET_DIR="${APACHE_DOC_ROOT}/wp-content/themes/"
PLUGINS_TARGET_DIR="${APACHE_DOC_ROOT}/wp-content/plugins/"

# This is also used in Dockerfile. 
# So if you change here, you have to change there as well.
ENTRYPOINT_DIRECTORY=/docker-entrypoint.d

#
########### END - system variables #####################


######################################################

# Before we run our custom entry point logic, we must run the main docker-entrypoint.sh script in wordpress container.
# Since we will overwrite the entrypoint ourselves and use our custom script, 
# it is imporant to source the main entrypoint in this script, let it do it's thing and then we run our script.

if [ -r /usr/local/bin/docker-entrypoint.sh ]; then
  source /usr/local/bin/docker-entrypoint.sh
fi


############ START - Custom Entrypoint logic ###############

echo
echo "-------------------------> Running  wordpress-custom-entrypoint.sh script <----------------------------"
echo

# Reference: https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
if [ -z ${GITHUB_USER+x} ] || [ -z ${GITHUB_TOKEN+x} ]; then
  echo "GITHUB_USER and/or GITHUB_TOKEN are found to be empty/unset."
  echo "Themes and plugins from private git repositories will not be downloaded becasue of this."
  USE_GIT=0
else
  echo "Found github credentials for user ${GITHUB_USER} ... Setting up git in container ..."

  # GITHUB_USER is plaintext/regular in app.env (eg. john)
  # GITHUB_TOKEN is base64 encoded when picked from app.env . 
  # It need to be decoded before they are used.
  
  # GITHUB_CREDENTIALS=${GITHUB_USER}:${GITHUB_TOKEN}
  GITHUB_CREDENTIALS=${GITHUB_USER}:$(echo ${GITHUB_TOKEN} | base64 -d)

  # echo "Debug - GITHUB_CREDENTIALS are set as: ${GITHUB_CREDENTIALS}"

  # We will use: git clone https://user:token@github.com/org/repo.git
  # or: git clone https://$GITHUB_CREDENTIALS@github.com/org/repo.git

  USE_GIT=1
fi

echo


# Only run the theme and plugin copying scipts, if there is a wp-content directory under APACHE_DOC_ROOT. 
if [ -d ${APACHE_DOC_ROOT}/wp-content ]; then

  echo "Calling/source-ing all custom scripts from the ${ENTRYPOINT_DIRECTORY} directory - if there are any ...." 
  for SCRIPTFILE in $(find ${ENTRYPOINT_DIRECTORY} -name "*.sh" | sort -n); do
    echo
    echo "=====> Running script file: ${SCRIPTFILE} ..."
    source ${SCRIPTFILE} 
  done

else

  echo "There is no wordpress content wp-content/ under APACHE_DOC_ROOT: $APACHE_DOC_ROOT."
  echo "So, skipping all scripts under ${ENTRYPOINT_DIRECTORY} which help setup themes and plugins ..."
fi 


# unset all sensitive environment variables. 
# Though unset only works for variables defined in this (script) session.
# Not much useful:
unset GITHUB_USER GITHUB_TOKEN GITHUB_CREDENTIALS 

# Try exporting them with null values:
export GITHUB_USER=""
export GITHUB_TOKEN=""
export GITHUB_CREDENTIALS=""



echo
echo "-------------------------> Finished running wordpress-custom-entrypoint.sh script <----------------------------"
echo

# Run any other commands passed as arguments in CMD in Dockerfile, such as apache2-foreground
exec "$@"
