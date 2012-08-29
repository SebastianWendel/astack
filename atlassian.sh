APPS="jira confl crowd"
DEST="/opt"

for APP in ${APPS} ; do
  if [ $(id ${APP}) == "1" ] ; then
    useradd -m ${APP} >/dev/null 2>&1
  fi
  if [ ! -f ${DEST}/${APP} ] ; then
    mkdir -p ${DEST}/${APP} >/dev/null 2>&1
  fi
done
