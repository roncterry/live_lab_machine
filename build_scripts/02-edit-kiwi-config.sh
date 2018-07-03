#!/bin/bash
#
# version: 1.1.0
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

echo
echo "#########################################################################"
echo "  Editing Kiwi config for: ${OS_IMAGE_NAME}-${VERSION}"
echo "#########################################################################"
echo
sleep 2

if [ -e ./config.xml ]
then
  vimdiff config.xml ${OS_IMAGE_NAME}-${VERSION}/config.xml
else
  echo
  echo "No template config.xml found. Skipping"
  echo
  sleep 2
fi

if [ -e ./config.sh ]
then
  vimdiff config.sh ${OS_IMAGE_NAME}-${VERSION}/config.sh
else
  echo
  echo "No template config.sh found. Skipping"
  echo
fi
