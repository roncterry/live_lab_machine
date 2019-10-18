#!/bin/bash
#
# version: 2.1.1
# date: 2019-02-20

KIWI_TEMPLATE_DIR="/opt/image_building"
KIWI_EXPORT_DIR="/tmp/kiwi-export"
KIWI_BUILD_BASE_DIR="/tmp/kiwi-build"

if [ -z ${1} ]
then
  source /etc/os-release
  OS_IMAGE_NAME="$(echo ${NAME} | sed 's/ /_/g')"
else
  if [ -e "${KIWI_EXPORT_DIR}/${1}/config.xml" ]
  then
    OS_IMAGE_NAME="$(grep "<image schemaversion" ${KIWI_EXPORT_DIR}/${1}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 1)"
    VERSION="$(grep "<image schemaversion" ${KIWI_EXPORT_DIR}/${1}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 2)"
  else
    echo
    echo "ERROR:  No Kiwi confguration found in ${1}"
    echo
    exit 1
  fi
fi

BUILD_TYPE_LIST="iso oem vmx aws azure gce"

echo
echo "#########################################################################"
echo "  Cleaning up Kiwi build for: ${OS_IMAGE_NAME}-${VERSION}"
echo "#########################################################################"
echo

echo "Removing kiwi build directory files ..."
for BUILD_TYPE in ${BUILD_TYPE_LIST}
do
  if [ -d ${KIWI_BUILD_BASE_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE} ]
  then
    rm -rf ${KIWI_BUILD_BASE_DIR}/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/*
  fi
echo
done

echo "Removing kiwi build config files ..."
rm -rf ${KIWI_EXPORT_DIR}/${OS_IMAGE_NAME}-${VERSION}*/
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

echo "Removing NICs from 70-persistent-net.rules ..."
sed -i '/^SUBSYSTEM.*/d' /etc/udev/rules.d/70-persistent-net.rules
sed -i '/^# PCI*/d' /etc/udev/rules.d/70-persistent-net.rules
sed -i '/^# USB*/d' /etc/udev/rules.d/70-persistent-net.rules
echo

echo "Removing machine ID ..."
echo > /var/lib/dbus/machine-id
echo

echo "Removing SSH host keys ..."
rm -f /etc/ssh/ssh_host_*_key*
echo

echo "Cleaning up logs ..."
journalctl --vacuum-time 1m
echo

echo "Cleaning ssh know_hosts ..."
echo "" > /root/.ssh/known_hosts
for U_NAME in tux
do
  echo "" > /home/${U_NAME}/.ssh/known_hosts
done
echo

echo "Cleaning up cloud-init logs ..."
[ -e /var/log/cloud-init.log ] && echo "" > /var/log/cloud-init.log
[ -e /var/log/cloud-init-output.log ] && echo "" > /var/log/cloud-init-output.log
echo

echo "-- Finished --"

