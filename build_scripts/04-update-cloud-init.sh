#!/bin/bash
#
# version: 1.2.1
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

ARCH="x86_64"
BUILD_TYPE="vmx"
IMAGE_TYPE="qcow2"
DEFAULT_IMAGE_MOUNT_POINT="/tmp/vmx_image"

KIWI_TEMPLATE_DIR="/opt/image_building/templates"
KIWI_EXPORT_DIR="/tmp/kiwi-export"
KIWI_BUILD_BASE_DIR="/tmp/kiwi-build"

#############################################################################
#              Functions
#############################################################################

usage() {
  echo
  echo "USAGE: ${0} [<image_file>|<kiwi_config_dir>] [<image_mount_point>]"
  echo
}

get_image_name_and_ver() {
  # no argument
  if [ -z ${1} ]
  then
    source /etc/os-release
    source /etc/liveimage-release
    export OS_IMAGE_NAME="$(echo ${NAME} | sed 's/ /_/g')"
    export VERSION="${VERSION_ID}"
    export LIVE_IMAGE_VERSION="${LIVE_IMAGE_VERSION}"

    export VMX_IMAGE_DIR="${KIWI_BUILD_BASE_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}"
    export VMX_IMAGE_FILE="${OS_IMAGE_NAME}-${VERSION}.${ARCH}-${LIVE_IMAGE_VERSION}.${IMAGE_TYPE}"
    export VMX_IMAGE="${VMX_IMAGE_DIR}/${VMX_IMAGE_FILE}"
  # argument is a path to an image file
  elif [ -f ${1} ]
  then
    export VMX_IMAGE="${1}"
    export VMX_IMAGE_DIR="$(dirname ${VMX_IMAGE})"
    export VMX_IMAGE_FILE="$(basename ${VMX_IMAGE})"

    export OS_IMAGE_NAME="$(echo $(basename ${VMX_IMAGE}) | cut -d \- -f 1)"
    export VERSION="$(echo $(basename ${VMX_IMAGE}) | cut -d \- -f 2 | sed "s/.${ARCH}//g")"
    export LIVE_IMAGE_VERSION="$(echo $(basename ${VMX_IMAGE}) | cut -d \- -f 3 | sed "s/.${IMAGE_TYPE}//g")"
  # argument is absolute path to a Kiwi config dir
  elif [ -f "${1}/config.xml" ]
  then
    export OS_IMAGE_NAME="$(grep "<image schemaversion" ${1}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 1)"
    export VERSION="$(grep "<image schemaversion" ${1}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 2)"
    export LIVE_IMAGE_VERSION="$(grep ".*<version>.*" ${1}/config.xml | cut -d \> -f 2 | cut -d \< -f 1)"

    export VMX_IMAGE_DIR="${KIWI_BUILD_BASE_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}"
    export VMX_IMAGE_FILE="${OS_IMAGE_NAME}-${VERSION}.${ARCH}-${LIVE_IMAGE_VERSION}.${IMAGE_TYPE}"
    export VMX_IMAGE="${VMX_IMAGE_DIR}/${VMX_IMAGE_FILE}"
  # argument is name of Kiwi config dir
  elif [ -f "${KIWI_EXPORT_DIR}/${1}/config.xml" ]
  then
    export OS_IMAGE_NAME="$(grep "<image schemaversion" ${KIWI_EXPORT_DIR}/${1}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 1)"
    export VERSION="$(grep "<image schemaversion" ${KIWI_EXPORT_DIR}/${1}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 2)"
    export LIVE_IMAGE_VERSION="$(grep ".*<version>.*" ${KIWI_EXPORT_DIR}/${1}/config.xml | cut -d \> -f 2 | cut -d \< -f 1)"

    export VMX_IMAGE_DIR="${KIWI_BUILD_BASE_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}"
    export VMX_IMAGE_FILE="${OS_IMAGE_NAME}-${VERSION}.${ARCH}-${LIVE_IMAGE_VERSION}.${IMAGE_TYPE}"
    export VMX_IMAGE="${VMX_IMAGE_DIR}/${VMX_IMAGE_FILE}"
  else
    echo
    echo -e "${LTRED}ERROR:  No image file or Kiwi confguration found in: ${LTPURPLE}${1}${NC}"
    echo
    exit 1
  fi

  if ! [ -e ${VMX_IMAGE} ]
  then
    echo
    echo -e "${LTRED}ERROR:  Image file (${LTPURPLE}${VMX_IMAGE}${LTRED}) does not appear to exist${NC}"
    echo
    exit 1
  fi
}

get_image_mount_point() {
  if [ -z ${2} ]
  then
    IMAGE_MOUNT_POINT="${DEFAULT_IMAGE_MOUNT_POINT}"
  else
    if [ -e ${2} ]
    then
      IMAGE_MOUNT_POINT="${2}"
    fi
  fi
}

