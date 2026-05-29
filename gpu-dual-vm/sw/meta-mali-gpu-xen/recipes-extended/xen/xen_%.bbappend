# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
#
# Append GPU Kconfig fragment to Xen build.
# xen-gpu.cfg is generated from 'make menuconfig' and contains:
#   - DTB overlay support
#   - Mali G78AE GPU passthrough support
#   - Null scheduler as default

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://xen-gpu.cfg"
