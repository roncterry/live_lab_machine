#!/bin/bash
#
# version: 1.0.2
# date: 2019-10-16

#############################################################################
#              Global Variables
#############################################################################

### Colors ###
RED='\e[0;31m'
LTRED='\e[1;31m'
BLUE='\e[0;34m'
LTBLUE='\e[1;34m'
GREEN='\e[0;32m'
LTGREEN='\e[1;32m'
ORANGE='\e[0;33m'
YELLOW='\e[1;33m'
CYAN='\e[0;36m'
LTCYAN='\e[1;36m'
PURPLE='\e[0;35m'
LTPURPLE='\e[1;35m'
GRAY='\e[1;30m'
LTGRAY='\e[0;37m'
WHITE='\e[1;37m'
NC='\e[0m'
##############
#echo -e "${LTBLUE}==============================================================${NC}"
#echo -e "${LTBLUE}${NC}"
#echo -e "${LTBLUE}==============================================================${NC}"
#echo -e "${LTCYAN}  -${NC}"
#echo -e "${LTGREEN}COMMAND:${GRAY} ${NC}"
#echo -e "${LTRED}ERROR: ${NC}"
#echo -e "${LTPURPLE}  VAR=${GRAY}${VAR}${NC}"
##############

KIWI_TEMPLATE_DIR="/opt/image_building/templates"
KIWI_EXPORT_DIR="/tmp/kiwi-export"
KIWI_BUILD_BASE_DIR="/tmp/kiwi-build"

#############################################################################
#              Functions
#############################################################################

usage() {
  echo "USAGE: ${0} <image_type> <version_number>"
  echo
  echo "Image Type Options:  iso,vmx"
  echo
}

get_image_name_and_ver() {
  source /etc/os-release
  #source /etc/liveimage-release
  export OS_IMAGE_NAME="$(echo ${NAME} | sed 's/ /_/g')"
  export VERSION="${VERSION_ID}"

  if [ -z ${1} ]
  then
    echo
    echo -e "${LTRED}ERROR: You must provide an image type to update the version number. Exiting.${NC}"
    echo
    usage
    exit
  else
    BUILD_TYPE=${1}
  fi

  if [ -z ${2} ]
  then
    echo
    echo -e "${LTRED}ERROR: You must provide a version number. Exiting.${NC}"
    echo
    usage
    exit
  else
    export LIVE_IMAGE_VERSION="${2}"
  fi

  export ROOTFS_DIR="${KIWI_BUILD_BASE_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/build/image-root"
}

update_version_number() {
  echo -e "${LTCYAN}${ROOTFS_DIR}/image/config.xml${NC}"
  sed -i "s+^        <version>.*+        <version>${LIVE_IMAGE_VERSION}</version>+g" ${ROOTFS_DIR}/image/config.xml
  echo -e "${LTPURPLE}<version>${LIVE_IMAGE_VERSION}</version>${NC}"
  echo

  echo -e "${LTCYAN}${ROOTFS_DIR}/etc/liveimage-release${NC}"
  sed -i "s+^LIVE_IMAGE_VERSION=.*+LIVE_IMAGE_VERSION=${LIVE_IMAGE_VERSION}+g" ${ROOTFS_DIR}/etc/liveimage-release
  echo -e "${LTPURPLE}LIVE_IMAGE_VERSION=${LIVE_IMAGE_VERSION}${NC}"
  echo
}

main() {
  get_image_name_and_ver ${*}
  echo
  echo -e "${LTBLUE}==============================================================${NC}"
  echo -e "${LTBLUE}Updating image version for: ${LTPURPLE}${BUILD_TYPE}${NC}"
  echo -e "${LTBLUE}To version number:          ${LTPURPLE}${LIVE_IMAGE_VERSION}${NC}"
  echo -e "${LTBLUE}==============================================================${NC}"
  echo 
  
  if [ -d ${ROOTFS_DIR} ]
  then
    update_version_number
  else
    echo -e "${LTRED}ERROR: The rootfs for image type ${LTPURPLE}${BUILD_TYPE}${LTRED} doesn't appear to exist. Exiting.${NC}"
    echo
  fi
}


main ${*}
