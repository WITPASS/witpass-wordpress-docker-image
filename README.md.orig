# [example_com.online](example_com.online) - a Wordpress based fashion/clothing website
The website is Wordpress based, but this repository will **not** contain any wordpress code. The repository will **not** contain any **content** (**uploads**) either. It will only contain customizations , such as **themes**, **plugins**, etc. The **content** (`uploads`) will be managed by the system administrator on the server. Or, the developer will use example content on his/her own work computer. 

Of-course this repository will also hold a `Dockerfile` and a `docker-compose.yml` file which contains instructions of building a custom image for this repo, and instructions to run it / bring it up - as a service.

The idea is as follows:
* We use standard wordpress docker container from: [https://hub.docker.com/_/wordpress/?tab=description](https://hub.docker.com/_/wordpress/?tab=description)
* We simply provide the DB details to the container image at run time
* We mount the `uploads` directory from docker host to mountpoints inside the wordpress docker container
* We **copy** our themes and plugins inside the docker container before starting it up.
* So, essentially, we will only maintain custom themes and custom plugins in this repository.
* It is expected from the developers/maintainers of this repository, that they will keep the Dockerfile updated with the exact version of the wordpress docker container with which the themes and plugins are compatible. 

## Visual structure of the repository:
Here is the visual structure of the repository:
```
[kamran@kworkhorse wordpress-example_com.online]$ tree -L 2 
.
├── custom-git-issues.sh
├── docker
│   └── docker-entrypoint.sh.orig
├── docker-compose.yml
├── Dockerfile
├── plugins
│   ├── download.list
│   ├── README.md
│   └── woocommerce
├── README.md
├── themes
│   ├── astra
│   ├── download.list
│   └── README.md
└── wordpress-custom-entrypoint.sh
```

# How to use this docker image - summary:

For the impatient :)
* Clone this repo on your computer
* Setup MySQL 5.7 on a server, or on the same computer - ideally as a docker container, and start it. Instructions are in this file. See: "Persistent data in mysql container"
* Build the wordpress image using the Dockerfile. Use any image name and tag you want to use, such as wp-example_com:test. See: "How to run the image"
* Stay in the repository directory.
* Either use `docker run` or `docker-compose up` command to bring up the wordpress container. See: "How to run the image" and "Run the setup with docker-compose"

# How to use this docker image - detailed:

