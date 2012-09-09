#!/bin/bash
#-----------------------------------------------------------------------------------------------------
# File:         atlassian-setup.sh
# Description:  xxxxxxxxxxxxxxxxxxxxxxx
# Plattform:    Red-Hat,CentOS,Debian,Ubuntu
# Created:      01.09.2012
# Author:       Sebastian Wendel, evobyte IT-Services Hamburg
#-----------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------
# ToDos:
#-----------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------
# configuration (only this section can be changed)
#-----------------------------------------------------------------------------------------------------
APPS="crowd confluence jira stash"
DESTINATION="/opt"
LOGFILE="atlassian-setup.log"

#-----------------------------------------------------------------------------------------------------
# script usage
#-----------------------------------------------------------------------------------------------------
USAGE="USAGE: ${0} [OPTIONS]...

-d --debug:    gibt eine detaillierte Ausgebe zur verarbeitung des Skripts aus
-h -? --help:  gibt diesen Hilfetext aus.

Exit status:
 0  if OK,
 1  if minor problems.\n\n"

ERROR="FEHLER: Ein oder mehrere Vorraussetzungen wurden nicht erfüllt!\n"

#-----------------------------------------------------------------------------------------------------
# script behavior
#-----------------------------------------------------------------------------------------------------
#set -o nounset
#set -o errexit

#-----------------------------------------------------------------------------------------------------
# variable
#-----------------------------------------------------------------------------------------------------
STAMP_TIME=$(date +%Y%m%d-%H%M%S)
JOB_UPDATE=0
JOB_INSTALL=0
JOB_PURGE=0
VERSION_NOW=0
VERSION_UPDATE=0

#-----------------------------------------------------------------------------------------------------
# control structure
#-----------------------------------------------------------------------------------------------------
if [ $# -gt 0 ] ; then
  while true ; do
    case $1 in
      -u|--update)      JOB_UPDATE=1 ;;
      -i|--install)     JOB_INSTALL=1 ;;
      -p|--purge)       JOB_PURGE=1 ;;
      -d|--destination) shift; DESTINATION=$1 ;;
      -x|--debug)       shift; set -x ;;
      -h|-?|--help)     printf "${USAGE}"; exit ;;
      *)                printf "\nERROR: Unknown Option \"$1\" !\n"; printf "\n${USAGE}"; exit 1;;
    esac
    shift
    [ $# -eq 0 ] && break
  done
fi
#if [ "${JOB_UPDATE}" == "0" ] || [ "${JOB_UPDATE}" == "" ] && [ "${JOB_INSTALL}" == "0" ] || [ "${JOB_INSTALL}" == "" ] || [ "${JOB_PURGE}" == "0" ] || [ "${JOB_PURGE}" == "" ]; then
#  printf "${ERROR}"
#  exit 1
#fi

#-----------------------------------------------------------------------------------------------------
# environment
#-----------------------------------------------------------------------------------------------------

# GET WORKING DIRECTORY
SCRIPT="$0"
while [ -h "$SCRIPT" ] ; do
  ls=$(ls -ld "$SCRIPT")
  link=$(expr "$ls" : '.*-> \(.*\)$')
  if expr "$link" : '/.*' > /dev/null; then
    SCRIPT="$link"
  else
    SCRIPT=$(dirname "$SCRIPT")/"$link"
  fi
done
MD_HOME=$(dirname "$SCRIPT")/..
export MD_HOME=$(cd $MD_HOME; pwd)

# GET DISTRIBUTION TYPE
if [ -f /etc/lsb-release ]; then
  . /etc/lsb-release
  DISTRO=$DISTRIB_ID
elif [ -f /etc/debian_version ]; then
  DISTRO=debian
elif [ -f /etc/redhat-release ]; then
  DISTRO="redhat"
else
  DISTRO=$(uname -s)
  exit 1
fi

# GET KERNEL ARCHITECTURE
case $(uname -m) in
x86_64)
  ARCH=64
  ;;
i*86)
  ARCH=32
  ;;
*)
  ARCH=?
  ;;
esac
  
#-----------------------------------------------------------------------------------------------------
# functions
#-----------------------------------------------------------------------------------------------------
function log() {
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  printf "${TIMESTAMP} $1\n" >> "${DESTINATION}\${LOGFILE}" 2>&1
}

function checkFilesystem() {
  echo "installMysql"
}

function installApache() {
  echo "installMysql"
}

