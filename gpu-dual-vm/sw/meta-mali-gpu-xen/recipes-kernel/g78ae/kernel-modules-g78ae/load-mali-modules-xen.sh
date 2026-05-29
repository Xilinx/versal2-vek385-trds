#!/bin/bash

modprobe mali_gpu_aw
modprobe mali_kbase gpu_req_timeout=3000
modprobe dma-buf-test-exporter
