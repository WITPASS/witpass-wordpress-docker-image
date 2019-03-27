#!/bin/bash
echo
echo "-----> Copying plugin directories from this repository - if any ..."
echo

# copy individual plugin-directories from inside the 'plugins' directory to  the plugins-target directory:



if [ -d ${PLUGINS_SOURCE_DIR} ]; then

  echo "Found plugins directory at location: ${PLUGINS_SOURCE_DIR} . Processing directory ..."

  PLUGINS_DIR_LIST=$(find ${PLUGINS_SOURCE_DIR} -mindepth 1 -maxdepth 1 -type d)

  if [ -z ${PLUGINS_DIR_LIST+x} ]; then
    echo "The ${PLUGINS_SOURCE_DIR} directory does not seem to have individual theme directories inside it. Skipping ..."
    echo "If this is not what you expected, then ensure that you are copying plugins directory" 
    echo "  from your repo into ${PLUGINS_SOURCE_DIR} in your Dockerfile. e.g:"
    echo "COPY plugins /usr/src/plugins/"
  else
    echo "Processing various plugins directories found under ${PLUGINS_SOURCE_DIR} ..."

    for PLUGIN_DIR in ${PLUGINS_DIR_LIST}; do
      echo "Copying plugin-directory from location: ${PLUGIN_DIR} ... to  ${PLUGINS_TARGET_DIR}/"
      cp -r ${PLUGIN_DIR} ${PLUGINS_TARGET_DIR}/
    done

  fi

else
  echo "The ${PLUGINS_SOURCE_DIR} directory was not found. Skipping plugin copy operation ..."
fi

