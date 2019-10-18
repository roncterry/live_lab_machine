#!/bin/bash
#
# version: 1.0.3
# date: 2019-10-17

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

REGULAR_USER="tux"
EXTENSIONS_DIR=".local/share/gnome-shell/extensions"
EXTENSIONS_SRC_DIR="/home/${REGULAR_USER}/${EXTENSIONS_DIR}"
SUDO_DIR_LIST="root etc/skel"

#############################################################################
#              Functions
#############################################################################

usage() {
  echo "USAGE: ${0} <image_type>"
  echo
  echo "Image Type Options:  iso,vmx,azure"
  echo
}

get_image_name_and_ver() {
  source /etc/os-release
  source /etc/liveimage-release
  export OS_IMAGE_NAME="$(echo ${NAME} | sed 's/ /_/g')"
  export VERSION="${VERSION_ID}"
  if [ -z ${2} ]
  then
    export LIVE_IMAGE_VERSION="${LIVE_IMAGE_VERSION}"
  fi

  if [ -z ${1} ]
  then
    echo
    echo -e "${LTRED}ERROR: You must provide image type to update the GNOME Shell extensions. Exiting.${NC}"
    echo
    usage
    exit
  else
    export BUILD_TYPE=${1}
  fi
  
  export ROOTFS_DIR="${KIWI_BUILD_BASE_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/build/image-root"
}

update_regular_user() {
  echo -e "${LTCYAN}Updating: ${LTPURPLE}${REGULAR_USER}${NC}"
  echo -e "${LTGREEN}COMMAND:${GRAY} rm -rf ${ROOTFS_DIR}/home/${REGULAR_USER}/${EXTENSIONS_DIR}/*${NC}"
  rm -rf ${ROOTFS_DIR}/home/${REGULAR_USER}/${EXTENSIONS_DIR}/*

  echo -e "${LTGREEN}COMMAND:${GRAY} cp -r ${EXTENSIONS_SRC_DIR}/* ${ROOTFS_DIR}/home/${REGULAR_USER}/${EXTENSIONS_DIR}/${NC}"
  cp -r ${EXTENSIONS_SRC_DIR}/* ${ROOTFS_DIR}/home/${REGULAR_USER}/${EXTENSIONS_DIR}/

  echo -e "${LTGREEN}COMMAND:${GRAY} chown -R ${REGULAR_USER}.users ${ROOTFS_DIR}/home/${REGULAR_USER}/${EXTENSIONS_DIR}/*${NC}"
  chown -R ${REGULAR_USER}.users ${ROOTFS_DIR}/home/${REGULAR_USER}/${EXTENSIONS_DIR}/*
  echo
}

update_sudo_users() {
  for SUDO_DIR in ${SUDO_DIR_LIST}
  do
    echo -e "${LTCYAN}Updating: ${LTPURPLE}${SUDO_DIR}${NC}"
    echo -e "${LTGREEN}COMMAND:${GRAY} rm -rf ${ROOTFS_DIR}/${SUDO_DIR}/${EXTENSIONS_DIR}/*${NC}"
    rm -rf ${ROOTFS_DIR}/${SUDO_DIR}/${EXTENSIONS_DIR}/*

    echo -e "${LTGREEN}COMMAND:${GRAY} cp -r ${EXTENSIONS_SRC_DIR}/* ${ROOTFS_DIR}/${SUDO_DIR}/${EXTENSIONS_DIR}/${NC}"
    cp -r ${EXTENSIONS_SRC_DIR}/* ${ROOTFS_DIR}/${SUDO_DIR}/${EXTENSIONS_DIR}/
    echo
  done
}

main() {
  get_image_name_and_ver ${*}
  echo
  echo -e "${LTBLUE}==============================================================${NC}"
  echo -e "${LTBLUE}Updating the GNOME Shell Extensions for image type: ${LTPURPLE}${BUILD_TYPE}${NC}"
  echo -e "${LTBLUE}==============================================================${NC}"
  echo

  update_regular_user

  update_sudo_users
}


main ${*}
