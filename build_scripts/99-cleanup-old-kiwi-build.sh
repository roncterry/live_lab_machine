#!/bin/bash
#
# version: 1.1.1
# date: 2018-06-26

if [ -z ${1} ]
then
  source /etc/os-release
  OS_IMAGE_NAME="$(echo ${NAME} | sed 's/ /_/g')"
else
  if [ -e "${1}/config.xml" ]
  then
    OS_IMAGE_NAME="$(grep "<image schemaversion" ${1}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 1)"
    VERSION="$(grep "<image schemaversion" ${1}/config.xml | grep -o "name=.*" | cut -d \" -f 2 | cut -d \- -f 2)"
  else
    echo
    echo "ERROR:  No Kiwi confguration found in ${1}"
    echo
    exit 1
  fi
fi

BUILD_TYPE_LIST="iso oem vmx"

echo
echo "#########################################################################"
echo "  Cleaning up Kiwi build for: ${OS_IMAGE_NAME}-${VERSION}"
echo "#########################################################################"
echo

echo "Removing kiwi build directory files ..."
for BUILD_TYPE in ${BUILD_TYPE_LIST}
do
  rm -rf /tmp/kiwi-build/${OS_IMAGE_NAME}-${VERSION}-${BUILD_TYPE}/*
echo
done

echo "Removing kiwi build config files ..."
rm -rf /tmp/kiwi-export/${OS_IMAGE_NAME}-${VERSION}/
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

echo "-- Finished --"

