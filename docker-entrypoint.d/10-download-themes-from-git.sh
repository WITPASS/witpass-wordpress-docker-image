#!/bin/bash
echo
echo "-----> Downloading custom themes from your (private) git repositories - if any ..."
echo 
# Download themes using the download.list file:
# echo "Debug - USE_GIT found as: ${USE_GIT}"

if [ -r ${THEMES_GIT_REPOS_FILE} ] && [ "${USE_GIT}" == "1" ] && [ -d ${THEMES_TARGET_DIR} ] ; then
  echo "Found a file with list of themes to download from git - as: ${THEMES_GIT_REPOS_FILE} . Processing file ..."

  # THEMES_GIT_URL_LIST=$(grep -v '\#' ${THEMES_GIT_REPOS_FILE} | egrep "http|https" | awk '{print $2}')
  THEMES_GIT_URL_LIST=$(cat ${THEMES_GIT_REPOS_FILE} | sed -n '/http/p' | sed '/\#/d' | awk '{print $2}')
  if [ -z "${THEMES_GIT_URL_LIST}" ]; then
    echo "The themes file - ${THEMES_GIT_REPOS_FILE} is empty, skipping themes download ..."
  else

    for THEME_GIT_URL in ${THEMES_GIT_URL_LIST}; do 

      re='^http.*.git$'
      # Note: double brackets!
      if [[ ${THEME_GIT_URL} =~ $re ]]; then
        echo "Syntax of  GIT repository URL ${THEME_GIT_URL} seem to be OK."
      else
        echo "Syntax of GIT repository URL ${THEME_GIT_URL} is not OK." 
  	echo "The URL in the file ${THEMES_GIT_REPOS_FILE} needs to be a git repo - (URL ending in .git) - so we can clone it!"
	echo "Ignoring ${THEME_GIT_URL} ..."
	continue
      fi

      echo "Cloning repository from GIT URL: ${THEME_GIT_URL} ... and saving into ${THEMES_TARGET_DIR}/"
      URL_LHS=$(echo ${THEME_GIT_URL} | awk -F '://' '{print $1}')
      URL_RHS=$(echo ${THEME_GIT_URL} | awk -F '://' '{print $2}')


      FULL_GIT_REPO_URL=$(echo "${URL_LHS}://${GITHUB_CREDENTIALS}@${URL_RHS}")
      # echo "Debug - New URL: ${URL_LHS}://${GITHUB_CREDENTIALS}@${URL_RHS}"
      # echo "Debug - New URL: ${FULL_GIT_REPO_URL}"

      # remove the '.git' from basename to find out the name of the directory which will be created after git pull.
      URL_BASE_NAME=$(basename ${THEME_GIT_URL} | sed 's/\.git$//g')
      # clone the repo (quitely) and move it to target location, all in a subshell, so scipt's current dir is not affected. 
      ( 
        # remove existing directory, else git clone will complain
        rm -fr ${URL_BASE_NAME}  ${THEMES_TARGET_DIR}/${URL_BASE_NAME} 
        git clone ${FULL_GIT_REPO_URL}
        mv ${URL_BASE_NAME} ${THEMES_TARGET_DIR}/
      )
    done
  fi 
else
  echo "Maybe Git is not setup in this container,"
  echo "the file with list of themes to download was not found under themes/ directory,"
  echo "or, ${THEMES_TARGET_DIR} does not exist."
  echo "Skipping theme download ..."
fi


