#!/bin/bash
#
# version: 1.0.1
# date: 2019-10-18

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

UPDATES_DEST_DIR="/root/Downloads"

#############################################################################
#              Functions
#############################################################################

usage() {
  echo "USAGE: ${0} <image_type> <update_directory>"
  echo
  echo "Image Type Options:  iso,vmx,azure"
  echo
  echo "The <updates_directory> should contain the following:"
  echo "  -Your updated image-rootfs-update.sh script"
  echo "  -The updated VirtualBox extension pack (optional)"
  echo "  -Any custom RPM packages to be installed (optional)"
  echo "  -Any pre/post update scripts (ending in .pre or .post) (optional)"
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
    echo -e "${LTRED}ERROR: You must provide image type to update. Exiting.${NC}"
    echo
    usage
    exit
  else
    export BUILD_TYPE=${1}
  fi

  if [ -z ${2} ]
  then
    echo
    echo -e "${LTRED}ERROR: You must provide the directory containing the updates. Exiting.${NC}"
    echo
    usage
    exit
  fi
  
  export ROOTFS_DIR="${KIWI_BUILD_BASE_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/build/image-root"
}

copy_updates_into_rootfs() {
  echo -e "${LTCYAN}Copying Updates ...${NC}"
  echo -e "${LTGREEN}COMMAND:${GRAY} cp -R ${2}/* ${ROOTFS_DIR}${UPDATES_DEST_DIR}/${NC}"
  cp -R ${2}/* ${ROOTFS_DIR}${UPDATES_DEST_DIR}/
}

main() {
  get_image_name_and_ver ${*}
  echo
  echo -e "${LTBLUE}==============================================================${NC}"
  echo -e "${LTBLUE}Copying updates into rootfs for image type: ${LTPURPLE}${BUILD_TYPE}${NC}"
  echo -e "${LTBLUE}==============================================================${NC}"
  echo

  copy_updates_into_rootfs ${*}

  echo
  echo -e "${ORANGE}Next Steps:${NC}"
  echo -e "    ${GRAY}chroot-prep.sh ${ROOTFS_DIR}${NC}"
  echo -e "    ${GRAY}chroot ${ROOTFS_DIR}${NC}"
  echo -e "    ${GRAY}cd ${UPDATES_DEST_DIR}${NC}"
  echo -e "    ${GRAY}bash image-rootfs-update.sh${NC}"
  echo -e "    ${GRAY}exit${NC}"
  echo -e "    ${GRAY}chroot-unprep.sh ${ROOTFS_DIR}${NC}"
  echo -e
}


main ${*}
