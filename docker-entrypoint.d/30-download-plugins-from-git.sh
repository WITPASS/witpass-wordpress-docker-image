#!/bin/bash
echo
echo "-----> Downloading custom plugins from your (private) git repositories - if any ..."
echo 

# Download plugins using the download.list file:
# echo "Debug - USE_GIT found as: ${USE_GIT}"

if [ -r ${PLUGINS_GIT_REPOS_FILE} ] && [ "${USE_GIT}" == "1" ] && [ -d ${PLUGINS_TARGET_DIR} ] ; then
  echo "Found a file with list of plugins to download from git - as: ${PLUGINS_GIT_REPOS_FILE} . Processing file ..."

  PLUGINS_GIT_URL_LIST=$(grep -v '\#' ${PLUGINS_GIT_REPOS_FILE} | egrep "http|https" | awk '{print $2}')
  for PLUGIN_GIT_URL in ${PLUGINS_GIT_URL_LIST}; do 

    re='^http.*.git$'
    # Note: double brackets!
    if [[ ${PLUGIN_GIT_URL} =~ $re ]]; then

        echo "Syntax of  GIT repository URL ${PLUGIN_GIT_URL} seem to be OK."
      else
        echo "Syntax of GIT repository URL ${PLUGIN_GIT_URL} is not OK." 
	echo "The URL in the ${PLUGIN_GIT_REPOS_FILE} file needs to be a git repo (so we can clone it)"
	echo "Ignoring ${PLUGIN_GIT_URL} ..."
	continue
    fi

    echo "Cloning repository from GIT URL: ${PLUGIN_GIT_URL} ... and saving into ${PLUGINS_TARGET_DIR}/"
    URL_LHS=$(echo ${PLUGIN_GIT_URL} | awk -F '://' '{print $1}')
    URL_RHS=$(echo ${PLUGIN_GIT_URL} | awk -F '://' '{print $2}')


    FULL_GIT_REPO_URL=$(echo "${URL_LHS}://${GITHUB_CREDENTIALS}@${URL_RHS}")
    # echo "Debug - New URL: ${URL_LHS}://${GITHUB_CREDENTIALS}@${URL_RHS}"
    # echo "Debug - New URL: ${FULL_GIT_REPO_URL}"

    # remove the '.git' from basename to find out the name of the directory which will be created after git pull.
    URL_BASE_NAME=$(basename ${PLUGIN_GIT_URL} | sed 's/\.git$//g')
    # clone the repo (quitely) and move it to target location, all in a subshell, so scipt's current dir is not affected. 
    ( 
      # delete any existing directory otherwise git will complain.
      rm -fr ${URL_BASE_NAME}
      git clone ${FULL_GIT_REPO_URL}
      mv ${URL_BASE_NAME} ${PLUGINS_TARGET_DIR}/
    )
  done
else
  echo "Maybe Git is not setup in this container," 
  echo "  or, the file with list of plugins to download was not found under plugins/ directory."
  echo "  or, ${PLUGINS_TARGET_DIR} does not exist."
  echo "Skipping plugin download ..."
fi


