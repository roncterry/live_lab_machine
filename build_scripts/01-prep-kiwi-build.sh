#!/bin/bash
#
# version: 1.0.0
# date: 2018-06-26

source /etc/os-release

BUILD_TYPE_LIST="iso oem vmx"
OS_IMAGE_NAME="$(echo ${NAME} | sed 's/ /_/g')"

echo
echo "#########################################################################" 
echo "  Prepping Kiwi image build for: ${OS_IMAGE_NAME}-${VERSION}"
echo "#########################################################################" 
echo

for BUILD_DIR in ${BUILD_TYPE_LIST}
do
  if [ -e "/tmp/kiwi-build/${OS_IMAGE_NAME}-${VERSION}-${BUILD_DIR}" ]
  then
    echo "Removing kiwi build directory files: ${BUILD_DIR} ..."
    rm -rf /tmp/kiwi-build/${OS_IMAGE_NAME}-${VERSION}-${BUILD_DIR}/*
    echo
  else
    echo "Creating kiwi build directory: ${BUILD_DIR} ..."
    mkdir -p /tmp/kiwi-build/${OS_IMAGE_NAME}-${VERSION}-${BUILD_DIR}
    echo
  fi
done

if [ -e "/tmp/kiwi-export/${OS_IMAGE_NAME}-${VERSION}" ]
then
  echo "Removing kiwi build config files ..."
  rm -rf /tmp/kiwi-export/${OS_IMAGE_NAME}-${VERSION}/
#else
#  echo "Creating kiwi config directory ..."
#  mkdir -p /tmp/kiwi-export/${OS_IMAGE_NAME}-${VERSION}
fi
echo

echo "Cleaning up Kiwi cache directories ..."
rm -rf /var/cache/kiwi/packages/*
rm -rf /var/cache/kiwi/zypper/*
echo

echo "Cleaning up Download directories ..."
rm -rf /root/Downloads/*
rm -rf /home/tux/Downloads/*
echo

echo "Cleaning up Course directories ..."
rm -rf /home/tux/course_files/*
rm -rf /home/tux/scripts/*
rm -rf /home/tux/pdf/*
rm -rf /home/iso/*
rm -rf /home/images/*
rm -rf /home/VMs/*
echo

echo "Removing machine profile from Machinery ..."
machinery remove localhost
echo

echo "Cleaning up logs ..."
journalctl --vacuum-time 1m
echo

echo
echo "========================================================================="
echo "Kicking off Machinery inspection and export ..."
echo
machinery inspect -x localhost
machinery export-kiwi -k /tmp/kiwi-export/ localhost
mv /tmp/kiwi-export/localhost-kiwi /tmp/kiwi-export/${OS_IMAGE_NAME}-${VERSION}

