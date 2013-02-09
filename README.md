# Description #

Atlassian is the industry leader for Software development and collaboration tools for teams, from startup to enterprise. And as Web applications become more critical to business functions we need to ensure that this infrastructure is configured properly and not leave any bugs that are already fixed. This tool will keep it to up to date and do it always the same way so you're infrastructure stays consistent.

This Project astack for atlassian is a script to securely deploy and update Atlassians developer applications in less than five minutes, like apt or yum.

For more Information to Atlassians Produrcts please visit: http://www.atlassian.com

# Features #

## Dependencies ##
You just need a fresh system installation, described in the Platform section. All dependencies will be handled by the script.

## Functionality ##
For now the Script handles the following tasks:
* Postfix Mail Server installation
* Apache Webserver installation
* Apache Vhost creation
* Apache Disk Cache configuration
* MySQL Database server installation
* MySQL Database creation
* MySQL JDBC Driver installation
* Setup Init scripts
* Oracle Java JVM > 1.7 installation and update
* And of course the installation, configuration and update of the following applications

## Applications ##
* **Jira** is the project tracker for teams planning, building and launching great products.
* **Confluence** connects teams with the content and co-workers that need to get work done, faster.
* **Stash** is Git management to create and manage repositories fast and enterprise-grade.
* **Fisheye** Source browser to monitor and analyze Subversion, Git and Mercurial.
* **Crowd** is a single sign-on and user identity tool that's easy to use, administer, and integrate.

All applications will be deployed as a standalone installation bundled with tomcat as the application server.

## Procedures ##
* **show** shows the latest available version to install
* **install** applications with the latest stable release
* **update** existing applications to the latest stable release
* **backup** existing mysql database, the home folder and the actual binary folder
* **restore** latest mysql database, the home folder and the binary folder
* **purge** the whole application stack, so be careful

# Requirements #

## Platform ##
As the script runs with Bash it's limited to Linux/Unix Style-Systems only.

The Script is build for the following Platforms:
* Debian, Ubuntu

The Script is tested on the following Versions:
* Debian 6.06
* Ubuntu 12.04.1
* 32 and 64 bit

Support for the following Platforms is coming:
* Red Hat, CentOS, Oracle

## Systems ##
There are multiple ways to customize or scale your setup:

### single Node Setup ###
* all specified applications will be installed on the same system
* MySQL Server including all databases will be on the same system
* Apache Webserver as reverse-proxy on the same system

If you expect not that much requests that's your way to go.

### multi Node Setup ###
* run the script on each Node where you wantto install the specified application
* MySQL server including the the Database for the specified application
* Apache web server as reverse-proxy on the same System

### external Reverse-Proxy ###
* you can run each scenario with the external proxy switch

## Filesystem ##

You need at least 1GB of file system space for each application, expect more for updates and backups. The script checks that dependency before each execution.

## System Memory ##

You need at least 1GB of system memory for each application. The script checks that dependency before execution and calculates the memory configuration for each application. It leaves some memory out for the database server. 

Be aware that for now the database server needs to tuned by the user.

Consider using: http://mysqltuner.pl

## Hostnames ##

Ensure that you have one of the following domain name configurations.

The default subdomains are the application names:
* jira.example.com
* confluence.example.com
* stash.example.com
* fisheye.example.com
* crowd.example.com

You can choose alternative subdomains like the following:
* projects.example.com
* wiki.example.com
* git.example.com
* repo.example.com
* id.example.com

Of course "example.com" is just an example and can be set by an option switch to change it to your needs.

# Usage #
To start using astak, download, make it executable and run it:

    wget https://raw.github.com/sourceindex/astack/master/astack
    chmod +x astack
    ./astack

The help output should give you some overview:

    USAGE: astack [SUBCOMMAND] [OPTIONS] ...
    
    Subcommands:
    show            show the latest available version to install
    install         installs the specified applications
    update          updates the specified applications to the latest release
    backup          backups the current applications
    restore         restores the specified applications from the latest backup
    purge           removes all installations including there data, but no system componets
    
    Options:
    --domain        specifies the your domain, there is no default
    --application   specifies the applications, the default is: crowd confluence jira stash
    --destination   specifies the destination folder, the default is: /opt
    --alt-names     specifies altenative secondary domain names 
    --ext-proxy     uses that switch to export the proxy config for another system
    --debug         runs the script with debugging output
    --verbose       runs the script with developer output
    -h -? --help    shows that help output

Some Examples:

    astack show
    astack install --domain example.com
    astack install --domain example.com --alt-names --application "confluence jira"
    astack update --domain example.com --alt-names --ext-proxy
    astack backup
    astack restore

## Post Installation ##

The only things that are not automatic are the Apache ssl settings in your vhost config and post installation process after the first deployment. 

After you finish the installation you can go directly to the Setup process on the wiki:
https://confluence.atlassian.com

## Known Issues ##

If you come to the point where you get this error "crowd unable to login after setup" please read the following information:

https://confluence.atlassian.com/display/CROWDKB/Client+Host+is+Invalid

# Why Bash #
There may be better scripting languages than Bash, but I used Bash because most sysadmins I know understand shell scripting better than C/C++ or Python. I hope to make it easier to understand, debug and maybe get some patches.

# Future Outlook #
I plan to add features like the following:
* wider platform support
* more Atlassian Applications
* automatic application check to validate update procedure
* support for different database engines like PostgreSQL and Oracle

# Limitations and Issues #

* the only supported database server is MySQL
* the only supported web server is Apache

If you have any questions or recommendations just create a issue at the github repository.

https://github.com/sourceindex/astack/issues

If you want to help have a look at the github issues section, patches are more than welcome.

# License and Author #

Author: Sebastian Wendel, (<packages@sourceindex.de>)

Copyright: 2013, SourceIndex IT-Serives

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

![Tracking Pixel](https://tracking.sourceindex.de/piwik.php?idsite=5&amp;rec=1)
