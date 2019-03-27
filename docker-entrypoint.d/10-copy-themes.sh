#!/bin/bash
echo
echo "-----> Copying theme directories from this repository - if any ..."
echo

# copy individual theme-directories from inside the 'themes' directory to  the themes-target directory:

if [ -d ${THEMES_SOURCE_DIR} ]; then

  echo "Found themes directory at location: ${THEMES_SOURCE_DIR} ."

  THEMES_DIR_LIST=$(find ${THEMES_SOURCE_DIR} -mindepth 1 -maxdepth 1 -type d)

  if [ -z ${THEMES_DIR_LIST+x} ]; then
    echo "The ${THEMES_SOURCE_DIR} directory does not seem to have individual theme directories inside it. Skipping ..."
    echo "If this is not what you expected, then ensure that you are copying themes  directory"
    echo "  from your repo into ${THEMES_SOURCE_DIR} in your Dockerfile. e.g:"
    echo "COPY themes /usr/src/themes/"
  else
    echo "Processing various themes directories found under ${THEMES_SOURCE_DIR} ..."
    for THEME_DIR in ${THEMES_DIR_LIST}; do
      echo "Copying theme-directory from location: ${THEME_DIR} ... to  ${THEMES_TARGET_DIR}/"
      cp -r ${THEME_DIR} ${THEMES_TARGET_DIR}/
    done
  fi

else
  echo "The main ${THEMES_SOURCE_DIR} directory was not found. Skipping theme copy operation ..."
fi



