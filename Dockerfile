# FROM wordpress:5.2.4-php7.3-apache
FROM wordpress:5.3.2-php7.3-apache

# Below, we remove the 'exec'  instruction from original docker-entrypoint.sh ,
#   which will help us inject our own script in the container,
#   which, in-turn calls the original docker-entrypoint.sh.
# Use the php.ini-production as the default php.ini file. 
# * The PHP_INI_DIR variable is already defined in this docker image by upstream.
# Also install OS tools, e.g. unzip,  git, etc.
# Also do othe prep work on the OS before we do anything else.

RUN sed -i '/^exec/d' /usr/local/bin/docker-entrypoint.sh \
    && mkdir /usr/src/themes /usr/src/plugins  /docker-entrypoint.d \
    && apt-get update && apt-get -y install git unzip && apt-get clean \
    && mv ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini


# Override PHP settings with a custom configuration file. e.g.
# * Reduce the per-PHP-script memory requirement (memory_limit) from 128 M to 32 M.
# * Set correct date.timezone
COPY php-custom-config.ini $PHP_INI_DIR/conf.d/


# The "copy themes & plugins" cannot be part of a generic image, nor in generic Dockerfile.
# BUT, it can be part of Dockerfile, which will be based on this generic image. 
# Copy themes and plugins from the repository to a fixed place inside the container image.
# The themes and plugins will be processed by the our wordpress-custom-entrypoint.sh script,
#   when the container starts.
# COPY themes /usr/src/themes/
# COPY plugins /usr/src/plugins/ 

# This will stay in this Dockerfile.
# Copy the "docker-entrypoint.d" directory holding all the custom scripts - to / .
COPY docker-entrypoint.d /docker-entrypoint.d/

# Copy our custom entrypoint script to /usr/local/bin/
COPY wordpress-custom-entrypoint.sh /usr/local/bin/

# Copy MPM-prefork with custom/tuned values for resource usage.
# Modify this file to increase the resource utilization.
COPY mpm_prefork.conf  /etc/apache2/mods-enabled/mpm_prefork.conf

# We run our own wordpress-custom-docker-entrypoint.sh, 
# which first calls the actual docker-entrypoint.sh and then runs our theme and plugin management logic.
#  When ENTRYPOINT is present in a dockerfile, it is always run before executing CMD.
ENTRYPOINT ["/usr/local/bin/wordpress-custom-entrypoint.sh"]

# ######################################################################################################
# Enable the following if you want to run wordpress's own docker-entrypoint.sh.
# If you choose to do this, then remember to disable/remove the sed in the beginning of this Dockerfile,
#   which removes a key (exec) instruction from official docker-entrypoint.sh .
# ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
# ######################################################################################################

# Run apache in foreground as the last process in the container.
CMD ["apache2-foreground"]
