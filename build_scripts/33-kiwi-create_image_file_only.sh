#!/bin/bash
#
# version: 1.0.3
# date: 2019-10-16

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

get_kiwi_version() {
  if echo $* | grep -q kiwi=
  then
    KIWI_VER=$(echo $* | grep kiwi= | cut -d = -f 2 | awk '{ print $1 }')
    
    case ${KIWI_VER} in
      kiwi|KIWI)
        KIWI_NEXT_GEN=N
      ;;
      kiwi-ng|KIWI-NG)
        KIWI_NEXT_GEN=Y
      ;;
    esac
  elif which kiwi-ng > /dev/null
  then
    KIWI_NEXT_GEN=Y
  else
    KIWI_NEXT_GEN=N
  fi

  case ${KIWI_NEXT_GEN} in
    y|Y|yes|Yes|YES)
      KIWI_CMD="kiwi-ng --color-output"
      #KIWI_CMD="kiwi compat"
    ;;
    *)
      KIWI_CMD="/usr/sbin/kiwi"
    ;;
  esac

  #echo KIWI_VER=${KIWI_VER}
  #echo KIWI_CMD=${KIWI_CMD}
  #read
}

build_image_file_only() {
  case ${BUILD_TYPE} in
    iso|ISO)
      KIWI_BUILD_TARGET_DIR=${OS_IMAGE_NAME}-${VERSION}-iso
      KIWI_BUILD_ROOT_DIR=${KIWI_BUILD_TARGET_DIR}/build/image-root
    ;;
    vmx|VMX|qcow2|QCOW2)
      KIWI_BUILD_TARGET_DIR=${OS_IMAGE_NAME}-${VERSION}-vmx
      KIWI_BUILD_ROOT_DIR=${KIWI_BUILD_TARGET_DIR}/build/image-root
    ;;
    oem|OEM)
      KIWI_BUILD_TARGET_DIR=${OS_IMAGE_NAME}-${VERSION}-oem
      KIWI_BUILD_ROOT_DIR=${KIWI_BUILD_TARGET_DIR}/build/image-root
    ;;
    aws|AWS)
      KIWI_BUILD_TARGET_DIR=${OS_IMAGE_NAME}-${VERSION}-aws
      KIWI_BUILD_ROOT_DIR=${KIWI_BUILD_TARGET_DIR}/build/image-root
    ;;
    azure|AZURE)
      KIWI_BUILD_TARGET_DIR=${OS_IMAGE_NAME}-${VERSION}-azure
      KIWI_BUILD_ROOT_DIR=${KIWI_BUILD_TARGET_DIR}/build/image-root
    ;;
    gce|GCE)
      KIWI_BUILD_TARGET_DIR=${OS_IMAGE_NAME}-${VERSION}-gce
      KIWI_BUILD_ROOT_DIR=${KIWI_BUILD_TARGET_DIR}/build/image-root
    ;;
  esac

  echo
  echo "--------------------------------------------------------------------------"
  echo "        Building Image Type: ${BUILD_TYPE}"
  echo "        Live Image Version:  ${LIVE_IMAGE_VERSION}"
  echo "        Kiwi Image Root:     ${KIWI_BUILD_ROOT_DIR}"
  echo "        Kiwi Target Dir:     ${KIWI_BUILD_TARGET_DIR}"
  echo "        Using Kiwi Command:  ${KIWI_CMD}"
  echo "--------------------------------------------------------------------------"
  echo

  case ${KIWI_NEXT_GEN} in
    y|Y|yes|Yes|YES)
      echo "COMMAND: ${KIWI_CMD} system create --root ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_ROOT_DIR}/ --target-dir ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_TARGET_DIR}/"
      echo
      ${KIWI_CMD} system create --root ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_ROOT_DIR}/ --target-dir ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_TARGET_DIR}/
    ;;
    *)
      echo "COMMAND: ${KIWI_CMD} --create ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_ROOT_DIR}/ -d ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_TARGET_DIR}/"
      echo
      ${KIWI_CMD} --create ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_ROOT_DIR}/ -d ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_TARGET_DIR}/
    ;;
  esac
  echo
  echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
  echo "*                 Finished creating: ${BUILD_TYPE}"
  echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
  echo
  echo
}

main() {
  get_build_type ${*}
  get_image_name_and_ver ${*}
  get_kiwi_version ${*}

  echo
  echo "#########################################################################" 
  echo "  Building Kiwi image for: ${OS_IMAGE_NAME}-${VERSION}"
  echo "       Live Image Version: ${LIVE_IMAGE_VERSION}"
  echo "            Image Type(s): ${BUILD_TYPE_LIST}"
  echo "#########################################################################" 
  echo

  for BUILD_TYPE in ${BUILD_TYPE_LIST}
  do
    build_image_file_only
  done
}

time main ${*}