## The environment variables:
This repository contains a Dockerfile, which uses official wordpress docker image (version ? todo). The actual version will keep changing becasue upstream will continue to provide newer images with latest version of wordpress, (and php) as they come out. Details about these variables can be obtained from: [https://hub.docker.com/_/wordpress/](https://hub.docker.com/_/wordpress/)

The following environment variables are used to configure database connection to your wordpress instance. 
* `WORDPRESS_DB_HOST` (The DNS name / IP address of your MySQL database server. On simple docker installations it will **never** be `localhost`)
* `WORDPRESS_DB_USER` (no-brainer :)
* `WORDPRESS_DB_PASSWORD` (no-brainer :)
* `WORDPRESS_DB_NAME` (no-brainer :)
* `WORDPRESS_TABLE_PREFIX` (Normally set to `wp_`)

The following environment variables are used to pass the user-id (`uid`) and group-id (`gid`) of the OS user to the running container, so Apache web server can actually run as that user. 

* `APACHE_RUN_USER` (The value of this variable will be of the format: `#1000`, i.e. a '#' sign and the uid of the OS user, which you can obtain running the `id` command)
* `APACHE_RUN_GROUP` (The value of this variable will be of the format: `#1000`, i.e. a '#' sign and the gid of the OS user, which you can obtain running the `id` command)
* `GITHUB_USER` (The github username which has access to private repositories - regular / plaintext.
* `GITHUB_TOKEN` (The github token for the github user which has access to private repositories - **ENCODED with base64**)

Most of the time these (and APACHE_*) environment variables are the only ones you need to configure for your container to run properly.

Example configuration of these environment variables:

```
WORDPRESS_DB_HOST=db.example.com
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_PASSWORD=secret_password
WORDPRESS_DB_NAME=wp_db
WORDPRESS_TABLE_PREFIX=wp_
APACHE_RUN_USER=#1000
APACHE_RUN_GROUP=#1000
GITHUB_USER=regulargithubusername
GITHUB_TOKEN=base64encodedgithubtoken

```

**Notes:** 
* If the WORDPRESS_DB_NAME specified does not already exist on the given MySQL server, it will be created automatically upon startup of the wordpress container, provided that the WORDPRESS_DB_USER specified has the necessary permissions to create it.
* When you run this image as a container on a docker-host, you should know that the database will **never** be on `localhost`. It will be either running in the host OS as a systemd service, or running as another container on the same docker-host. It may even be a completely different server somewhere on the network. In all these cases, you will need to know the name or IP address where MySQL service is running.

The following variables are used by the apache server inside this image to run as the user-id (`uid`) and group-id (`gid`) of the OS user on the docker host. This is useful for writing to `wp-content/uploads` directory. You may be mounting `uploads` from a directory on your docker-host on `wp-content/uploads` inside the container.

The following environment variables default to unique random SHA1 hashes - if their values are not provided by you. It is ok to leave them empty for most of the cases.
* `WORDPRESS_AUTH_KEY`
* `WORDPRESS_SECURE_AUTH_KEY=`
* `WORDPRESS_LOGGED_IN_KEY`
* `WORDPRESS_NONCE_KEY`
* `WORDPRESS_AUTH_SALT`
* `WORDPRESS_SECURE_AUTH_SALT`
* `WORDPRESS_LOGGED_IN_SALT`
* `WORDPRESS_NONCE_SALT`

Other environment variables:
* `WORDPRESS_DEBUG` (This defaults to disabled, non-empty value such as `1` or `true` will enable WP_DEBUG in wp-config.php)
* `WORDPRESS_CONFIG_EXTRA` (This defaults to nothing. Any *non-empty* value will be embedded verbatim/as-it-is inside wp-config.php)
This `WORDPRESS_CONFIG_EXTRA` variable is especially useful for applying extra configuration values this image does not provide by default such as `WP_ALLOW_MULTISITE`; see docker-library/wordpress#142 for more details) 

(More on `WP_ALLOW_MULTISITE` - todo)

If you are using docker-compose, then you should setup these environment variables in `app.env` environment file . An example of this is provided as `app.env.example` in this repository.

## How to run the image:

**Note:** It is important that the MySQL DB setup is ready before you run the wordpress container. If the MySQL DB container is not setup, the wordpress container will still start, it is just that it will not be able to find any database to connect to! At the moment, I have a mysql container running. More on this - in detail - is further below in this document. 

```
[kamran@kworkhorse tmp]$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                               NAMES
16689e29383b        mysql:5.7             "docker-entrypoint.s…"   About an hour ago   Up About an hour    0.0.0.0:3306->3306/tcp, 33060/tcp   elegant_chandrasekhar
```


To run this wordpress based image, you can use `docker run` command directly , or use `docker-compose up` . The docker run command will need a pre-built image. You can build an image yourself by doing a `docker build` in the git repository of this project:

```
[kamran@kworkhorse example_com.online]$ docker build -t wp-example_com:test .
```

You also need to know your uid and gid. You can find these by running the `id` command:
```
$ id
uid=1000(kamran) gid=1000(kamran) groups=1000(kamran),10(wheel),981(libvirt),1001(docker)
```

Decide on a data directory for wordpress. I use `/home/kamran/tmp/<projectname>` , becasue I can delete the entire tmp when I want. Note this is not `/tmp`, because `/tmp` is erased at every system restart.

```
[kamran@kworkhorse example_com.online]$ mkdir  /home/kamran/tmp/example_com.online/uploads -p

```

Then, a `docker run` command to bring this up will look like the following:

```
[kamran@kworkhorse example_com.online]$ docker run \
  -p 80:80 \
  -v /home/kamran/tmp/example_com.online/uploads:/var/www/html/wp-content/uploads \
  -e WORDPRESS_DB_HOST=172.17.0.1 \
  -e WORDPRESS_DB_USER=user_example_com \
  -e WORDPRESS_DB_PASSWORD=secret \
  -e WORDPRESS_DB_NAME=db_example_com \
  -e WORDPRESS_TABLE_PREFIX=wp_ \
  -e APACHE_RUN_USER='#1000' \
  -e APACHE_RUN_GROUP='#1000' \
  -d wp-example_com:test 
```

Example:

```
[kamran@kworkhorse example_com.online]$ docker run \
>   -p 80:80 \
>   -v /home/kamran/tmp/example_com.online/uploads:/var/www/html/wp-content/uploads \
>   -e WORDPRESS_DB_HOST=172.17.0.1 \
>   -e WORDPRESS_DB_USER=user_example_com \
>   -e WORDPRESS_DB_PASSWORD=secret \
>   -e WORDPRESS_DB_NAME=db_example_com \
>   -e WORDPRESS_TABLE_PREFIX=wp_ \
>   -e APACHE_RUN_USER='#1000' \
>   -e APACHE_RUN_GROUP='#1000' \
>   -d wp-example_com:test 
9b0871be405227112a6feea3e2d762b5808faf3b3f6267352f62954c4574825c

[kamran@kworkhorse example_com.online]$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                               NAMES
9b0871be4052        wp-example_com:test    "/usr/local/bin/word…"   4 seconds ago       Up 3 seconds        0.0.0.0:80->80/tcp                  hardcore_gagarin
16689e29383b        mysql:5.7             "docker-entrypoint.s…"   About an hour ago   Up About an hour    0.0.0.0:3306->3306/tcp, 33060/tcp   elegant_chandrasekhar
```

OK. We have our wordpress container running! Hurray!

Now is the time to reach this web-site using a browser. Use `http://localhost` on your computer to reach this. Alternatively, you can setup a proper hostname for this in your `/etc/hosts` file and reach it using that name instead of localhost, such as `http://example_com.online`. If this is the fresh installation, then you should be able to see Wordpress Welcome screen. If you see a language selection screen instead, then it means the wordpress container was not able to reach the DB using the credentials you provided. In that case you will need to investigate.

Here is an example of setting up a local name resolver on you linux computer:
```
$ cat /etc/hosts
127.0.0.1	localhost	localhost.localdomain
127.0.0.1	example_com.online  www.example_com.online
```

![docs/images/screenshot-01.png](docs/images/screenshot-01.png)

![docs/images/screenshot-02.png](docs/images/screenshot-02.png)

![docs/images/screenshot-03.png](docs/images/screenshot-03.png)

![docs/images/screenshot-04.png](docs/images/screenshot-04.png)


## Run the setup with docker-compose 

**Note:** There are two versions of the `docker-compose.yml` file in this repository. One (`docker-compose.yml.localpc`) is supposed to be used by the devs, and the other is more suited for server. If the devs have the same setup as the server, (e.g. network and proxy setup), then they can use the `docker-compose.yml.server` file by adjusting few things only.

To make sure that we don't make any mistake on the server, the `docker-compose.yml` is setup as a symbolic link to the `docker-compose.yml.server` file.

First kill any wordpress container you have runnng before starting one with docker-compose.

```
[kamran@kworkhorse example_com.online]$ docker kill zen_bardeen 
zen_bardeen
[kamran@kworkhorse example_com.online]$ 
```


If not already in it, change to location of git repo on the file system, which contains our `docker-compose.yml` file :

```
[kamran@kworkhorse ~]$ cd /home/kamran/Projects/Personal/MurtazaSb/wordpress-example_com.online
[kamran@kworkhorse wordpress-example_com.online]$ 
```

Adjust the docker-compose file to use the correct values for the volumes directive.

```
    volumes:
      - /home/kamran/tmp/example_com.online/uploads:/var/www/html/wp-content/uploads
```

Create a copy of `app.env.example` file as  `app.env` and adjust it to use the db credentials of your setup. :

```
[kamran@kworkhorse wordpress-example_com.online]$ cp app.env.example app.env

[kamran@kworkhorse wordpress-example_com.online]$ id
uid=1000(kamran) gid=1000(kamran) groups=1000(kamran),10(wheel),981(libvirt),1001(docker)

[kamran@kworkhorse wordpress-example_com.online]$ cat app.env
WORDPRESS_DB_HOST=172.17.0.1
WORDPRESS_DB_NAME=db_example_com
WORDPRESS_DB_USER=user_example_com
WORDPRESS_DB_PASSWORD=secret
WORDPRESS_TABLE_PREFIX=wp_
APACHE_RUN_USER=#1000
APACHE_RUN_GROUP=#1000
```

Now you are ready to bring up the wordpress container as docker-compose application:

```
[kamran@kworkhorse wordpress-example_com.online]$ docker-compose -f docker-compose.yml.localpc up -d
Creating wordpress-example_comcouk_example_1 ... done

[kamran@kworkhorse wordpress-example_com.online]$ docker-compose ps
              Name                            Command               State         Ports       
----------------------------------------------------------------------------------------------
wordpress-example_comcouk_example_1   /usr/local/bin/wordpress-c ...   Up      0.0.0.0:80->80/tcp
```

To stop the docker-compose application:
```
[kamran@kworkhorse wordpress-example_com.online]$ docker-compose -f docker-compose.yml.localpc stop 
[kamran@kworkhorse wordpress-example_com.online]$ docker-compose -f docker-compose.yml.localpc rm -f
```


# Logs:

Check logs of the containers to investigate for any problems. The following log does not show any problems, i.e. everything seem to be running ok.

```
[kamran@kworkhorse wordpress-example_com.online]$ docker logs -f wordpress-example_comcouk_example_1
WordPress not found in /var/www/html - copying now...
WARNING: /var/www/html is not empty! (copying anyhow)
Complete! WordPress has been successfully copied to /var/www/html

---------------------> Starting wordpress-custom-entrypoint.sh script <--------------------

-----> Processing themes - if any ...

Found a file with list of themes to download as: /usr/src/themes/download.list . Processing file ...
Downloading theme-file from URL: https://downloads.wordpress.org/theme/oceanwp.1.6.4.zip ... and saving into /var/www/html/wp-content/themes//
Found themes directory at location: /usr/src/themes .
Processing various themes directories found under /usr/src/themes ...
Copying theme-directory from location: /usr/src/themes/astra ... to  /var/www/html/wp-content/themes//

-----> Processing plugins - if any ...

Found a file with list of plugins to download as: /usr/src/plugins/download.list . Processing file ...
Downloading plugin-file from URL: https://downloads.wordpress.org/plugin/jetpack.7.1.1.zip ... and saving into /var/www/html/wp-content/plugins//
Found plugins directory at location: /usr/src/plugins . Processing directory ...
Processing various plugins directories found under /usr/src/plugins ...
Copying plugin-directory from location: /usr/src/plugins/woocommerce ... to  /var/www/html/wp-content/plugins//

-------------------------> Finished running wordpress-custom-entrypoint.sh script <----------------------------

AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.19.0.2. Set the 'ServerName' directive globally to suppress this message
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.19.0.2. Set the 'ServerName' directive globally to suppress this message
[Thu Mar 21 15:33:26.275677 2019] [unixd:alert] [pid 145] AH02155: getpwuid: couldn't determine user name from uid 1000, you probably need to modify the User directive
[Thu Mar 21 15:33:26.275972 2019] [unixd:alert] [pid 146] AH02155: getpwuid: couldn't determine user name from uid 1000, you probably need to modify the User directive
[Thu Mar 21 15:33:26.276684 2019] [unixd:alert] [pid 147] AH02155: getpwuid: couldn't determine user name from uid 1000, you probably need to modify the User directive
[Thu Mar 21 15:33:26.276722 2019] [mpm_prefork:notice] [pid 1] AH00163: Apache/2.4.25 (Debian) PHP/7.3.3 configured -- resuming normal operations
[Thu Mar 21 15:33:26.276764 2019] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND'
[Thu Mar 21 15:33:26.277422 2019] [unixd:alert] [pid 148] AH02155: getpwuid: couldn't determine user name from uid 1000, you probably need to modify the User directive
[Thu Mar 21 15:33:26.277444 2019] [unixd:alert] [pid 149] AH02155: getpwuid: couldn't determine user name from uid 1000, you probably need to modify the User directive
172.19.0.1 - - [21/Mar/2019:15:33:30 +0000] "GET /?p=5 HTTP/1.1" 200 6717 "http://example_com.online/" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Safari/537.36"
172.19.0.1 - - [21/Mar/2019:15:33:31 +0000] "GET /wp-content/uploads/2019/03/kamranazeem-praqma-profile.png HTTP/1.1" 200 309159 "http://example_com.online/?p=5" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Safari/537.36"
[Thu Mar 21 15:33:31.283286 2019] [unixd:alert] [pid 151] AH02155: getpwuid: couldn't determine user name from uid 1000, you probably need to modify the User directive
172.19.0.1 - - [21/Mar/2019:15:34:05 +0000] "POST /wp-admin/admin-ajax.php HTTP/1.1" 200 654 "http://example_com.online/wp-admin/post.php?post=5&action=edit" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Safari/537.36"
```



--------------

# MySQL setup:

**Note:** Mysql 8 is not compatible with latest wordpress:5.1.1 . It is best to use MySQL 5.7 .

If you have a database service running somewhere on the network, logon to it as root (or other admin user), and use the following commands to create a fresh database for this wordpress installation.

**Note:** Be careful about using `@'%'` on production db servers. Consult your db/system administrator to get this done correctly.
```
MariaDB [(none)]> create database db_example_com;
Query OK, 1 row affected (0.002 sec)

MariaDB [(none)]> grant all on db_example_com.* to user_example_com@'%' identified by 'secret';
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.001 sec)
```

**Note:** MariaDB is a fork of MySQL. It is exactly the same as mysql. It is actually mysql! :)


You can run a simple MySQL container on your work computer and save yourself time and energy of setting up MySQL yourself. Here is how you would do it:

```
$ docker run \
  -e MYSQL_ROOT_PASSWORD=supersecret \
  -e MYSQL_DATABASE=db_example_com \
  -e MYSQL_USER=user_example_com \
  -e MYSQL_PASSWORD=secret \
  -p 3306:3306 \
  -d mysql:5.7 
```

Example:

Run the mysql:5.7 container.
```
[kamran@kworkhorse ~]$ docker run \
>   -e MYSQL_ROOT_PASSWORD=supersecret \
>   -e MYSQL_DATABASE=db_example_com \
>   -e MYSQL_USER=user_example_com \
>   -e MYSQL_PASSWORD=secret \
>   -p 3306:3306 \
>   -d mysql:5.7 

Unable to find image 'mysql:5.7' locally
8: Pulling from library/mysql
f7e2b70d04ae: Already exists 
. . . 
75b0db54e16c: Pull complete 
Digest: sha256:4589ba2850b93d103e60011fe528fc56230516c1efb4d3494c33ff499505356f
Status: Downloaded newer image for mysql:5.7
cacb95553f0ea36b675d6ffec5ec6b5d5f5fb76f92bb7d8a239104a13840ceb3
```

Verify that the container is running:
```
[kamran@kworkhorse ~]$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                               NAMES
cacb95553f0e        mysql:5.7             "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:3306->3306/tcp, 33060/tcp   lucid_lehmann
```

**Notes:**
* The above command will create the mysql db container, and will also map it's port from your docker-host to the mysql container. So you can use the IP address of your docker0 network from inside the wordpress container. Normally that IP is `172.17.0.1` , but it may be different. 
* The above command will create a fresh DB instance everytime, and database created inside it will be deleted each time mysql container is stopped or dies.
* Other available versions for mysql docker image are `mysql:5.6` and `mysql:5.7`


## Persistent data in mysql container:
To have persistence for the database(s) you create, you should decide about a directory in your computer, which you can use to keep the actual MySQL data files from inside the container. Say that location is: `/home/kamran/tmp/mysql-data-dir`. 

First, you need to ensure that the data directory you chose to use `/home/kamran/tmp/mysql-data-dir` exists, and has correct ownership/permissions so mysql process can write into this directory. For some silly reason, mysql process inside the mysql container runs as `uid 999`. So, you need to ensure that either the directory `/home/kamran/tmp/mysql-data-dir` is owned by user `999` (by doing: `sudo chown 999:999 /home/kamran/tmp/mysql-data-dir`) , OR, simply open the read and write permissions to `everyone` on the test system by doing `chmod a+rwx /home/kamran/tmp/mysql-data-dir` . This may look like a security concern, but it is not. This directory is inside your home directory `/home/kamran` which already has very restricted access. So you do whatever inside your home directory is no one's concern. Besides, this is just for development and testing.

```
[kamran@kworkhorse ~]$ cd tmp/

[kamran@kworkhorse tmp]$ mkdir mysql-data-dir

[kamran@kworkhorse tmp]$ chmod a+rwx mysql-data-dir

[kamran@kworkhorse tmp]$ ls -l | grep mysql
drwxrwxrwx   2 kamran kamran       4096 Mar 21 14:03 mysql-data-dir
```

Then, you would run the mysql container as follows:

```
$ docker run \
  -e MYSQL_ROOT_PASSWORD=supersecret \
  -e MYSQL_DATABASE=db_example_com \
  -e MYSQL_USER=user_example_com \
  -e MYSQL_PASSWORD=secret \
  -v /home/kamran/tmp/mysql-data-dir:/var/lib/mysql \
  -p 3306:3306 \
  -d mysql:5.7 
```

Example:

```
[kamran@kworkhorse tmp]$ docker run   \
  -e MYSQL_ROOT_PASSWORD=supersecret   \
  -e MYSQL_DATABASE=db_example_com   \
  -e MYSQL_USER=user_example_com   \
  -e MYSQL_PASSWORD=secret \
  -v ${PWD}/mysql-data-dir:/var/lib/mysql  \
  -p 3306:3306   -d mysql:5.7 

16689e29383bd96629fcc2998bee31346d2a0a4906b828e1cb81021462d96866
```

Verify that the container is running:
```
[kamran@kworkhorse tmp]$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                               NAMES
16689e29383b        mysql:5.7             "docker-entrypoint.s…"   2 seconds ago       Up 1 second         0.0.0.0:3306->3306/tcp, 33060/tcp   elegant_chandrasekhar
```

If you do a simple file list check on the mysql-data-dir now, you will see that the directory you created is populated with mysql data files. Hurray! 

```
[kamran@kworkhorse tmp]$ ls mysql-data-dir/
 auto.cnf        ca.pem            ibdata1         mysql                server-cert.pem
 binlog.000001   client-cert.pem   ib_logfile0     mysql.ibd            server-key.pem
 binlog.000002   client-key.pem    ib_logfile1     performance_schema   sys
 binlog.index    db_example_com       ibtmp1          private_key.pem      undo_001
 ca-key.pem      ib_buffer_pool   '#innodb_temp'   public_key.pem       undo_002
```

**Note:** 
* If you want to use different versions of mysql (such as 5.6, 5.7, 8) for different projects, then you must have separate data directories for them. e.g. You may want to have the directory setup as `/home/kamran/tmp/mysql-data-5.6/` and `/home/kamran/tmp/mysql-data-8.0`, etc.
* Note that you cannot have two instances of mysql running at the same time *using the same host port `3306`* . 


## You have a db dump for the project?
This site `example_com.online` will be setup as a fresh wordpress website, but say it was an existing website, which you are migrating, then you do a db dump from some existing server. With the container solution, it is very easy to load this dump into a database. First you run the mysql container as shown above. Then, you copy the mysql db dump in the mysql container. Then `exec` into the mysql container and load the data. Simple! Here is how:

First find the sql file you are interested in loading:
```
[kamran@kworkhorse tmp]$ ls -lh example_com.online.sql 
-rw-rw-r-- 1 kamran kamran 7.9M Mar 21 14:17 example_com.online.sql
```

Find the id of the mysql container:
```
[kamran@kworkhorse tmp]$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                               NAMES
16689e29383b        mysql:5.7             "docker-entrypoint.s…"   10 minutes ago      Up 10 minutes       0.0.0.0:3306->3306/tcp, 33060/tcp   elegant_chandrasekhar
```

Copy the `.sql` file inside this container in `/tmp/` :

```
[kamran@kworkhorse tmp]$ docker cp example_com.online.sql elegant_chandrasekhar:/tmp/ 
```

Now, exec into the mysql docker container, and load the `.sql` data file into the related database:

```
[kamran@kworkhorse tmp]$ docker exec -it elegant_chandrasekhar bash

root@16689e29383b:/# 
```

[Optional:] Verify that you can connect to the database using the credentials you provided at container run time:

```
root@16689e29383b:/# mysql -h localhost -u user_example_com -D db_example_com -p                           
Enter password: 
Server version: 5.7.25 MySQL Community Server - GPL

mysql> 

mysql> quit
Bye
```

Ok we can connect to the database. Time to load datafile:

```
root@16689e29383b:/# mysql -h localhost -u user_example_com -D db_example_com -p < /tmp/example_com.online.sql 
Enter password: 
root@16689e29383b:/# 
```

The sql dump was loaded successfully! You can verify by logging in to mysql and doing a `show tables` and some `select` queries on the tables of your choice:

```
root@16689e29383b:/# mysql -h localhost -u user_example_com -D db_example_com -p
Enter password: 
Server version: 5.7.25 MySQL Community Server - GPL

mysql> show tables;
+------------------------------------------------------+
| Tables_in_db_example_com                                |
+------------------------------------------------------+
| wp_commentmeta                                       |
| wp_comments                                          |
| wp_links                                             |
| wp_options                                           |
| wp_postmeta                                          |
| wp_posts                                             |
| wp_revslider_css                                     |
| wp_revslider_layer_animations                        |
. . .
output snipped
. . . 
| wp_woocommerce_shipping_zone_locations               |
| wp_woocommerce_shipping_zone_methods                 |
| wp_woocommerce_shipping_zones                        |
| wp_woocommerce_tax_rate_locations                    |
| wp_woocommerce_tax_rates                             |
+------------------------------------------------------+
70 rows in set (0.00 sec)

mysql> select count(1) from wp_posts;
+----------+
| count(1) |
+----------+
|      192 |
+----------+
1 row in set (0.00 sec)

mysql> 
```


It works! 

**Note:** `example_com.online` is being setup as a fresh website with fresh database. It did not have an existing database. I used some other sample database dump and used it as `example_com.online.sql` . This was just for demonstration. :)


## Using this mysql database as a general mysql service:
This is very much possible. Since you have provided a `MYSQL_ROOT_PASSWORD`, you can log in to this instance and create other databases and other users if needed, just like in any other regular mysql database. One example:

```
root@16689e29383b:/# mysql -h localhost -u root -p                        
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 15
Server version: 5.7.25 MySQL Community Server - GPL

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| db_example_com        |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

mysql> 


mysql> use mysql;
Database changed

mysql> create database db_wbitt;
Query OK, 1 row affected (0.02 sec)


mysql> grant all on db_wbitt.* to user_wbitt@'%' identified by 'secret';
Query OK, 0 rows affected (0.01 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.01 sec)

mysql> quit
Bye
root@16689e29383b:/# 
```

There! you have a new user and a new database in the same database container instance! 


-------- 

**NOTE:** If you find any problems / errors in this document, or if you have suggestions of improvements, please create a ticket/issue with necessary details.