function createVhost() {
  echo "createVhost"
#sudo cat > /etc/httpd/conf.d/jenkins.conf << 'EOF'
#<VirtualHost *:80>
#  ServerName        build.dfd-hamburg.de
  # ServerAlias       macrodeployment.dfd-hamburg.de
  # ServerSignature   Off
 
  # ErrorLog      logs/jenkins-error.loge
  # CustomLog     logs/jekins-access.log combined
  # LogLevel      warn
 
  # RewriteEngine On
  # RewriteCond %{HTTPS} off
  # RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}
# </VirtualHost>
 
# <VirtualHost *:443>
  # ServerName        build.dfd-hamburg.de
  # ServerAlias       macrodeployment.dfd-hamburg.de
  # ServerSignature   Off
 
  # SSLEngine     on
  # SSLProtocol   all -SSLv2
  # SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM:+LOW
  # SSLCertificateFile /etc/ssl/certs/eos-build-00.pem
  # SSLCertificateKeyFile /etc/ssl/certs/eos-build-00.key
 
  # ErrorLog      logs/jenkins-error.log
  # CustomLog     logs/jekins-access.log combined
  # LogLevel      warn
 
  # ProxyPass             / http://0.0.0.0:8080/
  # ProxyPassReverse      / http://0.0.0.0:8080/
  # ProxyRequests         Off
 
  # <Proxy http://0.0.0.0:8080/*>
    # Order deny,allow
    # Allow from all
  # </Proxy>
# </VirtualHost>
# EOS
}

function createCerts() {
  openssl genrsa > /etc/ssl/certs/eos-build-00.key
  openssl req -new -x509 -key /etc/ssl/certs/eos-build-00.key -out /etc/ssl/certs/eos-build-00.pem -days 3650
}

function installMysql() {
  #deb http://repo.percona.com/apt VERSION main
  #deb-src http://repo.percona.com/apt VERSION main
  #apt-get update
  #apt-get install percona-server-server-5.5 percona-server-client-5.5 percona-xtrabackup
  
  
  #rpm -Uhv http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm
  #rpm -Uhv http://www.percona.com/downloads/percona-release/percona-release-0.0-1.i386.rpm
  #yum install -y percona-xtrabackup percona-server-server-55-5 percona-server-client-55-5
  
  #cat <<MYSQL_PRESEED | debconf-set-selections
  #mysql-server-5.1 mysql-server/root_password password $MYSQL_PASS
  #mysql-server-5.1 mysql-server/root_password_again password $MYSQL_PASS
  #mysql-server-5.1 mysql-server/start_on_boot boolean true
  #MYSQL_PRESEED
  DEBIAN_FRONTEND=noninteractive apt-get install -f -y mysql-server
  echo "MySQL Password set to '${MYSQL_PASS}'. Remember to delete ~/.mysql.passwd" | tee ~/.mysql.passwd;
  service mysqld restart
}

function installApp() {
  cp .install4j/response.varfile
  atlassian-confluence-X.Y.bin -q -varfile response.varfile
}

function createFolders() {
  if [ ! -d ${DESTINATION}/${1} ] ; then
    mkdir ${DESTINATION}/${1}
  fi
}

function purgeFolders() {
  if [ -d ${DESTINATION}/${1} ] ; then
    rm -rf ${DESTINATION}/${1}
  fi
}

function createCredentials() {
  id -u ${1} > /dev/null 2>&1
  if [ $? -eq 1 ] ; then
    groupadd ${1}
    useradd -s /bin/bash -r -m -g ${1} -d ${DESTINATION}/${1}/data ${1}
  fi
}

function setEnvirement() {
  if [ -f "${DESTINATION}/${1}/data/.profile" ] ; then
    if [ ! $(grep JAVA_HOME "${DESTINATION}/${1}/data/.profile") ] ; then
      echo "export JAVA_HOME=/opt/java/current" >> "${DESTINATION}/${1}/data/.profile"
      echo "export PATH=$PATH:/opt/java/current/bin" >> "${DESTINATION}/${1}/data/.profile"
      if [ ${1} == "stash" ] ; then
        echo "export STASH_HOME=/opt/stash/data" >> "${DESTINATION}/${1}/data/.profile"
      fi
    fi
  fi
}

function purgeCredentials() {
  id -u ${1} >/dev/null 2>&1
  if [ $? -eq 0 ] ; then
    userdel ${1}
  fi
}

function purgeJava() {
  if [ -d "${DESTINATION}/java" ] ; then
    rm -rf "${DESTINATION}/java"
  fi
}

function killApp() {
  if [ ${1} == "crowd" ] ; then
    PID_FILE="/opt/crowd/current/apache-tomcat/work/catalina.pid"
  else
    PID_FILE="/opt/${1}/current/work/catalina.pid"
  fi
  if [ -f ${PID_FILE} ] ; then
    PID=$(cat ${PID_FILE})
    kill -9 ${PID}
  fi
}

function startApp() {
  if [ ${1} == "crowd" ] ; then
    if [ ! -f "/opt/crowd/current/apache-tomcat/work/catalina.pid" ] ; then
      su ${1} -l -c "/opt/crowd/current/start_crowd.sh"
    fi
  else
    if [ ! -f "/opt/${1}/current/work/catalina.pid" ] ; then
      su ${1} -l -c "/opt/${1}/current/bin/start-${1}.sh"
    fi
  fi
}

function deployLatestJava() {
  if [ -f /tmp/jdk-*-linux-*.tar.gz ] ; then
    JAVA_BIN=$(ls /tmp/jdk-*-linux-*.tar.gz)
    JAVA_NAME=$(tar ztvf ${JAVA_BIN} | head -n 1 | awk '{print $6}' | cut -d"/" -f1)
    if [ ! -d "${DESTINATION}/java" ] ; then
      mkdir "${DESTINATION}/java"
    fi
    if [ ! -d "${DESTINATION}/java/${JAVA_NAME}" ] ; then
      tar -xzvf ${JAVA_BIN} -C "${DESTINATION}/java" >/dev/null 2>&1
      ln -fs "${DESTINATION}/java/${JAVA_NAME}" /opt/java/current
      chown -R root:root /opt/java/current/
    fi
  fi
}

