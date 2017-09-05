#!/bin/sh
# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This script toggles the power control of the bluetooth adapter to "on"
# if there are bluetooth connected devices; and to "auto" otherwise.

# $1 represents an udev added/changed/removed bluetooth peripheral device.
# It looks like
#  /devices/pci0000:00/0000:00:14.0/usb1/1-8/1-8:1.0/bluetooth/hci0/hci0:3585:18
bluetooth_peripheral_device=$1

# Refer to the following issue about Intel 7260.
#     b/35581558: Samus: BT device disappears
INTEL_CONTROLLER="8087_07dc"

# Only apply this work-around to samus for now.
TARGET_BOARDS="samus"

# Get the device path of bluetooth adapter.
get_bluetooth_adapter_devpath() {
  local path="/sys$1"
  local devpath=""
  while [ "${path}" != "/sys/devices" ] && [ -z "${devpath}" ]; do
    # Check if this is the Intel adapter device.
    if udevadm info "${path}" 2>/dev/null | grep -iq "${INTEL_CONTROLLER}"; then
      devpath="${path}"
      break
    fi
    # Walk up along the device path.
    path=$(dirname "${path}")
  done
  echo "${devpath}"
}

# Extract the board.
BOARD=$(awk -F= '$1 == "CHROMEOS_RELEASE_BOARD" {print $2}' /etc/lsb-release)

# If BOARD is not in the TARGET_BOARDS, exit.
if ! echo "${BOARD}" | grep -q -E "^(${TARGET_BOARDS})$"; then
  exit 0
fi

# The bluetooth adapter device path is the parent path of
# bluetooth_peripheral_device with the following property
#     E: ID_SERIAL=8087_07dc
# which looks like
#     /devices/pci0000:00/0000:00:14.0/usb1/1-8
INTEL_DEVPATH=$(get_bluetooth_adapter_devpath "${bluetooth_peripheral_device}")
if [ -z "${INTEL_DEVPATH}" ]; then
  exit 0
fi

USB_POWER_CONTROL="${INTEL_DEVPATH}/power/control"

# The command "btmgmt con" would list connected bluetooth devices like
#   CD:96:76:EF:09:39 type LE Random
#   EE:4B:AC:F6:E3:15 type LE Random
# and list nothing if there are no connected devices.
NUM_BT_CONN_DEVICES=$(btmgmt con | wc -l)

if [ "${NUM_BT_CONN_DEVICES}" = 0 ]; then
  # AUTO is the default value to save power when USB bus is idle.
  echo "auto" > "${USB_POWER_CONTROL}"
else
  # Make USB bus always on to work around Intel's firmware issue.
  echo "on" > "${USB_POWER_CONTROL}"
fi