update_config() {
  # create mount point
  echo -e "${LTCYAN}-Create mountpoint${NC}"
  echo -e "${LTGREEN}COMMAND:${GRAY} mkdir -p ${IMAGE_MOUNT_POINT}${NC}"
  mkdir -p ${IMAGE_MOUNT_POINT}
  echo

  # mount image file
  echo -e "${LTCYAN}-Mount image${NC}"
  echo -e "${LTGREEN}COMMAND:${GRAY} guestmount -a ${VMX_IMAGE} -i ${IMAGE_MOUNT_POINT}${NC}"
  guestmount -a ${VMX_IMAGE} -i ${IMAGE_MOUNT_POINT}
  echo

  # disable GDM auto login
  echo -e "${LTCYAN}-Disable GDM autologin${NC}"
  echo -e "${LTGREEN}COMMAND:${GRAY} sed -i 's/^DISPLAYMANAGER_AUTOLOGIN=.*/DISPLAYMANAGER_AUTOLOGIN=/g' ${IMAGE_MOUNT_POINT}/etc/sysconfig/displaymanager${NC}"
  sed -i 's/^DISPLAYMANAGER_AUTOLOGIN=.*/DISPLAYMANAGER_AUTOLOGIN=/g' ${IMAGE_MOUNT_POINT}/etc/sysconfig/displaymanager
  echo

  # disable root user
  echo -e "${LTCYAN}-Disable root account (cloud-init)${NC}"
  echo -e "${LTGREEN}COMMAND:${GRAY} sed -i 's/^disable_root.*/disable_root: true/g' ${IMAGE_MOUNT_POINT}/etc/cloud/cloud.cfg${NC}"
  sed -i 's/^disable_root.*/disable_root: true/g' ${IMAGE_MOUNT_POINT}/etc/cloud/cloud.cfg
  echo

  # comment existing data_source list
  echo -e "${LTCYAN}-Update datasources${NC}"
  echo -e "${LTGREEN}COMMAND:${GRAY} sed -i 's/^datasource_list: \[ None \]/#datasource_list: \[ None \]/g' ${IMAGE_MOUNT_POINT}/etc/cloud/cloud.cfg${NC}"
  sed -i 's/^datasource_list: \[ None \]/#datasource_list: \[ None \]/g' ${IMAGE_MOUNT_POINT}/etc/cloud/cloud.cfg
  echo

  # uncomment new data_source list
  #echo -e "${LTGREEN}COMMAND:${GRAY} sed -i 's/^#datasource_list: \[ LocalDisk.*/datasource_list: \[ LocalDisk,  NoCloud, OpenStack, None \]/g' ${IMAGE_MOUNT_POINT}/etc/cloud/cloud.cfg${NC}"
  #sed -i 's/^#datasource_list: \[ LocalDisk.*/datasource_list: \[ LocalDisk,  NoCloud, OpenStack, None \]/g' ${IMAGE_MOUNT_POINT}/etc/cloud/cloud.cfg
  echo -e "${LTGREEN}COMMAND:${GRAY} sed -i 's/^#datasource_list: .*/datasource_list: \[ ConfigDrive, LocalDisk,  NoCloud, OpenStack, None \]/g' ${IMAGE_MOUNT_POINT}/etc/cloud/cloud.cfg${NC}"
  sed -i 's/^#datasource_list: .*/datasource_list: \[ ConfigDrive, LocalDisk,  NoCloud, OpenStack, None \]/g' ${IMAGE_MOUNT_POINT}/etc/cloud/cloud.cfg
  echo

  ## enable cloud-init services
  #echo -e "${LTCYAN}-Enable cloud-init services${NC}"
  #echo -e "${LTGREEN}COMMAND:${GRAY} systemctl enable cloud-init.service${NC}"
  #systemctl enable cloud-init.service
  #echo -e "${LTGREEN}COMMAND:${GRAY} systemctl enable cloud-init-local.service${NC}"
  #systemctl enable cloud-init-local.service
  #echo -e "${LTGREEN}COMMAND:${GRAY} systemctl enable cloud-config.service${NC}"
  #systemctl enable cloud-config.service
  #echo -e "${LTGREEN}COMMAND:${GRAY} systemctl enable cloud-final.service${NC}"
  #systemctl enable cloud-final.service
  #echo

  # umount image file
  echo -e "${LTCYAN}-Unmount image${NC}"
  echo -e "${LTGREEN}COMMAND:${GRAY} umount ${IMAGE_MOUNT_POINT}${NC}"
  umount ${IMAGE_MOUNT_POINT}
  echo

  # remove mount point
  echo -e "${LTCYAN}-Remove mountpoint${NC}"
  echo -e "${LTGREEN}COMMAND:${GRAY} rmdir ${IMAGE_MOUNT_POINT}${NC}"
  rmdir ${IMAGE_MOUNT_POINT}

  echo
}

main() {
  get_image_name_and_ver $*
  get_image_mount_point $*

  echo
  echo -e "${LTBLUE}#########################################################################${NC}" 

  echo -e "${LTBLUE}  Updating the Image's OS Config${NC}"
  echo -e "${LTBLUE}    Image Dir:         ${LTPURPLE}${VMX_IMAGE_DIR}/${NC}"
  echo -e "${LTBLUE}    Image File:        ${LTPURPLE}${VMX_IMAGE_FILE}${NC}"
  echo -e "${LTBLUE}    Image File Type:   ${LTPURPLE}${IMAGE_TYPE}${NC}"
  echo -e "${LTBLUE}    Image Mount Point: ${LTPURPLE}${IMAGE_MOUNT_POINT}/${NC}"

  echo -e "${LTBLUE}#########################################################################${NC}" 
  echo

  update_config $*

  echo
  echo -e "${LTBLUE}*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*${NC}"
  echo -e "${LTBLUE}*                                Finished ${NC}"
  echo -e "${LTBLUE}*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*${NC}"
  echo
  echo
}

time main $*

