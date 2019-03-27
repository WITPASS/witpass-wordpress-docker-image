#!/bin/bash

# This script does two things:
# - makes sure that there is an OS user with the uid passed to the container.
# - changes the ownership of the files downloaded during execution of this script.

# If APACHE_RUN_USER and APACHE_RUN_GROUP are set, 
#   then we need to ensure that a user with that ID exists in the container.

echo

if [ -z ${APACHE_RUN_USER+x} ] || [ -z  ${APACHE_RUN_GROUP+x} ] ; then

  echo "APACHE_RUN_USER and/or APACHE_RUN_GROUP are empty. Nothing to do ..."
else
  echo "Found APACHE_RUN_USER=${APACHE_RUN_USER} and APACHE_RUN_GROUP=${APACHE_RUN_GROUP} ..."
  echo "Setting up APACHE to run as APACHE_RUN_USER=${APACHE_RUN_USER} and APACHE_RUN_GROUP=${APACHE_RUN_GROUP}"

  # First we remove any # signs from the APACHE_RUN_USER and APACHE_RUN_GROUP variables.

  user="${APACHE_RUN_USER}"
  group="${APACHE_RUN_GROUP}"

  # strip off any '#' symbol from the user and group variables
  pound='#'
  user="${user#$pound}"
  group="${group#$pound}"

  # Check if it is a number, or a username:

  re='^[0-9]+$'
  if [[ ${user} =~ $re && ${group} =~ $re ]] ; then
     # echo "$user and $group are numeric"
     # In this case, create a new user with this ID.
     # It is important to do this, otherwise apache complains about uid not matching to an existing user.
    
     echo "Creating a user with UID ${user} and GID ${group} ..."
     groupadd -g ${group} site-owner
     useradd -u ${user} -g ${group}  --no-create-home --home-dir /var/www/html site-owner 

     echo "Changing ownership of ${APACHE_DOC_ROOT} to ${user}:${group} - recursively ..." 
     chown -R ${user}:${group} ${APACHE_DOC_ROOT}

  else
     echo "User $user is NOT a number. It is expected that the operator knows about this,"
     echo "  and knows what he/she is doing. So we do nothing about it ..."
  fi

fi 

