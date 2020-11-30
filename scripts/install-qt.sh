#!/bin/bash
# Aurélien Brooke - License: MIT

if [ -z "$QT_VERSION" ]; then
    echo "Please define the QT_VERSION environment variable as desired"
    exit 1
fi

if [ -z "$QT_PATH" ]; then
    echo "Please define the QT_PATH environment variable as desired"
    exit 1
fi

if [ -z "$QT_PLATFORM" ]; then
    echo "Please define the QT_PLATFORM environment variable as desired"
    exit 1
fi

set -e #quit on error

mkdir /tmp/qt
sudo apt update && sudo apt install python3 python3-pip -y
pip3 install aqtinstall
sudo aqt install --outputdir ${QT_PATH} ${QT_VERSION} linux android ${QT_PLATFORM} -m qtcharts
find "${QT_PATH}" -mindepth 1 -maxdepth 1 ! -name "${QT_VERSION}" -exec echo 'Cleaning Qt SDK: {}' \; -exec rm -r '{}' \;
rm -rf /tmp/qt
