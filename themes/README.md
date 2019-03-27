This directory will contain:
* custom themes which we need to place inside the main wordpress Docker container before it starts. Each custom theme will be in it's own subdirectory.
* list of publicly available themes which we need to install in our wordpress container. It needs to contain Name of the theme and the exact URL to download it in the file called `download.list` . The format of the 'download.list' file is that it must have total two columns. A theme name and the URL. If theme name is multiword (`Ocean WP`), then make sure that you remove all spaces in the name of the theme, and make it one word, e.g.  `OceanWP` or `Ocean-WP`. Make sure that the URL is the link to actual zip file, normally found under the blue `Download` button on wordpress website.
* list of  themes in your private github repository, which we need to install in our wordpress container. It needs to contain Name of the theme and the exact URL to download it in the file called `gitrepos.list` . The format of the 'gitrepos.list' file is that it must have total two columns. A theme name and the URL of 'a git repository'. Theme name must be one word, e.g.  `MySuperWPtheme` or `My-Super-WP-theme`.


Here is an example of download.list file:
```
$ cat themes/download.list

# Format of this file is:
# ThemeName   	URL
OceanWP       	https://downloads.wordpress.org/theme/oceanwp.1.6.4.zip
```

Here is an example of gitrepos.list file:
```
$ cat themes/gitrepos.list 
# Format of this file is two columns:
# ThemeName   URL

ExampleTheme       https://github.com/exampleOrg/wp-theme-example.git
```
