#!/bin/bash

echo
echo "-----> Downloading plugins - if any ..."
echo 

# Download plugins using the download.list file:

if [ -r ${PLUGINS_DOWNLOAD_FILE} ] && [ -d ${PLUGINS_TARGET_DIR} ] ; then
  echo "Found a file with list of plugins to download as: ${PLUGINS_DOWNLOAD_FILE} . Processing file ..."


  # If grep does not find anything it exits with exit code 1,
  #   which is ok in general, but docker execution of script fails unexpectedly.
  # So any grep command in a chain of pipes can fail (match not found),
  #   and can case docker-compose to fail during startup.
  #   Therefore, it is important to use 'something' to suppress error mesasges or error exit codes:
  # That something is sed, which does not return exit code 1 in case of match-not-found.

  # The following fails (during docker run only),
  #   , if there are no lines with http (file empty), or there are no lines with # sign. VERY SILLY

  # PLUGINS_URL_LIST=$(grep 'http' ${PLUGINS_DOWNLOAD_FILE}  | grep -v '\#' | awk '{print $2}' )

  PLUGINS_URL_LIST=$(cat ${PLUGINS_DOWNLOAD_FILE} | sed -n '/http/p' | sed '/\#/d' | awk '{print $2}')


  # Note: the if check below is different from ${VARIABLE+x} ,
  #  because ${VARIABLE+x} checks if variable exists,
  #  whereas `-z "${VARIABLE}"` checks if variable is null"

  if [ -z "${PLUGINS_URL_LIST}" ]; then
    echo "The plugins file - ${PLUGINS_DOWNLOAD_FILE} is empty, skipping plugins downloads ..."
  else

    for PLUGIN_URL in ${PLUGINS_URL_LIST}; do 
      echo "Downloading plugin-file from URL: ${PLUGIN_URL} ... and saving into ${PLUGINS_TARGET_DIR}/"
      URL_BASE_NAME=$(basename ${PLUGIN_URL})
      curl -sL ${PLUGIN_URL} -o ${PLUGINS_TARGET_DIR}/${URL_BASE_NAME}

      # Unzip the file (quitely) and overwrite files if exist 
      #   , and remove the zip file, all in a subshell, 
      #   , so scipt's current dir is not affected. 
      # pwd
      ( cd ${PLUGINS_TARGET_DIR} ; unzip -q -o ${URL_BASE_NAME} ; rm ${URL_BASE_NAME} )
      # pwd
    done
  fi

else
  echo "File with list of plugins to download was not found under plugins/ directory."
  echo "Or, ${PLUGINS_TARGET_DIR} was not found."
  echo "Skipping plugin download ..."
fi

