#!/bin/bash
#-----------------------------------------------------------------------------------------------------
# File:         atlassian.sh
# Description:  xxxxxxxxxxxxxxxxxxxxxxx
# Plattform:    Red-Hat,CentOS,Debian,Ubuntu
# Created:      01.09.2012
# Author:       Sebastian Wendel, evobyte IT-Services Hamburg
#-----------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------
# ToDos:
#-----------------------------------------------------------------------------------------------------
# network timeout
# addadd init script
# restore procedure
# dedicated data path
# check java bin arch
# check java jre free download

#-----------------------------------------------------------------------------------------------------
# configuration (only this section can be changed)
#-----------------------------------------------------------------------------------------------------
APPS="crowd confluence jira stash"
PATH_DEST="/opt"
PATH_BACKUP="${PATH_DEST}/backup"
PATH_JDK="/atlassian"
TEMP="/tmp"
LOGFILE="atlassian-setup.log"
DOMAIN="example.org"
MAXBACKUPS=14

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
TIMESTAMP=$(date +%Y%m%d%H%M%S)
JOB_UPDATE=0
JOB_INSTALL=0
JOB_BACKUP=0
JOB_RESTORE=0
JOB_PURGE=0
VERSION_NOW=0
VERSION_UPDATE=0
PKG_DEBIAN="openssl git xmlstarlet"
PKG_REDHAT=""

