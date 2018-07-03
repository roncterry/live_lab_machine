#!/bin/bash
#
# version: 1.1.1
# date: 2018-07-02

get_build_type() {
  if [ -z ${1} ]
  then
    BUILD_TYPE_LIST="iso"
    #BUILD_TYPE_LIST="vmx"
    #BUILD_TYPE_LIST="oem"
    #BUILD_TYPE_LIST="iso vmx"
    #BUILD_TYPE_LIST="iso vmx oem"
  else
    case ${1} in
      -h|--help)
        echo
        echo "USAGE: ${0} [iso|vmx|oem] [<kiwi_config_dir>]"
        echo
      ;;
      iso|ISO)
        BUILD_TYPE_LIST="iso"
      ;;
      vmx|VMX)
        BUILD_TYPE_LIST="vmx"
      ;;
      oem|OEM)
        BUILD_TYPE_LIST="oem"
      ;;
      iso,vmx|ISO,VMX)
        BUILD_TYPE_LIST="iso vmx"
      ;;
      vmx,iso|VMX,ISO)
        BUILD_TYPE_LIST="vmx iso"
      ;;
    esac
  fi
}

get_image_name_and_ver() {
  if [ -z ${2} ]
  then
    source /etc/os-release
    OS_IMAGE_NAME="$(echo ${NAME} | sed 's/ /_/g')"
  else
    if [ -e "${2}/config.xml" ]
    then
      OS_IMAGE_NAME="$(grep "<image schemaversion" ${2}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 1)"
      VERSION="$(grep "<image schemaversion" ${2}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 2)"
    else
      echo
      echo "ERROR:  No Kiwi confguration found in ${1}"
      echo
      exit 1
    fi
  fi
}

get_kiwi_version() {
  if kiwi --version | grep -q "next generation"
  then
    KIWI_NEXT_GEN=Y
  else
    KIWI_NEXT_GEN=N
  fi

  case ${KIWI_NEXT_GEN} in
    y|Y|yes|Yes|YES)
      KIWI_CMD="kiwi --color-output"
      #KIWI_CMD="kiwi compat"
    ;;
    *)
      KIWI_CMD="kiwi"
    ;;
  esac
}

build_image() {
  KIWI_CONFIG_DIR=${OS_IMAGE_NAME}-${VERSION}
  KIWI_BUILD_DIR=${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}
  echo "--------------------------------------------------------------------------"
  echo "        Cleaning up build dir"
  echo "--------------------------------------------------------------------------"
  echo "COMMAND: rm -rf /tmp/kiwi-build/${KIWI_BUILD_DIR}/build"
  echo
  rm -rf /tmp/kiwi-build/${KIWI_BUILD_DIR}/build
  echo
  echo "--------------------------------------------------------------------------"
  echo "        Building: ${BUILD_TYPE}"
  echo "--------------------------------------------------------------------------"
  case ${KIWI_NEXT_GEN} in
    y|Y|yes|Yes|YES)
      echo "COMMAND: ${KIWI_CMD} --type ${BUILD_TYPE} system build --description /tmp/kiwi-export/${KIWI_CONFIG_DIR} --target-dir /tmp/kiwi-build/${KIWI_BUILD_DIR}/"
      echo
      ${KIWI_CMD} --type ${BUILD_TYPE} system build --description /tmp/kiwi-export/${KIWI_CONFIG_DIR} --target-dir /tmp/kiwi-build/${KIWI_BUILD_DIR}/
    ;;
    *)
      echo "COMMAND: ${KIWI_CMD} --type ${BUILD_TYPE} --build /tmp/kiwi-export/${KIWI_CONFIG_DIR} -d /tmp/kiwi-build/${KIWI_BUILD_DIR}/"
      echo
      ${KIWI_CMD} --type ${BUILD_TYPE} --build /tmp/kiwi-export/${KIWI_CONFIG_DIR} -d /tmp/kiwi-build/${KIWI_BUILD_DIR}/
    ;;
  esac
  echo
  echo
}

main() {
  get_build_type ${*}
  get_image_name_and_ver ${*}
  get_kiwi_version

  echo
  echo "#########################################################################" 
  echo "  Building Kiwi image for: ${OS_IMAGE_NAME}-${VERSION}"
  echo "            Image Type(s): ${BUILD_TYPE_LIST}"
  echo "#########################################################################" 
  echo
  for BUILD_TYPE in ${BUILD_TYPE_LIST}
  do
    build_image
  done
}

time main ${*}