function deployLatestBin() {
  rm -f /tmp/${1}.*
  wget https://my.atlassian.com/download/feeds/current/${1}.json -P /tmp >/dev/null 2>&1
  binUrl=$(cat /tmp/${1}.json | grep -Po '"zipUrl":.*?[^\\]",'  | grep tar.gz | grep -v cluster | grep -v "\-war." | cut -d"\"" -f4)
  fileName=$(echo ${binUrl} | cut -d"/" -f8 )
  folderName=${fileName%.tar.gz}
  if [ ! -f /tmp/${fileName} ] ; then
    wget ${binUrl} -P /tmp >/dev/null 2>&1
  fi
  tar -xzvf /tmp/${fileName} -C ${DESTINATION}/${1} >/dev/null 2>&1
  if [ ${1} == "jira" ] ; then
    ln -fs "/opt/${1}/${folderName}-standalone" /opt/${1}/current
  else
    ln -fs /opt/${1}/${folderName} /opt/${1}/current
  fi
  chown -R ${1}:${1} "/opt/${1}/current/"
}

function setFixes() {
  if [ ${1} == "crowd" ] ; then
    if [ -f "/opt/crowd/current/apache-tomcat/bin/setenv.sh" ] ; then
      if [ ! $(grep CATALINA_PID "/opt/crowd/current/apache-tomcat/bin/setenv.sh") ] ; then
        cat >> /opt/crowd/current/apache-tomcat/bin/setenv.sh << 'EOF'
# set the location of the pid file
if [ -z "$CATALINA_PID" ] ; then
    if [ -n "$CATALINA_BASE" ] ; then
        CATALINA_PID="$CATALINA_BASE"/work/catalina.pid
    elif [ -n "$CATALINA_HOME" ] ; then
        CATALINA_PID="$CATALINA_HOME"/work/catalina.pid
    fi
fi
export CATALINA_PID

PRGDIR=`dirname "$0"`
if [ -z "$CATALINA_BASE" ]; then
  if [ -z "$CATALINA_HOME" ]; then
    LOGBASE=$PRGDIR
    LOGTAIL=..
  else
    LOGBASE=$CATALINA_HOME
    LOGTAIL=.
  fi
else
  LOGBASE=$CATALINA_BASE
  LOGTAIL=.
fi

PUSHED_DIR=`pwd`
cd $LOGBASE
cd $LOGTAIL
LOGBASEABS=`pwd`
cd $PUSHED_DIR

echo ""
echo "Server startup logs are located in $LOGBASEABS/logs/catalina.out"
EOF
      fi
    fi
  fi
}

function checkLicense() {
  echo checkLicense
}

function createDatabase() {
  #if ! ${MYSQL} -u ${NAME_APP} -e "use ${NAME_APP}"; then
  #  PASSWORD_SET=$(openssl rand -base64 32 | sha256sum | head -c 32 ; echo)
    #while read_dom; do
    #  if [[ $ENTITY = "Key" ]] ; then
    #     echo $CONTENT
    #  fi
    #done < input.xml
    echo "installMysql" | tee ~/.mysql.passwd
  #else
  #  PASSWORD_GET=(cat ${FOLDER_HOME}\conf\dbconfig.xml | sed -e 's%(^<password>|</password>$)%%g')
  #fi
}

function createLogrotate() {
  echo "deployLatestBin"
}

function backupDatabase() { 
  echo "mysqldump"
}

function backupData() { 
  ${TAR} -zcvf prog-1-jan-2005.tar.gz /home/jerry/prog
}

function restoreLatestData() {
  find ${FOLDER_BACKUP} -name ${BACKUP} -mtime ...
  tar -zxvf prog-1-jan-2005.tar.gz -C /home/jerry/prog
}

#-----------------------------------------------------------------------------------------------------
# function calls
#-----------------------------------------------------------------------------------------------------
if [ ${JOB_UPDATE} -eq 1 ] ; then
  echo "UPDATE TEST"
fi

if [ ${JOB_INSTALL} -eq 1 ] ; then
  deployLatestJava
  for APP in ${APPS}; do
    echo "INSTALL ${APP}"
    createFolders ${APP}
    createCredentials ${APP}
    setEnvirement ${APP}
    deployLatestBin ${APP}
    setFixes ${APP}
    startApp ${APP}
  done
fi 

if [ ${JOB_PURGE} -eq 1 ] ; then
  purgeJava
  for APP in ${APPS}; do
    echo "PURGE ${APP}"
    killApp ${APP}
    purgeCredentials ${APP}
    purgeFolders ${APP}
  done
fi 

#log ${DESTINATION}
#log ${DISTRO}
#log ${ARCH}

#-----------------------------------------------------------------------------------------------------
# notes
#-----------------------------------------------------------------------------------------------------
