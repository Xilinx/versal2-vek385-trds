# versal2-vek385-trds

<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1> Versal AI Edge Series Gen 2 - VEK385 Targeted Reference Design </h1>
   </td>
 </tr>
</table>

This project demonstrates Targeted Reference Designs (TRDs) targeting the VEK385 Rev-B board. Each TRD showcases different multi-sensor video capture and display capabilities, providing comprehensive examples for high-performance applications.

The following is a list of Platform Designs available:
| Platform Name  | Description | Links |
| ---------------|------------- | -------------- |
|GPU Dual VM TRD |The Dual-VM GPU TRD provides high-performance virtualized graphics and multi-stream vision processing capabilities: <ul><li>4x IMX623 camera capture -> GPU-based 4-stream stitching in Dom0 -> HDMI display output</li><li>Concurrent DomU GPU workload (glmark2) with real-time performance statistics on DisplayPort output</li><li>Xen-based Dom0/DomU isolation with simultaneous GPU-accelerated applications on two displays</li></ul> | <ul><li>[Documentation](https://xilinx-wiki.atlassian.net/wiki/x/AgC97)</li><li>[Prebuilt images](https://account.amd.com/en/forms/downloads/trd-license-versal-xef.html?filename=gpu-dual-vm-rel-2025-2-prebuilt-images.zip)</li><li>[Sources and License](https://account.amd.com/en/forms/downloads/trd-license-versal-xef.html?filename=gpu-dual-vm-rel-2025-2-sources-licenses.zip)</li></ul>|



# License
Copyright (C) 2026 Advanced Micro Devices, Inc.
SPDX-License-Identifier: MIT
