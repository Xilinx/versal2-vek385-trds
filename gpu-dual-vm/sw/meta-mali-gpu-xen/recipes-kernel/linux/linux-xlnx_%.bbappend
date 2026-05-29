FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://gpu-xen.cfg"
SRC_URI += "file://0001-Revert-drivers-firmware-xilinx-Add-support-to-get-th.patch"
SRC_URI += "file://0001-drm-xlnx-hdmi-debounce-HPD-low-to-ignore-sink-side-b.patch"
