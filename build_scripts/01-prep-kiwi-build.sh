#!/bin/bash
#
# version: 2.1.2
# date: 2019-10-16

##############################################################################
#       Set Default Global Variables
##############################################################################


source /etc/os-release
#BUILD_TYPE_LIST="iso vmx oem"
BUILD_TYPE_LIST="iso vmx oem azure gce"
#BUILD_TYPE_LIST="iso vmx oem aws azure gce"
#BUILD_TYPE_LIST="iso vmx oem aws"

OS_IMAGE_NAME="$(echo ${NAME} | sed 's/ /_/g')"

case ${VERSION}
in
  42.3)
    DEFAULT_LIVE_IMAGE_VERSION="5.1.0"
  ;;
  15.0)
    DEFAULT_LIVE_IMAGE_VERSION="6.0.0"
  ;;
  15.1)
    DEFAULT_LIVE_IMAGE_VERSION="7.0.0"
  ;;
esac

DEFAULT_LIVE_IMAGE_HOME_URL="https://s3-us-west-2.amazonaws.com/lab-machine-image/files.html"

KIWI_TEMPLATE_DIR="/opt/image_building/templates"
KIWI_EXPORT_DIR="/tmp/kiwi-export"
KIWI_BUILD_BASE_DIR="/tmp/kiwi-build"

##############################################################################
#       Usage Function
##############################################################################

usage() {
  echo
  echo "USAGE: ${0} version=<live_image_version> [<options>]"
  echo
  echo "  Options:"
  echo "           no_write_release_file"
  echo "           no_remove_kiwi_build_dirs"
  echo "           no_remove_kiwi_export_files"
  echo "           no_clean_kiwi_cache"
  echo "           no_clean_download_dirs"
  echo "           no_clean_course_dirs"
  echo "           no_remove_machinery_profile"
  echo "           no_clean_logs"
  echo "           no_machinery_inspection"
  echo "           no_machinery_export"
  echo "           no_copy_machinery_export_to_build_type"
  echo
}

if echo $* | grep -Eq '\-h|\-\-help|\-help|help'
then
  usage
  exit 0
fi

##############################################################################
#       Set Other Global Variables
##############################################################################

if [ -e /etc/liveimage-release ]
then
  source /etc/liveimage-release
  export LIVE_IMAGE_VERSION=${LIVE_IMAGE_VERSION}
  export LIVE_IMAGE_HOME_URL=${LIVE_IMAGE_HOME_URL}
else
  echo 
  echo "File /etc/liveimage-release not found. Using default values."
  export LIVE_IMAGE_VERSION=${DEFAULT_LIVE_IMAGE_VERSION}
  export LIVE_IMAGE_HOME_URL=${DEFAULT_LIVE_IMAGE_HOME_URL}
fi

NEW_LIVE_IMAGE_VERSION=$(echo $* | grep "version=.*" | cut -d " " -f 1 | cut -d = -f 2)

case ${NEW_LIVE_IMAGE_VERSION}
in
  current)
    export NEW_LIVE_IMAGE_VERSION=${LIVE_IMAGE_VERSION}
  ;;
  default)
    export NEW_LIVE_IMAGE_VERSION=${DEFAULT_LIVE_IMAGE_VERSION}
  ;;
  none)
    export NEW_LIVE_IMAGE_VERSION=none
  ;;
esac

if [ -z ${NEW_LIVE_IMAGE_VERSION} ]
then
  echo
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "  ERROR: Please provide the new image version number."
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  usage
  echo
  echo "-----------------------------------------------------------------------"
  echo "Current image release info (from /etc/liveimage-release):"
  echo "  LIVE_IMAGE_VERSION=${LIVE_IMAGE_VERSION}"
  echo "  LIVE_IMAGE_HOME_URL=${LIVE_IMAGE_HOME_URL}"
  echo "-----------------------------------------------------------------------"
  echo
  exit 1
fi

##############################################################################
#                 Functions
##############################################################################

write_liveimage_release_file() {
  if [ "${LIVE_IMAGE_VERSION}" != none ]
  then
    echo "Writing liveimage-release file ..."
    echo LIVE_IMAGE_VERSION="${NEW_LIVE_IMAGE_VERSION}" > /etc/liveimage-release
    echo LIVE_IMAGE_HOME_URL="${LIVE_IMAGE_HOME_URL}" >> /etc/liveimage-release
    echo
  fi
}