#-----------------------------------------------------------------------------------------------------
# control structure
#-----------------------------------------------------------------------------------------------------
if [ $# -gt 0 ] ; then
  while true ; do
    case $1 in
      -u|--update)      JOB_UPDATE=1 ;;
      -i|--install)     JOB_INSTALL=1 ;;
      -b|--backup)      JOB_BACKUP=1 ;;
      -r|--restore)     JOB_RESTORE=1 ;;
      -p|--purge)       JOB_PURGE=1 ;;
      -d|--destination) shift; PATH_DEST=$1 ;;
      -x|--debug)       shift; set -x ;;
      -h|-?|--help)     printf "${USAGE}"; exit ;;
      *)                printf "\nERROR: Unknown Option \"$1\" !\n"; printf "\n${USAGE}"; exit 1;;
    esac
    shift
    [ $# -eq 0 ] && break
  done
fi
#if [ "${JOB_UPDATE}" == "0" ] && [ "${JOB_INSTALL}" == "0" ] && [ "${JOB_PURGE}" == "0" ] ; then
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

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

#-----------------------------------------------------------------------------------------------------
# functions
#-----------------------------------------------------------------------------------------------------
function log() {
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  printf "${TIMESTAMP} $1\n" >> "${PATH_DEST}\${LOGFILE}" 2>&1
}

function checkFilesystem() {
  echo "installMysql"
}

function installTools() {
  if [[ ${DISTRO} == "Ubuntu" || "debian" ]] ; then
    for PKG in ${PKG_DEBIAN} ; do
      if [ ! $(dpkg -s ${PKG} > /dev/null 2>&1) ] ; then 
        apt-get install -y ${PKG} >/dev/null 2>&1
      fi
    done
  fi
}

function installApache() {
  if [[ ${DISTRO} == "Ubuntu" || "debian" ]] ; then
    if [ ! $(dpkg -s apache2 > /dev/null 2>&1) ] ; then 
      apt-get install -y apache2 >/dev/null 2>&1
    fi 
    a2enmod proxy proxy_http ssl rewrite >/dev/null 2>&1
    if [ ! $(grep "NameVirtualHost \*:443" /etc/apache2/ports.conf | grep -v "#" >/dev/null 2>&1) ] ; then
      echo "NameVirtualHost *:443" >> /etc/apache2/ports.conf
    fi
    service apache2 restart >/dev/null 2>&1
  fi
}

function installMySQL() {
  if [[ ${DISTRO} == "Ubuntu" || "debian" ]] ; then
    dpkg -s mysql-server >/dev/null 2>&1
    if [ ! ${?} == "0" ] ; then 
      DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server >/dev/null 2>&1
      export MYSQL_PASS=$(openssl rand -base64 18)
      mysql -uroot -e "UPDATE mysql.user SET password=PASSWORD('${MYSQL_PASS}') WHERE user='root'; FLUSH PRIVILEGES;"; >/dev/null 2>&1
      echo "MySQL root password: ${MYSQL_PASS}"
    fi
  fi
}

function createDatabase() {
  if [[ ${DISTRO} == "Ubuntu" || "debian" ]] ; then
    dpkg -s mysql-server >/dev/null 2>&1
    if [ ${?} == "0" ] ; then
      if [ ! -n "${MYSQL_PASS}" ]; then
        unset MYSQL_PASS
        PROMPT="Please enter MySQL root password: "
        while IFS= read -p "${PROMPT}" -r -s -n 1 CHAR ; do
          if [[ ${CHAR} == $'\0' ]] ; then
            break
          fi
          PROMPT='*'
          MYSQL_PASS+="${CHAR}"
        done
        echo
        export MYSQL_PASS=${MYSQL_PASS}
      fi
    fi
  fi 
  if ! mysql -u root -p${MYSQL_PASS} -Bse "USE '${1}'" >/dev/null 2>&1 ; then
    PASSWORD=$(openssl rand -base64 18)
    Q1="CREATE DATABASE IF NOT EXISTS ${1} CHARACTER SET utf8 COLLATE utf8_general_ci;"
    Q2="GRANT ALL ON *.* TO '${1}'@'localhost' IDENTIFIED BY '${PASSWORD}';"
    Q3="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}${Q3}"
    mysql -u root -p${MYSQL_PASS} -Bse "${SQL}"
    echo "Created database ${1} password: ${PASSWORD}"
  else
    echo "Could not create Database ${1}, maybe it alredy exists!"
  fi
}

function createCerts() {
  if [[ ${DISTRO} == "Ubuntu" || "debian" ]] ; then
    SSL_FOLDER="/etc/ssl/certs"
  else
    SSL_FOLDER="/etc/ssl/certs" # have to be determined
  fi 
  if [ ! $(which openssl) ] ; then 
    apt-get install -y apache2 >/dev/null 2>&1
  fi 
  if [[ ! -f  ${SSL_FOLDER}/${DOMAIN}.key && ${SSL_FOLDER}/${DOMAIN}.pem ]] ; then
    openssl genrsa > ${SSL_FOLDER}/${DOMAIN}.key
    openssl req -new -x509 -key ${SSL_FOLDER}/${DOMAIN}.key -out ${SSL_FOLDER}/${DOMAIN}.pem -days 3650
  fi
}

function createVhost() {
  TOMCAT_CONFIG=$(find ${PATH_DEST}/${1} -name server.xml)
  TOMCAT_PORT=$(xmlstarlet sel -t -m Server/Service/Connector -v @port ${TOMCAT_CONFIG})
  if [[ ${DISTRO} == "Ubuntu" || "debian" ]] ; then
    VHOST_FILE="/etc/apache2/sites-available/${1}"
    SSL_FOLDER="/etc/ssl/certs"
  else
    VHOST_FILE="/etc/httpd/conf.d/${1}"
    SSL_FOLDER="/etc/ssl/certs" # have to be determined
  fi 
  APACHE_LOG_DIR='${APACHE_LOG_DIR}'
  cat > ${VHOST_FILE} << EOF
<VirtualHost *:80>
  ServerName        ${1}.${DOMAIN}
  ServerAdmin       webmaster@${DOMAIN}
  ServerSignature   Off
 
  ErrorLog          ${APACHE_LOG_DIR}/${1}-error.log
  CustomLog         ${APACHE_LOG_DIR}/${1}-access.log combined
  LogLevel          warn
 
  RewriteEngine     On
  RewriteCond       %{HTTPS} off
  RewriteRule       (.*) https://%{HTTP_HOST}%{REQUEST_URI}
</VirtualHost>
 
<VirtualHost *:443>
  ServerName        ${1}.${DOMAIN} 
  ServerAdmin       webmaster@${DOMAIN}
  ServerSignature   Off
 
  SSLEngine         On
  SSLProtocol       -all +SSLv3 +TLSv1
  SSLCipherSuite    SSLv3:+HIGH:+MEDIUM
  SSLCertificateFile ${SSL_FOLDER}/${DOMAIN}.pem
  SSLCertificateKeyFile ${SSL_FOLDER}/${DOMAIN}.key
 
  ErrorLog          ${APACHE_LOG_DIR}/${1}-error.log
  CustomLog         ${APACHE_LOG_DIR}/${1}-access.log combined
  LogLevel          warn

  RewriteEngine     On
  RewriteLogLevel   0
  RewriteLog        ${APACHE_LOG_DIR}/${1}-rewrite.log
  RewriteRule       ^/?$ https://%{HTTP_HOST}/${1}/ [R,L]

  ProxyRequests     Off
  ProxyPreserveHost On
   
  <Proxy *>
    Order deny,allow
    Allow from all
  </Proxy>
        
  ProxyPass         /${1} http://0.0.0.0:${TOMCAT_PORT}/${1}
  ProxyPassReverse  /${1} http://0.0.0.0:${TOMCAT_PORT}/${1}

  <Location /${1}>
    Order allow,deny
    Allow from all
  </Location>
</VirtualHost>
EOF
  if [[ ${DISTRO} == "Ubuntu" || "debian" ]] ; then
    a2ensite ${1} >/dev/null 2>&1
    a2dissite default default-ssl >/dev/null 2>&1
    service apache2 reload >/dev/null 2>&1
  else
    service httpd reload >/dev/null 2>&1
  fi
}

function purgeVhost() {
  if [[ ${DISTRO} == "Ubuntu" || "debian" ]] ; then
    a2dissite ${1} >/dev/null 2>&1
    rm -f /etc/apache2/sites-available/${1} >/dev/null 2>&1
    service apache2 reload >/dev/null 2>&1
  else
    rm -f /etc/apache2/sites-available/${1} >/dev/null 2>&1
    service httpd reload >/dev/null 2>&1
  fi 
}

function createFolders() {
  if [ ! -d ${PATH_DEST}/${1} ] ; then
    mkdir -p ${PATH_DEST}/${1}
  fi
  if [ ! -d ${PATH_BACKUP} ] ; then
    mkdir -p ${PATH_BACKUP}
  fi
}

function purgeFolders() {
  if [ -d ${PATH_DEST}/${1} ] ; then
    rm -rf ${PATH_DEST}/${1}
  fi
}

function createCredentials() {
  id -u ${1} > /dev/null 2>&1
  if [ $? -eq 1 ] ; then
    groupadd ${1}
    useradd -s /bin/bash -r -m -g ${1} -d ${PATH_DEST}/${1}/data ${1}
  fi
}

function setEnvirement() {
  if [ -f "${PATH_DEST}/${1}/data/.profile" ] ; then
    if [ ! $(grep JAVA_HOME "${PATH_DEST}/${1}/data/.profile") ] ; then
      echo "export JAVA_HOME=${PATH_DEST}/java/current" >> "${PATH_DEST}/${1}/data/.profile"
      echo "export PATH=$PATH:${PATH_DEST}/java/current/bin" >> "${PATH_DEST}/${1}/data/.profile"
      if [ ${1} == "stash" ] ; then
        echo "export STASH_HOME=${PATH_DEST}/stash/data" >> "${PATH_DEST}/${1}/data/.profile"
      fi
    fi
  fi
}

function purgeCredentials() {
  id -u ${1} >/dev/null 2>&1
  if [ $? -eq 0 ] ; then
    userdel -f ${1} >/dev/null 2>&1
  fi
}

function purgeJava() {
  if [ -d "${PATH_DEST}/java" ] ; then
    rm -rf "${PATH_DEST}/java"
  fi
}

function stopApp() {
  PID=$(ps -ef | grep ${1} | grep -v "grep" | awk '{print $2}')
  if [ ! "x${PID}" == "x" ] ; then
    while ps ef ${PID} >/dev/null 2>&1 ; do
      kill ${PID} >/dev/null 2>&1
      sleep 2
    done
  fi
}

function startApp() {
  PID=$(ps -ef | grep ${1} | grep -v "grep" | awk '{print $2}')
  if [ "x${PID}" == "x" ] ; then
    if [ ${1} == "crowd" ] ; then
      su ${1} -l -c "${PATH_DEST}/crowd/current/start_crowd.sh >/dev/null 2>&1"
    else
      su ${1} -l -c "${PATH_DEST}/${1}/current/bin/start-${1}.sh >/dev/null 2>&1"
    fi
  fi
}

function deployLatestJava() {
  if [ -f ${TEMP}/jdk-*-linux-*.tar.gz ] ; then
    JAVA_BIN=$(ls ${TEMP}/jdk-*-linux-*.tar.gz)
    JAVA_NAME=$(tar ztvf ${JAVA_BIN} | head -n 1 | awk '{print $6}' | cut -d"/" -f1)
    if [ ! -d "${PATH_DEST}/java" ] ; then
      mkdir "${PATH_DEST}/java"
    fi
    if [ ! -d "${PATH_DEST}/java/${JAVA_NAME}" ] ; then
      tar -xzvf ${JAVA_BIN} -C "${PATH_DEST}/java" >/dev/null 2>&1
      ln -fs "${PATH_DEST}/java/${JAVA_NAME}" ${PATH_DEST}/java/current
      chown -R root:root ${PATH_DEST}/java/current/
    fi
  fi
}

function deployLatestBin() {
  BIN_URL=$(wget -qO- https://my.atlassian.com/download/feeds/current/${1}.json | grep -Po '"zipUrl":.*?[^\\]",'  | grep tar.gz | grep -v cluster | grep -v "\-war." | cut -d"\"" -f4)
  FILE_NAME=$(echo ${BIN_URL} | cut -d"/" -f8 )
  FOLDER_NAME=${FILE_NAME%.tar.gz}
  if [ ! -f ${TEMP}/${FILE_NAME} ] ; then
    wget ${BIN_URL} -P /tmp >/dev/null 2>&1
  fi
  tar -xzvf ${TEMP}/${FILE_NAME} -C ${PATH_DEST}/${1} >/dev/null 2>&1
  if [ ${1} == "jira" ] ; then
    ln -fs "${PATH_DEST}/${1}/${FOLDER_NAME}-standalone" ${PATH_DEST}/${1}/current
  else
    ln -fs ${PATH_DEST}/${1}/${FOLDER_NAME} ${PATH_DEST}/${1}/current
  fi
  chown -R ${1}:${1} "${PATH_DEST}/${1}/current/"
}

function configTomcatProxy() {
  TOMCAT_CONFIG=$(find ${PATH_DEST}/${1} -name server.xml)
  if [ -f ${TOMCAT_CONFIG} ] ; then 
    xmlstarlet ed -L -PS -u "/Server/Service/Engine/Host/Context/@path" -v "/${1}" ${TOMCAT_CONFIG}
    if [ ! $(xmlstarlet sel -t -m Server/Service/Connector -v @proxyName ${TOMCAT_CONFIG})] ; then
      xmlstarlet ed -L -PS -s /Server/Service/Connector -t attr -n proxyName -v ${1}.${DOMAIN} ${TOMCAT_CONFIG}
      xmlstarlet ed -L -PS -s /Server/Service/Connector -t attr -n proxyPort -v 80 ${TOMCAT_CONFIG}
    fi
  fi
}


function setHomes() {
  if [ ${1} == "crowd" ]; then
    echo "${1}.home=${PATH_DEST}/${1}/data" > ${PATH_DEST}/${1}/current/${1}-webapp/WEB-INF/classes/${1}-init.properties
  elif [ ${1} == "confluence" ]; then
    echo "${1}.home=${PATH_DEST}/${1}/data" > ${PATH_DEST}/${1}/current/${1}/WEB-INF/classes/${1}-init.properties
  elif [ ${1} == "jira" ]; then
    echo "${1}.home=${PATH_DEST}/${1}/data" > ${PATH_DEST}/${1}/current/atlassian-${1}/WEB-INF/classes/${1}-application.properties
  fi
}

function setFixes() {
  #find ${PATH_DEST}/${1} -name server.xml -exec sed 's/Host name="localhost"/Host name="127.0.0.1"/g' -i {} \; 
  #find ${PATH_DEST}/${1} -name server.xml -exec sed 's/Engine name="Standalone" defaultHost="localhost"/Engine name="Standalone" defaultHost="127.0.0.1"/g' -i {} \; 
  if [ ${1} == "crowd" ] ; then
    if [ -f "${PATH_DEST}/crowd/current/apache-tomcat/bin/setenv.sh" ] ; then
      if [ ! $(grep CATALINA_PID "${PATH_DEST}/crowd/current/apache-tomcat/bin/setenv.sh") ] ; then
        cat >> ${PATH_DEST}/crowd/current/apache-tomcat/bin/setenv.sh << 'EOF'
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

function createLogrotate() {
  echo "deployLatestBin"
}

function backupDatabase() { 
  echo "mysqldump"
}

function backupData() {
  if [ -d "${PATH_DEST}/${1}" ] && [ -d ${PATH_BACKUP} ] ; then
    tar -zcf ${PATH_BACKUP}/${1}_backup_${TIMESTAMP}.tgz ${PATH_DEST}/${1} >/dev/null 2>&1
    for FILE in $(ls ${PATH_BACKUP}/${1}_backup_*.tgz | head -n-${MAXBACKUPS}) ; do 
      rm -f ${FILE} >/dev/null 2>&1
    done
  fi
}

function restoreLatestData() {
  NEWESTFILE=`ls | awk -F_ '{print $1 $2}' | sort -n -k 2,2 | tail -1`
  find ${FOLDER_BACKUP} -name ${BACKUP} -mtime ...
  tar -zxvf prog-1-jan-2005.tar.gz -C /home/jerry/prog
  filename="db_daily_"`eval date +%Y%m%d`".tgz"
}

#-----------------------------------------------------------------------------------------------------
# function calls
#-----------------------------------------------------------------------------------------------------
if [ ${JOB_UPDATE} -eq 1 ] ; then
  echo "UPDATE TEST"
fi

if [ ${JOB_INSTALL} -eq 1 ] ; then
  installTools
  deployLatestJava
  installApache
  createCerts
  installMySQL
  for APP in ${APPS}; do
    createDatabase ${APP}
    createFolders ${APP}
    createCredentials ${APP}
    setEnvirement ${APP}
    deployLatestBin ${APP}
    configTomcatProxy ${APP}
    setHomes ${APP}
    setFixes ${APP}
    startApp ${APP}
    createVhost ${APP}
    echo "INSTALLED ${APP}"
  done
fi 

if [ ${JOB_BACKUP} -eq 1 ] ; then
  for APP in ${APPS}; do
    stopApp ${APP}
    backupData ${APP}
    startApp ${APP}
  done
fi

if [ ${JOB_RESTORE} -eq 1 ] ; then
  for APP in ${APPS}; do
    backupData ${APP}
  done
fi

if [ ${JOB_PURGE} -eq 1 ] ; then
  purgeJava
  for APP in ${APPS}; do
    stopApp ${APP}
    purgeCredentials ${APP}
    purgeFolders ${APP}
    purgeVhost ${APP}
    echo "PURGED ${APP}"
  done
fi

unset MYSQL_PASS
