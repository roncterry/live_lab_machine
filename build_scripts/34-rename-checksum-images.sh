#!/bin/bash
#
# version: 1.0.0
# date: 2019-10-18

#############################################################################
#              Global Variables
#############################################################################

KIWI_TEMPLATE_DIR="/opt/image_building/templates"
KIWI_EXPORT_DIR="/tmp/kiwi-export"
KIWI_BUILD_BASE_DIR="/tmp/kiwi-build"

#############################################################################
#              Functions
#############################################################################

get_build_type() {
  if [ -z ${1} ]
  then
    BUILD_TYPE_LIST="iso"
    #BUILD_TYPE_LIST="vmx"
    #BUILD_TYPE_LIST="aws"
    #BUILD_TYPE_LIST="oem"
    #BUILD_TYPE_LIST="iso vmx"
    #BUILD_TYPE_LIST="iso vmx aws"
    #BUILD_TYPE_LIST="iso vmx oem"
  else
    case ${1} in
      -h|--help)
        echo
	echo "DESCRIPTION:  This script builds only the image file"
	echo "              from an already created Kiwi image root."
	echo
        echo "USAGE: ${0} <build_type>[,<build_type>[...]] [<kiwi_config_dir>]"
        echo
        echo "       Build Types: iso vmx qcow2 oem aws azure gce"
        echo
        echo "       (Note: Type vmx and qcow2 are the same)"
        echo
        exit
      ;;
      *)
        BUILD_TYPE_LIST=$(echo ${1} | tr , " ")
      ;;
    esac
  fi
}

get_image_name_and_ver() {
  if [ -z ${2} ]
  then
    source /etc/os-release
    source /etc/liveimage-release
    export OS_IMAGE_NAME="$(echo ${NAME} | sed 's/ /_/g')"
    export VERSION="${VERSION_ID}"
    export LIVE_IMAGE_VERSION="${LIVE_IMAGE_VERSION}"
  else
    if [ -e "${KIWI_EXPORT_DIR}/${2}/config.xml" ]
    then
      export OS_IMAGE_NAME="$(grep "<image schemaversion" ${KIWI_EXPORT_DIR}/${2}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 1)"
      export VERSION="$(grep "<image schemaversion" ${KIWI_EXPORT_DIR}/${2}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 2)"
      export LIVE_IMAGE_VERSION="$(grep ".*<version>.*" ${KIWI_EXPORT_DIR}/${2}/config.xml | cut -d \> -f 2 | cut -d \< -f 1)"
    else
      echo
      echo "ERROR:  No Kiwi confguration found in ${2}"
      echo
      exit 1
    fi
  fi
}

rename_checksum_image() {
  case ${BUILD_TYPE} in
    iso|ISO)
      KIWI_BUILD_TARGET_DIR=${OS_IMAGE_NAME}-${VERSION}-iso
      KIWI_BUILD_ROOT_DIR=${KIWI_BUILD_TARGET_DIR}/build/image-root

      echo
      echo "COMMAND: cd ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_TARGET_DIR}/"
      cd ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_TARGET_DIR}/

      echo "COMMAND: mv ${OS_IMAGE_NAME}-${VERSION}.x86_64-${LIVE_IMAGE_VERSION}.iso ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.iso"
      mv ${OS_IMAGE_NAME}-${VERSION}.x86_64-${LIVE_IMAGE_VERSION}.iso ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.iso

      echo "COMMAND: md5sum ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.iso > ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.iso.md5sum"
      md5sum ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.iso > ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.iso.md5sum
    ;;
    vmx|VMX|qcow2|QCOW2)
      KIWI_BUILD_TARGET_DIR=${OS_IMAGE_NAME}-${VERSION}-vmx
      KIWI_BUILD_ROOT_DIR=${KIWI_BUILD_TARGET_DIR}/build/image-root

      echo
      echo "COMMAND: cd ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_TARGET_DIR}/"
      cd ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_TARGET_DIR}/

      echo "COMMAND: mv ${OS_IMAGE_NAME}-${VERSION}.x86_64-${LIVE_IMAGE_VERSION}.qcow2 ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.qcow2"
      mv ${OS_IMAGE_NAME}-${VERSION}.x86_64-${LIVE_IMAGE_VERSION}.qcow2 ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.qcow2

      echo "COMMAND: md5sum ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.qcow2 > ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.qcow2.md5sum"
      md5sum ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.qcow2 > ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.qcow2.md5sum
    ;;
    oem|OEM)
      KIWI_BUILD_TARGET_DIR=${OS_IMAGE_NAME}-${VERSION}-oem
      KIWI_BUILD_ROOT_DIR=${KIWI_BUILD_TARGET_DIR}/build/image-root

      echo
      echo "COMMAND: cd ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_TARGET_DIR}/"
      cd ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_TARGET_DIR}/

      echo "COMMAND: mv ${OS_IMAGE_NAME}-${VERSION}.x86_64-${LIVE_IMAGE_VERSION}.raw ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.raw"
      mv ${OS_IMAGE_NAME}-${VERSION}.x86_64-${LIVE_IMAGE_VERSION}.raw ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.raw

      echo "COMMAND: md5sum ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.raw > ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.raw.md5sum"
      md5sum ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.raw > ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.raw.md5sum
    ;;
    aws|AWS)
      KIWI_BUILD_TARGET_DIR=${OS_IMAGE_NAME}-${VERSION}-aws
      KIWI_BUILD_ROOT_DIR=${KIWI_BUILD_TARGET_DIR}/build/image-root

      echo "Not Yet Implemented"
      echo
    ;;
    azure|AZURE)
      KIWI_BUILD_TARGET_DIR=${OS_IMAGE_NAME}-${VERSION}-azure
      KIWI_BUILD_ROOT_DIR=${KIWI_BUILD_TARGET_DIR}/build/image-root

      echo
      echo "COMMAND: cd ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_TARGET_DIR}/"
      cd ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_TARGET_DIR}/

      echo "COMMAND: mv ${OS_IMAGE_NAME}-${VERSION}.x86_64-${LIVE_IMAGE_VERSION}.vhdfixed ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd"
      mv ${OS_IMAGE_NAME}-${VERSION}.x86_64-${LIVE_IMAGE_VERSION}.vhdfixed ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd

      echo "COMMAND: md5sum ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd > ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd.md5sum"
      md5sum ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd > ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd.md5sum

      echo "COMMAND: tar czvf ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd.tgz ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd*"
      tar czvf ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd.tgz ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd*

      echo "COMMAND: md5sum ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd.tgz > ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd.tgz.md5sum"
      md5sum ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd.tgz > ${OS_IMAGE_NAME}-${VERSION}-desktop-${LIVE_IMAGE_VERSION}.fixed.vhd.tgz.md5sum
    ;;
    gce|GCE)
      KIWI_BUILD_TARGET_DIR=${OS_IMAGE_NAME}-${VERSION}-gce
      KIWI_BUILD_ROOT_DIR=${KIWI_BUILD_TARGET_DIR}/build/image-root

      echo "Not Yet Implemented"
      echo
    ;;
  esac


  echo
}

main() {
  get_build_type ${*}
  get_image_name_and_ver ${*}

  for BUILD_TYPE in ${BUILD_TYPE_LIST}
  do
    echo
    echo "#########################################################################" 
    echo "  Renameing and Checksumming: ${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}"
    echo "#########################################################################" 
    echo

    rename_checksum_image
  done
}

time main ${*}