remove_kiwi_build_dirs() {
  for BUILD_TYPE in ${BUILD_TYPE_LIST}
  do
    if [ -e "${KIWI_BUILD_BASE_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}" ]
    then
      echo "Removing kiwi build directory files: ${BUILD_TYPE} ..."
      rm -rf ${KIWI_BUILD_BASE_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/*
      echo
    else
      echo "Creating kiwi build directory: ${BUILD_TYPE} ..."
      mkdir -p ${KIWI_BUILD_BASE_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}
      echo
    fi
  done
}

remove_kiwi_export_files() {
  if [ -e "${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}" ]
  then
    echo "Removing kiwi build config files ..."
    rm -rf ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}/
  fi

  for BUILD_TYPE in ${BUILD_TYPE_LIST}
  do
    if [ -e "${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}" ]
    then
      echo "Removing kiwi build config files ..."
      rm -rf ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/
    fi
    echo
  done

}

clean_kiwi_cache() {
  echo "Cleaning up Kiwi cache directories ..."
  rm -rf /var/cache/kiwi/packages/*
  rm -rf /var/cache/kiwi/zypper/*
  echo
}

clean_download_dirs() {
  echo "Cleaning up Download directories ..."
  rm -rf /root/Downloads/*
  rm -rf /home/tux/Downloads/*
  echo
}

clean_course_dirs() {
  echo "Cleaning up Course directories ..."
  rm -rf /home/tux/course_files/*
  rm -rf /home/tux/scripts/*
  rm -rf /home/tux/pdf/*
  rm -rf /home/iso/*
  rm -rf /home/images/*
  rm -rf /home/VMs/*
  echo
}

remove_machinery_profile() {
  echo "Removing machine profile from Machinery ..."
  machinery remove localhost
  echo
}

clean_logs() {
  echo "Cleaning up logs ..."
  journalctl --vacuum-time 1m
  echo

  echo "Cleaning up cloud-init logs ..."
  echo "" > /var/log/cloud-init.log
  echo "" > /var/log/cloud-init-output.log
  echo
}

clean_ssh_known_hosts() {
  echo "Cleaning ssh know_hosts ..."

  echo "" > /root/.ssh/known_hosts

  for U_NAME in tux
  do
    echo "" > /home/${U_NAME}/.ssh/known_hosts
  done
  echo
}

do_machinery_inspection() {
  echo
  echo "========================================================================="
  echo "Kicking off Machinery inspection ..."
  echo
  machinery inspect -x --skip-files=/var/cache/kiwi --verbose localhost
  echo
}

do_machinery_export() {
  echo
  echo "========================================================================="
  echo "Kicking off Machinery export ..."
  echo
  machinery export-kiwi -k ${KIWI_EXPORT_DIR}/ localhost
  echo "  Renaming to: ${OS_IMAGE_NAME}-${VERSION}"
  mv ${KIWI_EXPORT_DIR}/localhost-kiwi ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}

  echo
}

copy_machinery_export_to_build_type() {
  echo
  echo "========================================================================="
  echo "Copying Machinery export ..."
  echo
  for BUILD_TYPE in ${BUILD_TYPE_LIST}
  do
    case ${BUILD_TYPE} in
      vmx|aws|AWS|azure|AZURE|gce|GCE)
        echo "  To: ${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}"
        cp -a ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION} ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}
      ;;
    esac
  done

  echo
}

main() {
  echo
  echo "#########################################################################" 
  echo "  Prepping Kiwi image build for: ${OS_IMAGE_NAME}-${VERSION}"
  echo "                  Image Version: ${LIVE_IMAGE_VERSION}"
  echo "#########################################################################" 
  echo

  if ! echo $* | grep -q no_write_release_file
  then
    write_liveimage_release_file
  else
    echo "(not writing out a release file)"
    echo
  fi

  if ! echo $* | grep -q no_remove_kiwi_build_dirs
  then
    remove_kiwi_build_dirs
  else
    echo "(not removing kiwi build directories)"
    echo
  fi

  if ! echo $* | grep -q no_remove_kiwi_export_files
  then
    remove_kiwi_export_files
  else
    echo "(not removing kiwi export files)"
    echo
  fi

  if ! echo $* | grep -q no_clean_kiwi_cache
  then
    clean_kiwi_cache
  else
    echo "(not cleaning kiwi cache)"
    echo
  fi

  if ! echo $* | grep -q no_clean_download_dirs
  then
    clean_download_dirs
  else
    echo "(not cleaning download directories)"
    echo
  fi

  if ! echo $* | grep -q no_clean_course_dirs
  then
    clean_course_dirs
  else
    echo "(not cleaning course directories)"
    echo
  fi

  if ! echo $* | grep -q no_remove_machinery_profile
  then
    remove_machinery_profile
  else
    echo "(not removing machinery machine profile)"
    echo
  fi

  if ! echo $* | grep -q no_clean_logs
  then
    clean_logs
  else
    echo "(not cleaning logs)"
    echo
  fi

  if ! echo $* | grep -q no_ssh_known_hosts
  then
    clean_ssh_known_hosts
  else
    echo "(not cleaning ssh known_hosts)"
    echo
  fi

  if ! echo $* | grep -q no_machinery_inspection
  then
    do_machinery_inspection
  else
    echo "(not performing machinery inspection)"
    echo
  fi

  if ! echo $* | grep -q no_machinery_export
  then
    do_machinery_export
  else
    echo "(not performing machinery export)"
    echo
  fi

  if ! echo $* | grep -q no_copy_machinery_export_to_build_type
  then
    copy_machinery_export_to_build_type
  else
    echo "(not performing copy of machinery export to build type)"
    echo
  fi
}

##############################################################################
#                       Main Code Body
##############################################################################

time main $*
