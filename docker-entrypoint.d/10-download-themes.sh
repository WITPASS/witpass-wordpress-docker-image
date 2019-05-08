#!/bin/bash -x
# set -x to enable debugging
echo
echo "-----> Downloading themes - if any ..."
echo 

# Download themes using the download.list file:
if [ -r ${THEMES_DOWNLOAD_FILE} ] && [ -d ${THEMES_TARGET_DIR} ] ; then
  echo "Found a file with list of themes to download as: ${THEMES_DOWNLOAD_FILE} . Processing file ..."

  # If grep does not find anything it exits with exit code 1, 
  #   which is ok in general, but docker execution of script fails unexpectedly.
  #   Therefore, it is important to OR true (|| true) every possibility of exit code 1 in the command below:

  THEMES_URL_LIST=$(grep -v \#  ${THEMES_DOWNLOAD_FILE} || true | grep 'http' || true | awk '{print $2}' || true)
  
  # Note: the if check below is different from ${VARIABLE+x} , 
  #  because ${VARIABLE+x} checks if variable exists, 
  #  whereas `-z "${VARIABLE}"` checks if variable is null"

  if [ -z "${THEMES_URL_LIST}" ] ; then 
    echo "The themes download file - ${THEMES_DOWNLOAD_FILE} is empty, skipping theme downloads ..."
  else
    for THEME_URL in ${THEMES_URL_LIST}; do 
      echo "Downloading theme-file from URL: ${THEME_URL} ... and saving into ${THEMES_TARGET_DIR}/"
      URL_BASE_NAME=$(basename ${THEME_URL})
      curl -sL ${THEME_URL} -o ${THEMES_TARGET_DIR}/${URL_BASE_NAME}

      # Unzip the file (quitely) and overwrite without asking,
      #  , and remove the zip file, all in a subshell, 
      #  , so scipt's current dir is not affected. 
      # pwd
      ( cd ${THEMES_TARGET_DIR} ; unzip -q -o ${URL_BASE_NAME} ; rm ${URL_BASE_NAME} )
      # pwd
    done
  fi
else
  echo "File with list of themes to download was not found under themes/ directory."
  echo "Or, ${THEMES_TARGET_DIR} was not found in the image."
  echo "Skipping theme download ..."
fi

