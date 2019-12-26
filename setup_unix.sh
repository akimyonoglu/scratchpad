#!/bin/bash

# VBOX Installed check

# VAGRANT Installed check

VBOX_VERSION=`vboxwebsrv --version 2>&1 | egrep -o "Version [0-9].[0-9].[0-9]$"|awk '{print $2}'`
VBOX_VERSION_MAJOR=`echo ${VBOX_VERSION} | awk -F'.' '{print $1}'`
VBOX_VERSION_MINOR=`echo ${VBOX_VERSION} | awk -F'.' '{print $2}'`

VAGRANT_VERSION=`vagrant --version | awk '{print $2}'`

VAGRANT_VBOX_PROVIDER_FOLDER="/opt/vagrant/embedded/gems/$VAGRANT_VERSION/gems/vagrant-$VAGRANT_VERSION/plugins/providers/virtualbox"
VAGRANT_VBOX_DRIVER_FOLDER="$VAGRANT_VBOX_PROVIDER_FOLDER/driver"
VAGRANT_VBOX_DRIVER_PLUGIN_FILE="$VAGRANT_VBOX_PROVIDER_FOLDER/plugin.rb"
VAGRANT_VBOX_DRIVER_META_FILE="$VAGRANT_VBOX_DRIVER_FOLDER/meta.rb"
VAGRANT_VBOX_DRIVER_FILE="${VAGRANT_VBOX_DRIVER_FOLDER}/version_${VBOX_VERSION_MAJOR}_${VBOX_VERSION_MINOR}.rb"
VAGRANT_VBOX_LATEST_EXISTING_DRIVER=`ls ${VAGRANT_VBOX_DRIVER_FOLDER} | grep "version_${VBOX_VERSION_MAJOR}" | sort -r | head -1| awk -F'.' '{print $1}'`
VAGRANT_VBOX_LATEST_EXISTING_DRIVER_VERSION_MAJOR=`echo ${VAGRANT_VBOX_LATEST_EXISTING_DRIVER}| awk -F'_' '{print $2}'`
VAGRANT_VBOX_LATEST_EXISTING_DRIVER_VERSION_MINOR=`echo ${VAGRANT_VBOX_LATEST_EXISTING_DRIVER}| awk -F'_' '{print $3}'`

# this function cretaes the missing vagrant virtual box driver file
create_vagrant_vbox_driver() {
    if [ -f "${VAGRANT_VBOX_DRIVER_FILE}" ]; then
        echo "Vagrant virtual box driver exists, skipping the fix."
    else
    cat > ${VAGRANT_VBOX_DRIVER_FILE} << EOF
require File.expand_path("../${VAGRANT_VBOX_LATEST_EXISTING_DRIVER}", __FILE__)

module VagrantPlugins
  module ProviderVirtualBox
    module Driver
      # Driver for VirtualBox 6.1.x
      class Version_6_1 < Version_6_0
        def initialize(uuid)
          super

          @logger = Log4r::Logger.new("vagrant::provider::virtualbox_${VBOX_VERSION_MAJOR}_${VBOX_VERSION_MINOR}")
        end
      end
    end
  end
end
EOF
    fi
}

inject_vbox_driver() {
    FILE_TO_CHANGE=$1
    FIX_EXISTS=`grep -i "version_${VBOX_VERSION_MAJOR}_${VBOX_VERSION_MINOR}" ${FILE_TO_CHANGE}`
    if [ -z "$FIX_EXISTS" ]; then
        LINE_TO_CHANGE=`grep -n "Version_${VAGRANT_VBOX_LATEST_EXISTING_DRIVER_VERSION_MAJOR}_${VAGRANT_VBOX_LATEST_EXISTING_DRIVER_VERSION_MINOR}" ${FILE_TO_CHANGE}| awk -F':' '{print $1}'`
        LINE_NO_TO_DUPLICATE=`grep -n "Version_${VAGRANT_VBOX_LATEST_EXISTING_DRIVER_VERSION_MAJOR}_${VAGRANT_VBOX_LATEST_EXISTING_DRIVER_VERSION_MINOR}" ${FILE_TO_CHANGE}| awk -F':' '{print $1}'`
        head -n ${LINE_NO_TO_DUPLICATE} ${FILE_TO_CHANGE} > "${FILE_TO_CHANGE}.tmp"
        tail -1 "${FILE_TO_CHANGE}.tmp" | sed "s/${VAGRANT_VBOX_LATEST_EXISTING_DRIVER_VERSION_MAJOR}_${VAGRANT_VBOX_LATEST_EXISTING_DRIVER_VERSION_MINOR}/${VBOX_VERSION_MAJOR}_${VBOX_VERSION_MINOR}/g" | sed "s/${VAGRANT_VBOX_LATEST_EXISTING_DRIVER_VERSION_MAJOR}\.${VAGRANT_VBOX_LATEST_EXISTING_DRIVER_VERSION_MINOR}/${VBOX_VERSION_MAJOR}\.${VBOX_VERSION_MINOR}/g" >> "${FILE_TO_CHANGE}.tmp"
        tail -n "+$((${LINE_NO_TO_DUPLICATE} + 1))" ${FILE_TO_CHANGE} >> "${FILE_TO_CHANGE}.tmp"
        mv "${FILE_TO_CHANGE}.tmp" "${FILE_TO_CHANGE}"
    else
        echo "Fix exists for $FILE_TO_CHANGE"
    fi
}

# Fix needed check
inject_vbox_driver $VAGRANT_VBOX_DRIVER_META_FILE
inject_vbox_driver $VAGRANT_VBOX_DRIVER_PLUGIN_FILE
create_vagrant_vbox_driver
vagrant up
vagrant ssh
