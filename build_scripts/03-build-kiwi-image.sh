#!/bin/bash
#
# version: 3.0.2
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
        echo "USAGE: ${0} <build_type>[,<build_type>[...]] [<kiwi_config_dir>] [--allow-existing-root]"
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

get_image_name_ver_and_options() {
  if [ -z ${2} ]
  then
    source /etc/os-release
    source /etc/liveimage-release
    export OS_IMAGE_NAME="$(echo ${NAME} | sed 's/ /_/g')"
    export VERSION="${VERSION_ID}"
    export LIVE_IMAGE_VERSION="${LIVE_IMAGE_VERSION}"
  elif [ "${2}" == "--allow-existing-root" ]
  then
    ALLOW_EXISTING_ROOT=Y
    KIWI_OPTIONS="${KIWI_OPTIONS} --recycle-root"
    KIWI_NG_OPTIONS="${KIWI_NG_OPTIONS} --allow-existing-root"

    if ! [ -z ${3} ]
    then
      if [ -e "${KIWI_EXPORT_DIR}/${3}/config.xml" ]
      then
        export OS_IMAGE_NAME="$(grep "<image schemaversion" ${KIWI_EXPORT_DIR}/${3}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 1)"
        export VERSION="$(grep "<image schemaversion" ${KIWI_EXPORT_DIR}/${3}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 2)"
        export LIVE_IMAGE_VERSION="$(grep ".*<version>.*" ${KIWI_EXPORT_DIR}/${3}/config.xml | cut -d \> -f 2 | cut -d \< -f 1)"
      else
        echo
        echo "ERROR:  No Kiwi confguration found in ${3}"
        echo
        exit 1
      fi
    else
      source /etc/os-release
      source /etc/liveimage-release
      export OS_IMAGE_NAME="$(echo ${NAME} | sed 's/ /_/g')"
      export VERSION="${VERSION}"
      export LIVE_IMAGE_VERSION="${LIVE_IMAGE_VERSION}"
    fi
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
      KIWI_CMD="kiwi-ng --color-output ${KIWI_NG_OPTIONS}"
    ;;
    *)
      KIWI_CMD="/usr/sbin/kiwi ${KIWI_OPTIONS}"
    ;;
  esac
}

build_image() {
  case ${BUILD_TYPE} in
    iso|ISO)
      BUILD_TARGET=iso
      KIWI_CONFIG_DIR=${OS_IMAGE_NAME}-${VERSION}
      KIWI_BUILD_DIR=${OS_IMAGE_NAME}-${VERSION}-iso
    ;;
    vmx|VMX|qcow2|QCOW2)
      BUILD_TARGET=vmx
      KIWI_CONFIG_DIR=${OS_IMAGE_NAME}-${VERSION}-vmx
      KIWI_BUILD_DIR=${OS_IMAGE_NAME}-${VERSION}-vmx
    ;;
    oem|OEM)
      BUILD_TARGET=oem
      KIWI_CONFIG_DIR=${OS_IMAGE_NAME}-${VERSION}
      KIWI_BUILD_DIR=${OS_IMAGE_NAME}-${VERSION}-oem
    ;;
    aws|AWS)
      BUILD_TARGET=vmx
      KIWI_CONFIG_DIR=${OS_IMAGE_NAME}-${VERSION}-aws
      KIWI_BUILD_DIR=${OS_IMAGE_NAME}-${VERSION}-aws
    ;;
    azure|AZURE)
      BUILD_TARGET=vmx
      KIWI_CONFIG_DIR=${OS_IMAGE_NAME}-${VERSION}-azure
      KIWI_BUILD_DIR=${OS_IMAGE_NAME}-${VERSION}-azure
    ;;
    gce|GCE)
      BUILD_TARGET=oem
      KIWI_CONFIG_DIR=${OS_IMAGE_NAME}-${VERSION}-gce
      KIWI_BUILD_DIR=${OS_IMAGE_NAME}-${VERSION}-gce
    ;;
  esac

  echo
  echo "--------------------------------------------------------------------------"
  echo "        Building Image Type: ${BUILD_TYPE}"
  echo "        Kiwi Build Target:   ${BUILD_TARGET}"
  echo "        Live Image Version:  ${LIVE_IMAGE_VERSION}"
  echo "        Using Kiwi Command:  ${KIWI_CMD}"
  echo "--------------------------------------------------------------------------"
  echo

  case ${ALLOW_EXISTING_ROOT} in
    Y)
      echo "        (Keeping existing build dir)"
      echo
    ;;
    *)
      echo "--------------------------------------------------------------------------"
      echo "        Cleaning up build dir"
      echo "--------------------------------------------------------------------------"
      echo "COMMAND: rm -rf ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_DIR}/build"
      echo
      rm -rf ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_DIR}/build
      echo
    ;;
  esac

  case ${KIWI_NEXT_GEN} in
    y|Y|yes|Yes|YES)
      echo "COMMAND: ${KIWI_CMD} --type ${BUILD_TARGET} system build --description ${KIWI_EXPORT_DIR}/${KIWI_CONFIG_DIR} --target-dir ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_DIR}/"
      echo
      ${KIWI_CMD} --type ${BUILD_TARGET} system build --description ${KIWI_EXPORT_DIR}/${KIWI_CONFIG_DIR} --target-dir ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_DIR}/
    ;;
    *)
      echo "COMMAND: ${KIWI_CMD} --type ${BUILD_TARGET} --build ${KIWI_EXPORT_DIR}/${KIWI_CONFIG_DIR} -d ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_DIR}/"
      echo
      ${KIWI_CMD} --type ${BUILD_TARGET} --build ${KIWI_EXPORT_DIR}/${KIWI_CONFIG_DIR} -d ${KIWI_BUILD_BASE_DIR}/${KIWI_BUILD_DIR}/
    ;;
  esac
  echo
  echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
  echo "*                 Finished building: ${BUILD_TYPE}"
  echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
  echo
  echo
}

main() {
  get_build_type ${*}
  get_image_name_ver_and_options ${*}
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
    build_image
  done
}

time main ${*}
