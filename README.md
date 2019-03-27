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

# Visual structure of the repository:
Here is the visual structure of the repository:
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

# Build instructions: 
```
[kamran@kworkhorse witpass-wordpress-docker-image]$ docker build -t witline:wordpress-5.1.1-php7.3-apache .
Sending build context to Docker daemon  185.3kB
Step 1/6 : FROM wordpress:5.1.1-php7.3-apache
 ---> 2db7620e78b0
Step 2/6 : RUN sed -i '/^exec/d' /usr/local/bin/docker-entrypoint.sh     && mkdir /usr/src/themes /usr/src/plugins  /docker-entrypoint.d     && apt-get update && apt-get -y install git unzip && apt-get clean
 ---> Using cache
 ---> 40cb3b9751fb
Step 3/6 : COPY docker-entrypoint.d /docker-entrypoint.d/
 ---> 1a20ff8d464a
Step 4/6 : COPY wordpress-custom-entrypoint.sh /usr/local/bin/
 ---> 63f9b763f832
Step 5/6 : ENTRYPOINT ["/usr/local/bin/wordpress-custom-entrypoint.sh"]
 ---> Running in bf448fc249ae
Removing intermediate container bf448fc249ae
 ---> 12dfcf60571f
Step 6/6 : CMD ["apache2-foreground"]
 ---> Running in 87c8c5771605
Removing intermediate container 87c8c5771605
 ---> 07bd5d25f858
Successfully built 07bd5d25f858
Successfully tagged witline:wordpress-5.1.1-php7.3-apache
[kamran@kworkhorse witpass-wordpress-docker-image]$ 
```
