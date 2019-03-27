#!/bin/bash
echo
echo "-----> Downloading themes - if any ..."
echo 

# Download themes using the download.list file:
if [ -r ${THEMES_DOWNLOAD_FILE} ] && [ -d ${THEMES_TARGET_DIR} ] ; then
  echo "Found a file with list of themes to download as: ${THEMES_DOWNLOAD_FILE} . Processing file ..."

  THEMES_URL_LIST=$(grep -v '\#' ${THEMES_DOWNLOAD_FILE} | grep 'http' | awk '{print $2}')
  for THEME_URL in ${THEMES_URL_LIST}; do 
    echo "Downloading theme-file from URL: ${THEME_URL} ... and saving into ${THEMES_TARGET_DIR}/"
    URL_BASE_NAME=$(basename ${THEME_URL})
    curl -sL ${THEME_URL} -o ${THEMES_TARGET_DIR}/${URL_BASE_NAME}

    # Unzip the file (quitely) and remove the zip file, all in a subshell, so scipt's current dir is not affected. 
    # pwd
    ( cd ${THEMES_TARGET_DIR} ; unzip -q ${URL_BASE_NAME} ; rm ${URL_BASE_NAME} )
    # pwd
  done
else

  echo "File with list of themes to download was not found under themes/ directory."
  echo "Or, ${THEMES_TARGET_DIR} was not found in the image."
  echo "Skipping theme download ..."
fi

