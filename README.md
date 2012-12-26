# Description #

Atlassian is the industrie leader for Software development and collaboration tools for teams, from startup to enterprise. And as Web applications become more critical to business functions we need to enshure that this infrastucture is configured propperly and not leave any bugs what are already fixed. So keep it to up to date and do it always the same way so your infrastucture stayes consistance.

This Project astack4atlassian is a simple bash script to secure deploying and updating Atlassians developer applications in less than five minutes.

For more Information to Atlassians Produrcts please visit http://www.atlassian.com .

# Features #

## Dependencies ##
By default the following system packages will be installed and configured:
* Apache Webserver
* Postfix Mail Server
* MySQL Database Server

The script install and update the runtime envirement:
* Oracle Java JRE

The script install and update the database driver:
* MySQL JDBC Driver

## Applications ##
* Jira is the project tracker for teams planning, building and launching great products.
* Confluence connects teams with the content and co-workers they need to get work done, faster.
* Stash is a Git management to create and manage repositories fast and enterprise-grade.
* Crowd is a single sign-on and user identity tool that's easy to use, administer, and integrate.

All applications will be deployed as a standalone installation bundeld with tomcat as the application server.

## Procedures ##

* install applications with the latest stable reslease
* update existing applications to the latest stable reslease
* backup existing mysql database, the home folder and the actual binary folder
* restore 
* purge

# Requirements #

## Platform ##
As the scrip runs with Bash its limited to Linux/Unix Style-Systems only.

The Script is build for the following platforms:
* Debian, Ubuntu

The support for the following Plattforms is comming soon:
* Red Hat, CentOS, Oracle

The Script is tested on the following platforms:
* Debian 6.06
* Ubuntu 12.04.1
* 32 and 64 bit

## Systems ##

* singe System including apllications 
* multiserver setup for all or every apllications 


## Filesystem ##

You need at least 1GB of filesystem space for each application, expect more for each update and backup. The script checks that dependencie beifore each execution.

## System Memory ##

You need at least 1GB of system memory for each application, expect more for each update and backup. The script checks that dependencie before each execution and calculate the memory confuguration for each application and leave some memory out for the database server. 

Be aware that for now the database server needs to tune by your self. 

Consider to use https://github.com/rackerhacker/MySQLTuner-perl .

## Internet Hostnames ##

Ensure that you have one of the following domain name configuration.

The default subdomains are like the following:
* jira.example.com
* confluence.example.com
* stash.example.com
* crowd.example.com

You can chouse alternative subdomains like the following:
* projects.example.com
* wiki.example.com
* git.example.com
* id.example.com

Of course "example.com" is just an example and can be set by an option switch.

# Usage #

    USAGE: astack4atlassian [SUBCOMMAND] [OPTIONS] ...
    
    Subcommands:
    install:        installs the specified applications
    update:         update the specified applications to the latest release
    backup:         backup the current applications
    restore:        restore the specified applications from the latest backup
    purge:          remove all installations including there data, but no system componets
    
    Options:
    --domain:       specifie the your domain, there is no default
    --applications: specifie the applications, the default is: crowd confluence jira stash
    --destination:  specifie the destination folder, the default is: /opt
    --alt-names:    specifie altenative secondary domain names 
    --ext-proxy:    use that switch to export the proxy config for another system
    --debug:        run the script with debugging output
    --verbose:      run the script with developer output
    -h -? --help:   show that help output

## Post Installation ##

The only thing whats not automatic is the post installation process after the firts deployment.

# Why Bash #

## Future Outlook ##
* wider plattform support
* more Applications
* automatic application check to validate update Procedures
* support for different database engines like portgesql and oracle 

# Limitations and Issues #

* Database Server only MySQL
* Web Server only Apache

If you have any questions or recommendations just create a issue at the github repository.
If you want to help have a lock at the github issues section, patches are more than welcome.

# License and Author #

Author: Sebastian Wendel, (<packages@sourceindex.de>)

Copyright: 2012, SourceIndex IT-Serives

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
