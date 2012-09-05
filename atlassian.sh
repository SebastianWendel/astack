#!/bin/bash
#-----------------------------------------------------------------------------------------------------
# File:         atlassian.sh
# Description:  xxxxxxxxxxxxxxxxxxxxxxx
# Plattform:    xxxxxxxxxxxxxxxxxxxxxxx
# Created:      30.07.2012
# Author:       Sebastian Wendel
#-----------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------
# ToDos:
#-----------------------------------------------------------------------------------------------------
# users
# folders
# download and extract
# check version

#-----------------------------------------------------------------------------------------------------
# configuration (only this section can be changed)
#-----------------------------------------------------------------------------------------------------
APPS="jira confluence stash crowd"
DEST="/opt"
ARCH=64

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
# constants
#-----------------------------------------------------------------------------------------------------
HOME="${DEST}/${APPS}/data"

#-----------------------------------------------------------------------------------------------------
# control structure
#-----------------------------------------------------------------------------------------------------
if [ $# -gt 0 ] ; then
  while true ; do
    case $1 in
      -u|--update)      shift; NAME_TANANT=$(echo $1 | ${TR} '[:lower:]' '[:upper:]') ;;
      -i|--install)     shift; FILE_PRINTERS=$1 ;;
      -d|--debug)       shift; set -x ;;
      -h|-?|--help)     ${PRINTF} "${USAGE}"; exit ;;
      *)                ${PRINTF} "\nERROR: Unknown Option \"$1\" !\n"; ${PRINTF} "\n${USAGE}"; exit 1;;
    esac
    shift
    [ $# -eq 0 ] && break
  done
fi
if [ "${NAME_TANANT}" == "0" ] || [ "${NAME_TANANT}" == "" ] || [ "${NAME_JOB}" == "0" ] || [ "${NAME_JOB}" == "" ]; then
  ${PRINTF} "${ERROR}"
  exit 1
fi

#-----------------------------------------------------------------------------------------------------
# environment
#-----------------------------------------------------------------------------------------------------
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
  
#-----------------------------------------------------------------------------------------------------
# functions
#-----------------------------------------------------------------------------------------------------
function createUsers() {
  if [ $(id ${APP}) == "1" ] ; then
    groupadd ${APP} >/dev/null 2>&1
    useradd -r -m -g ${APP} -d ${HOME} ${APP} >/dev/null 2>&1
  fi
}

function deployLatestBin() {
}

#-----------------------------------------------------------------------------------------------------
# functions calls
#-----------------------------------------------------------------------------------------------------
if [ $(id ${APP}) == "1" ] ; then
  for APP in ${APPS} ; do
    #if [ ! -f ${DEST}/${APP} ] ; then
    #  mkdir -p ${DEST}/${APP} >/dev/null 2>&1
    #fi
  done
fi

#-----------------------------------------------------------------------------------------------------
# notes
#-----------------------------------------------------------------------------------------------------
#http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-5.1.4-x64.bin
#http://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-1.2.2.tar.gz
#http://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-1.2.2.zip
#wget http://www.atlassian.com/software/jira/download
#http://www.atlassian.com/software/${APP}/downloads/binary/atlassian-${APP}-