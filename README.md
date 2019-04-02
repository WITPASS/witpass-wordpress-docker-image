# What is this image?
A custom wordpress docker image, with following features:
* ablility to copy and install user provided plugins and themes into the docker image
* can run any number of custom scripts; simply place them under `docker-entrypoint.d/`
* our custom script first calls the official wordpress `docker-entrypoint.sh`, and only after that it runs custom scripts
* GITHUB TOKEN to access repository is passed as a base64 encoded string

# How to use this image:
You need to use this image as the base image in the Dockerfile for **your wordpress website**. Then you add two COPY instructions in the Dockerfile, which copies your themes and plugins directories into the image at `/usr/src/themes` and `/usr/src/plugins` locations respectively. e.g:

```
# Copy themes and plugins from the repository to a fixed place inside the container image.
# The themes and plugins will be processed by the our custom entrypoint  scripts,
#   when the container starts.
COPY themes /usr/src/themes/
COPY plugins /usr/src/plugins/
```


```
$ docker-compose -f docker-compose.localpc up -d
```


# Environment variables:
Use `app.env` file to pass environment variables to the docker-compose application.

Ensure that you encode the git token with base64 before placing it in `app.env` . Here is how you can convert your git token into base64 representation:

```
$ MY_GITHUB_TOKEN='thegittokenyouobtainedfromgithub'
$ echo ${MY_GITHUB_TOKEN} | base64 -w 0
```

Copy the output of the last echo command and paste it in `app.env` for the GITHUB_TOKEN variable. **Note:** GITHUB_USER is not encoded with base64.


Here is what the `app.env` file looks like:
```
$ cat app.env
WORDPRESS_DB_HOST=db.example.com
WORDPRESS_DB_NAME=db_sitename
WORDPRESS_DB_USER=user_sitename
WORDPRESS_DB_PASSWORD=secret_password
WORDPRESS_TABLE_PREFIX=wp_
APACHE_RUN_USER=#1000
APACHE_RUN_GROUP=#1000
GITHUB_USER=regulargithubusername
GITHUB_TOKEN=base64encodedgithubtoken
```


# Visual structure of **your** wordpress website's repository:
Here is the visual structure of the wordpress website's repository - using this image.

```
[kamran@kworkhorse wordpress-dgheating.online]$ tree -L 2 
.
├── docker-compose.yml
├── Dockerfile
├── plugins
│   ├── download.list
│   ├── README.md
│   └── gitrepos.list
├── README.md
├── themes
│   ├── gitrepos.list
│   ├── download.list
│   └── README.md
└── app.env
```




# Build instructions for **this** image: 
```
docker build -t witline/wordpress:5.1.1-php-7.3-apache-2.4-v-1.0  -t witline/wordpress:latest . 

```

```
[kamran@kworkhorse witpass-wordpress-docker-image]$ docker build -t witline/wordpress:5.1.1-php-7.3-apache-2.4-v-1.0  -t witline/wordpress:latest .

Sending build context to Docker daemon    194kB
Step 1/6 : FROM wordpress:5.1.1-php7.3-apache
 ---> 2db7620e78b0
Step 2/6 : RUN sed -i '/^exec/d' /usr/local/bin/docker-entrypoint.sh     && mkdir /usr/src/themes /usr/src/plugins  /docker-entrypoint.d     && apt-get update && apt-get -y install git unzip && apt-get clean
 ---> Using cache
 ---> 40cb3b9751fb
Step 3/6 : COPY docker-entrypoint.d /docker-entrypoint.d/
 ---> f581785a6eef
Step 4/6 : COPY wordpress-custom-entrypoint.sh /usr/local/bin/
 ---> 672f94a637c2
Step 5/6 : ENTRYPOINT ["/usr/local/bin/wordpress-custom-entrypoint.sh"]
 ---> Running in 3defb070b770
Removing intermediate container 3defb070b770
 ---> 9a0f17b505db
Step 6/6 : CMD ["apache2-foreground"]
 ---> Running in 4a6ce219e6de
Removing intermediate container 4a6ce219e6de
 ---> 226bcc7d8802
Successfully built 226bcc7d8802
Successfully tagged witline/wordpress:5.1.1-php-7.3-apache-2.4-v-1.0
Successfully tagged witline/wordpress:latest
[kamran@kworkhorse witpass-wordpress-docker-image]$ 
```
