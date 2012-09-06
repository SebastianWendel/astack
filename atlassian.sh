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
APPS="jira confluence stash crowd"
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
# tool stack
#-----------------------------------------------------------------------------------------------------
HOSTNAME="/bin/hostname"
UNAME="/bin/uname"
PRINTF="/usr/bin/printf"
SED="/usr/bin/sed"
DATE="/sbin/date"
CUT="/usr/bin/cut"
CAT="/usr/bin/cat"
AWK="/sbin/awk"
GREP="/usr/bin/grep"
SORT="/usr/bin/sort"
UNIQ="/usr/bin/uniq"
DU="/usr/bin/du"
RM="/sbin/rm"
WC="/usr/bin/wc"
MKDIR="/sbin/mkdir"
SCP="/usr/bin/scp"
TR="/usr/bin/tr"
PING="/usr/sbin/ping"
STAMP_TIME=$(${DATE} +%Y%m%d-%H%M%S)

#-----------------------------------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------------------------------
HOME="${DEST}/${APPS}/data"
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
      -h|-?|--help)     ${PRINTF} "${USAGE}"; exit ;;
      *)                ${PRINTF} "\nERROR: Unknown Option \"$1\" !\n"; ${PRINTF} "\n${USAGE}"; exit 1;;
    esac
    shift
    [ $# -eq 0 ] && break
  done
fi
if [ "${JOB_UPDATE}" == "0" ] || [ "${JOB_UPDATE}" == "" ] && [ "${JOB_INSTALL}" == "0" ] || [ "${JOB_INSTALL}" == "" ] || [ "${JOB_PURGE}" == "0" ] || [ "${JOB_PURGE}" == "" ]; then
  ${PRINTF} "${ERROR}"
  exit 1
fi

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
  DISTRO=$(${UNAME} -s)
  exit 1
fi

# GET KERNEL ARCHITECTURE
case $(${UNAME} -m) in
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
  STAMP_TIME=$(${DATE} +%Y%m%d-%H%M%S)
  ${PRINTF} "${STAMP_TIME} $1\n" >> "${DESTINATION}\${LOGFILE}" 2>&1
}

function checkFilesystem() {
  echo "installMysql"
}

function installApache() {
  echo "installMysql"
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
}

function installApp() {
  cp .install4j/response.varfile
  atlassian-confluence-X.Y.bin -q -varfile response.varfile
}

function createUsers() {
  if [ $(id ${APP}) == "1" ] ; then
    groupadd ${APP} >/dev/null 2>&1
    useradd -r -m -g ${APP} -d ${HOME} ${APP} >/dev/null 2>&1
  fi
}

function deployLatestBin() {
  echo TEST
}

function checkLicense() {
  echo checkLicense
}

function createDatabase() {
  if ! ${MYSQL} -u ${NAME_APP} -e "use ${NAME_APP}"; then
    PASSWORD_SET=$(openssl rand -base64 32 | sha256sum | head -c 32 ; echo)
    #while read_dom; do
    #  if [[ $ENTITY = "Key" ]] ; then
    #     echo $CONTENT
    #  fi
    #done < input.xml
    echo "installMysql" | tee ~/.mysql.passwd
  else
    PASSWORD_GET=(${CAT} ${FOLDER_HOME}\conf\dbconfig.xml | ${SED} -e 's%(^<password>|</password>$)%%g')
  fi
}

function createUsers() {
  if [ $(id ${APP}) == "1" ] ; then
    groupadd ${APP} >/dev/null 2>&1
    useradd -r -m -g ${APP} -d ${HOME} ${APP} >/dev/null 2>&1
  fi
}

function createLogrotate() {
  echo "deployLatestBin"
}

function deployLatestBin() {
  echo "deployLatestBin"
}

function backupDatabase() { 
  mysqldump
}

function backupData() { 
  ${TAR} -zcvf prog-1-jan-2005.tar.gz /home/jerry/prog
}

function restoreLatestData() {
  find ${FOLDER_BACKUP} -name ${BACKUP} -mtime ...
  tar -zxvf prog-1-jan-2005.tar.gz -C /home/jerry/prog
}

function startApp() {
  echo "startApp"
}

function stopApp() {
  echo "stopApp"
}

function purgApp() {
  echo "purgApp"
}

#-----------------------------------------------------------------------------------------------------
# functions calls
#-----------------------------------------------------------------------------------------------------
if [ ${JOB_UPDATE}) -eq 1 ] ; then
  echo "UPDATE TEST"
fi

if [ ${JOB_INSTALL}) -eq 1 ] ; then
  echo "INSTALL TEST"
fi 

log ${DESTINATION}
log ${DISTRO}
log ${ARCH}

#-----------------------------------------------------------------------------------------------------
# notes
#-----------------------------------------------------------------------------------------------------
#http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-5.1.4-x64.bin
#http://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-1.2.2.tar.gz
#wget http://www.atlassian.com/software/jira/download
#http://www.atlassian.com/software/${APP}/downloads/binary/atlassian-${APP}-