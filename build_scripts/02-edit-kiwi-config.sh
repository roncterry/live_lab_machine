#!/bin/bash
#
# version: 2.1.1
# date: 2019-10-16

##############################################################################
#               Set Global Variables
##############################################################################

#BUILD_TYPE_LIST="iso vmx oem aws azure gce"
BUILD_TYPE_LIST="iso vmx oem azure gce"
#BUILD_TYPE_LIST="iso vmx oem aws"

KIWI_TEMPLATE_DIR="/opt/image_building/templates"
KIWI_EXPORT_DIR="/tmp/kiwi-export"
KIWI_BUILD_BASE_DIR="/tmp/kiwi-build"

if [ -z ${1} ]
then
  source /etc/os-release
  source /etc/liveimage-release
  export OS_IMAGE_NAME="$(echo ${NAME} | sed 's/ /_/g')"
  export VERSION="${VERSION_ID}"
  export LIVE_IMAGE_VERSION="${LIVE_IMAGE_VERSION}"
else
  if [ -e "${KIWI_EXPORT_DIR}/${1}/config.xml" ]
  then
    export OS_IMAGE_NAME="$(grep "<image schemaversion" ${KIWI_EXPORT_DIR}/${1}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 1)"
    export VERSION="$(grep "<image schemaversion" ${KIWI_EXPORT_DIR}/${1}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 2)"
    export LIVE_IMAGE_VERSION="$(grep ".*<version>.*" ${KIWI_EXPORT_DIR}/${1}/config.xml | cut -d \> -f 2 | cut -d \< -f 1)"
  else
    echo
    echo "ERROR:  No Kiwi confguration found in ${1}"
    echo
    exit 1
  fi
fi

##############################################################################
#               Functions
##############################################################################

remove_manually_installed_rpms_from_config() {
  for RPM_FILE in $(ls /inst/rpm) 
  do 
    local RPM_LIST="${RPM_LIST} $(rpm -qpi /inst/rpm/${RPM_FILE} 2>/dev/null | grep -v ^warning | grep ^Name | cut -d \: -f 2)"
  done

  echo
  echo "Removing manually installed packages from config.xml ..."
  echo

  for PACKAGE in ${RPM_LIST}
  do
    #sed -i "s/.*${PACKAGE}.*//g" ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.xml
    sed -i "/.*${PACKAGE}.*/d" ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.xml
  done

  for BUILD_TYPE in ${BUILD_TYPE_LIST}
  do
    if [ -d ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE} ]
    then
      for PACKAGE in ${RPM_LIST}
      do
        sed -i "/.*${PACKAGE}.*/d" ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/config.xml
      done
    fi
  done

  echo
}

update_os_and_version(){
  echo
  echo "Updating OS and Live Image Version in config.xml ..."
  echo

  sed -i "s/localhost/${OS_IMAGE_NAME}-${VERSION}/g" ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.xml
  sed -i "s+^ *<version>.*</version>+    <version>${LIVE_IMAGE_VERSION}</version>+g" ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.xml

  for BUILD_TYPE in ${BUILD_TYPE_LIST}
  do
    if [ -d ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE} ]
    then
      sed -i "s/localhost/${OS_IMAGE_NAME}-${VERSION}/g" ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/config.xml
      sed -i "s+^ *<version>.*</version>+    <version>${LIVE_IMAGE_VERSION}</version>+g" ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/config.xml
    fi
  done

  echo
}

diff_config_xml() {
  echo "--------------------------------------------------------------------"
  echo "Vimdiffing old config.xml [LEFT] with new config.xml [RIGHT]"
  echo "--------------------------------------------------------------------"
  echo
  sleep 2

  if [ -e ${KIWI_TEMPLATE_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.xml ]
  then
    vimdiff ${KIWI_TEMPLATE_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.xml ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.xml
  else
    echo
    echo "No template config.xml found. Skipping"
    echo
  fi
  echo
}

diff_config_xml_buildtype() {
  for BUILD_TYPE in ${BUILD_TYPE_LIST}
  do
    echo "--------------------------------------------------------------------"
    echo "                        [[${BUILD_TYPE}]]"
    echo "Vimdiffing old config.xml [LEFT] with new config.xml [RIGHT]"
    echo "--------------------------------------------------------------------"
    echo
    sleep 2

    if [ -e ${KIWI_TEMPLATE_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.xml.${BUILD_TYPE} ]
    then
      if [ -e ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/config.xml ]
      then
        vimdiff ${KIWI_TEMPLATE_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.xml.${BUILD_TYPE} ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/config.xml
      else
        echo
        echo "No config.xml for ${BUILD_TYPE} found. Skipping"
        echo
      fi
    else
      echo
      echo "No template config.xml.${BUILD_TYPE} found. Skipping"
      echo
    fi
    echo
  done
}

diff_config_sh() {
  echo "--------------------------------------------------------------------"
  echo "Vimdiffing old config.sh [LEFT] with new config.sh [RIGHT]"
  echo "--------------------------------------------------------------------"
  echo
  sleep 2

  if [ -e ${KIWI_TEMPLATE_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.sh ]
  then
    vimdiff ${KIWI_TEMPLATE_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.sh ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.sh
  else
    echo
    echo "No template config.sh found. Skipping"
    echo
  fi
}

diff_config_sh_buildtype() {
  for BUILD_TYPE in ${BUILD_TYPE_LIST}
  do
    echo "--------------------------------------------------------------------"
    echo "                        [[${BUILD_TYPE}]]"
    echo "Vimdiffing old config.sh.${BUILD_TYPE} [LEFT] with new config.sh [RIGHT]"
    echo "--------------------------------------------------------------------"
    echo
    sleep 2

    if [ -e ${KIWI_TEMPLATE_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.sh.${BUILD_TYPE} ]
    then
      if [ -e ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/config.sh ]
      then
        vimdiff ${KIWI_TEMPLATE_DIR}/${OS_IMAGE_NAME}-${VERSION}/config.sh.${BUILD_TYPE} ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/config.sh
      else
        echo
        echo "No config.sh for ${BUILD_TYPE} found. Skipping"
        echo
      fi
    else
      echo
      echo "No template config.sh.${BUILD_TYPE} found. Skipping"
      echo
    fi
    echo
  done
}

#############################################################################

main() {
  echo
  echo "#########################################################################"
  echo "  Editing Kiwi config for: ${OS_IMAGE_NAME}-${VERSION}"
  echo "#########################################################################"
  echo

  if ! echo $* | grep -q no_remove_rpms
  then
    remove_manually_installed_rpms_from_config
  fi

  if ! echo $* | grep -q no_update_os_and_version
  then
    update_os_and_version
  fi

  if ! echo $* | grep -q no_diff_xml
  then
    diff_config_xml
    diff_config_xml_buildtype
  fi

  if ! echo $* | grep -q no_diff_sh
  then
    diff_config_sh
    diff_config_sh_buildtype
  fi
}

##############################################################################
#            Main Code Body
##############################################################################

main $*
