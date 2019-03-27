#!/bin/bash

echo
echo "-----> Downloading plugins - if any ..."
echo 

# Download plugins using the download.list file:

if [ -r ${PLUGINS_DOWNLOAD_FILE} ] && [ -d ${PLUGINS_TARGET_DIR} ] ; then
  echo "Found a file with list of plugins to download as: ${PLUGINS_DOWNLOAD_FILE} . Processing file ..."

  PLUGINS_URL_LIST=$(grep -v '\#' ${PLUGINS_DOWNLOAD_FILE} | grep 'http' | awk '{print $2}')
  for PLUGIN_URL in ${PLUGINS_URL_LIST}; do 
    echo "Downloading plugin-file from URL: ${PLUGIN_URL} ... and saving into ${PLUGINS_TARGET_DIR}/"
    URL_BASE_NAME=$(basename ${PLUGIN_URL})
    curl -sL ${PLUGIN_URL} -o ${PLUGINS_TARGET_DIR}/${URL_BASE_NAME}

    # Unzip the file (quitely) and remove the zip file, all in a subshell, so scipt's current dir is not affected. 
    # pwd
    ( cd ${PLUGINS_TARGET_DIR} ; unzip -q ${URL_BASE_NAME} ; rm ${URL_BASE_NAME} )
    # pwd
  done

else
  echo "File with list of plugins to download was not found under plugins/ directory."
  echo "Or, ${PLUGINS_TARGET_DIR} was not found."
  echo "Skipping plugin download ..."
fi

