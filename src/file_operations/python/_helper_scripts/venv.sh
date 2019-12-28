#!/bin/bash
source /home/vagrant/.bash_profile
VENV_NAME="file_operations"
VENV_EXISTS=`workon | grep "${VENV_NAME}"`
if [ -z "${VENV_EXISTS}" ]; then
    mkvirtualenv -p /usr/bin/python3 file_operations
fi
workon file_operations