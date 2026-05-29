# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------
# ==============================================================================
# Makefile for GPU Dual-VM TRD Build Automation
# Platform: VEK385 Rev B with GPU Virtualization (Xen Dual-VM)
# ==============================================================================

#===============================================================================
# Build Configuration Variables
#===============================================================================

# Use current directory where Makefile is running
WORK_DIR := $(shell pwd)
BUILD_BASE := $(WORK_DIR)

# Yocto repository configuration (clones to current path)
REPO_URL := https://storage.googleapis.com/git-repo-downloads/repo
REPO_MANIFEST_URL := https://github.com/Xilinx/yocto-manifests.git
REPO_BRANCH := refs/tags/amd-edf-rel-v25.11
REPO_MANIFEST_FILE := default-edf.xml
YOCTO_DIR := $(BUILD_BASE)/yocto-edf-25.11

# Build target configuration
MACHINE_BOOTBIN := versal-2ve-2vm-vek385-revb-sdt-seg
MACHINE_ROOTFS := amd-cortexa78-mali-common
SDT_DIR := $(BUILD_BASE)/../hw/gpu_sdt
VEK385_TEMPLATE := sources/meta-amd-adaptive-socs/meta-amd-adaptive-socs-bsp/conf/machineyaml/versal-2ve-2vm-vek385-revb-sdt-seg.yaml

# Image targets
IMAGE_OSPI := edf-ospi
IMAGE_ROOTFS := edf-linux-disk-image
IMAGE_DOMU := core-image-minimal

# Detect if current path is on NFS filesystem
# Checks for 'nfs' or 'nfs4' filesystem type
IS_NFS := $(shell df -T $(WORK_DIR) 2>/dev/null | awk 'NR==2 {print $$2}' | grep -qE '^nfs' && echo "yes" || echo "no")

# Set YOCTO_TMP_DIR based on NFS detection
# NFS builds should use local tmp to avoid NFS performance issues
ifeq ($(IS_NFS),yes)
    YOCTO_TMP_DIR := $(BUILD_BASE)/tmp
    $(info *** NFS filesystem detected ***)
    $(info *** Using local TMP_DIR: $(YOCTO_TMP_DIR) ***)
else
    YOCTO_TMP_DIR := $(BUILD_BASE)/tmp
    $(info *** Local filesystem detected ***)
    $(info *** Using local TMP_DIR: $(YOCTO_TMP_DIR) ***)
endif

# Build environment
SHELL := /bin/bash

# Parallel build jobs (adjust based on your system)
PARALLEL_MAKE ?= $(shell nproc)
BB_NUMBER_THREADS ?= $(shell nproc)

#===============================================================================
# Color output for better readability
#===============================================================================

COLOR_RESET := \033[0m
COLOR_BOLD := \033[1m
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m
COLOR_BLUE := \033[34m
COLOR_CYAN := \033[36m

#===============================================================================
# Phony Targets
#===============================================================================

.PHONY: all setup sync clone-custom-layers configure-xen configure-kernel-patches configure-layers configure-local \
        gen-sdt gen-machine build-bootbin build-domu build-rootfs build artifacts \
        clean-machineconf help info

#===============================================================================
# Default Target
#===============================================================================

all: build
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)$(COLOR_BOLD)================================================$(COLOR_RESET)"
	@printf "%b\n" "$(COLOR_GREEN)$(COLOR_BOLD)  GPU Dual-VM TRD Build Complete!$(COLOR_RESET)"
	@printf "%b\n" "$(COLOR_GREEN)$(COLOR_BOLD)================================================$(COLOR_RESET)"
	@echo ""
	@echo "Output artifacts location:"
	@echo "  $(BUILD_BASE)/artifacts/"
	@echo ""

#===============================================================================
# Help Target
#===============================================================================

help:
	@echo "GPU Dual-VM TRD Makefile - Available Targets:"
	@echo ""
	@echo "  make all              - Complete build (setup → build → artifacts)"
	@echo "  make setup            - Download repo tool"
	@echo "  make sync             - Initialize and sync Yocto repositories"
	@echo "  make clone-custom-layers - Verify meta-mali-gpu-xen exists in current dir"
	@echo "  make configure-xen    - Configure Xen with GPU settings (automated)"
	@echo "  make configure-layers - Configure bblayers.conf"
	@echo "  make configure-local  - Configure local.conf with GPU packages"
	@echo "  make gen-sdt          - Generate System Device Tree from XSA"
	@echo "  make gen-machine      - Generate machine configuration"
	@echo "  make build-bootbin    - Build boot.bin (OSPI image)"
	@echo "  make build-domu       - Build DomU image (core-image-minimal)"
	@echo "  make build-rootfs     - Build Dom0 rootfs (edf-linux-disk-image)"
	@echo "  make build            - Build all images"
	@echo "  make artifacts        - Copy built images to artifacts directory"
	@echo "  make clean-machineconf - Clean machine configuration"
	@echo "  make info             - Display build configuration"
	@echo "  make help             - Show this help message"
	@echo ""
	@echo "Prerequisites:"
	@echo "  - Source Vitis tools before running 'make gen-sdt'"
	@echo "  - Ensure XSA file exists at: ../../hw/<xsa-file>.xsa"
	@echo ""

#===============================================================================
# Setup: Create directories and download repo tool
#===============================================================================

setup:
	@if [ ! -f $(BUILD_BASE)/repo ]; then \
		printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Setting up build environment ===$(COLOR_RESET)"; \
		echo "Downloading repo tool from Google..."; \
		curl -L -s -o $(BUILD_BASE)/repo $(REPO_URL) || { \
			printf "%b\n" "$(COLOR_YELLOW)Error: Failed to download repo tool$(COLOR_RESET)"; \
			exit 1; \
		}; \
		chmod +x $(BUILD_BASE)/repo; \
		echo "Repo tool downloaded successfully"; \
	else \
		echo "Repo tool already exists at $(BUILD_BASE)/repo"; \
	fi
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)Setup complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Sync: Initialize and sync Yocto repositories
#===============================================================================

sync: setup
	@if [ ! -d $(YOCTO_DIR)/.repo ]; then \
		printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Syncing Yocto repositories ===$(COLOR_RESET)"; \
		echo "Initializing repo in $(YOCTO_DIR)..."; \
		mkdir -p $(YOCTO_DIR); \
		cd $(YOCTO_DIR) && $(BUILD_BASE)/repo init \
			-u $(REPO_MANIFEST_URL) \
			-b $(REPO_BRANCH) \
			-m $(REPO_MANIFEST_FILE) || { \
			printf "%b\n" "$(COLOR_YELLOW)Error: repo init failed$(COLOR_RESET)"; \
			exit 1; \
		}; \
		echo "Repo initialized successfully"; \
	else \
		echo "Repo already initialized in $(YOCTO_DIR)"; \
	fi
	@if [ ! -d $(YOCTO_DIR)/sources ]; then \
		echo "Syncing repositories (this may take 10-30 minutes on first run)..."; \
		cd $(YOCTO_DIR) && $(BUILD_BASE)/repo sync -j$(PARALLEL_MAKE) || { \
			printf "%b\n" "$(COLOR_YELLOW)Error: repo sync failed$(COLOR_RESET)"; \
			echo "Try running: cd $(YOCTO_DIR) && $(BUILD_BASE)/repo sync"; \
			exit 1; \
		} \
	fi
	@printf "%b\n" "$(COLOR_GREEN)Repository sync complete$(COLOR_RESET)"

#===============================================================================
# Configure Xen: Apply GPU configuration fragment to Xen
#===============================================================================

configure-xen: clone-custom-layers
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Configuring Xen for GPU ===$(COLOR_RESET)"
	@mkdir -p $(BUILD_BASE)/meta-mali-gpu-xen/recipes-extended/xen/files
	@if [ -f $(BUILD_BASE)/xen-gpu.cfg ]; then \
		cp $(BUILD_BASE)/xen-gpu.cfg $(BUILD_BASE)/meta-mali-gpu-xen/recipes-extended/xen/files/xen-gpu.cfg; \
		printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) xen-gpu.cfg copied from $(BUILD_BASE)/xen-gpu.cfg"; \
	elif [ ! -f $(BUILD_BASE)/meta-mali-gpu-xen/recipes-extended/xen/files/xen-gpu.cfg ]; then \
		printf "%b\n" "$(COLOR_YELLOW)Warning: xen-gpu.cfg not found — creating empty placeholder$(COLOR_RESET)"; \
		echo "# Placeholder: replace with output of 'make menuconfig' for xen" > $(BUILD_BASE)/meta-mali-gpu-xen/recipes-extended/xen/files/xen-gpu.cfg; \
		echo "# Run: make configure-xen   after saving your menuconfig selections" >> $(BUILD_BASE)/meta-mali-gpu-xen/recipes-extended/xen/files/xen-gpu.cfg; \
		printf "%b\n" "$(COLOR_YELLOW)  Edit xen-gpu.cfg then re-run 'make configure-xen' to apply$(COLOR_RESET)"; \
	else \
		echo "xen-gpu.cfg already present in layer files dir"; \
	fi
	@echo ""
	@echo "  Layer path: meta-mali-gpu-xen/recipes-extended/xen/files/xen-gpu.cfg"
	@echo "  bbappend:   meta-mali-gpu-xen/recipes-extended/xen/xen_%%.bbappend"
	@echo "  Bitbake will apply the fragment automatically during 'do_configure'"
	@printf "%b\n" "$(COLOR_GREEN)Xen configuration complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Clone Custom Layers: Verify meta-mali-gpu-xen exists in current directory
#===============================================================================

clone-custom-layers: sync
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Cloning custom layers ===$(COLOR_RESET)"
	@if [ ! -d $(BUILD_BASE)/meta-mali-gpu-xen ]; then \
		printf "%b\n" "$(COLOR_YELLOW)Error: meta-mali-gpu-xen not found at $(BUILD_BASE)/meta-mali-gpu-xen$(COLOR_RESET)"; \
		exit 1; \
	else \
		echo "meta-mali-gpu-xen found at $(BUILD_BASE)/meta-mali-gpu-xen"; \
	fi
	@printf "%b\n" "$(COLOR_GREEN)Custom layers verified$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Configure Kernel Patches: Copy patches into meta-mali-gpu-xen layer
#===============================================================================

configure-kernel-patches: clone-custom-layers
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Configuring kernel patches ===$(COLOR_RESET)"
	@PATCH_DST=$(BUILD_BASE)/meta-mali-gpu-xen/recipes-kernel/linux/linux-xlnx; \
	mkdir -p $$PATCH_DST; \
	for patch in $(BUILD_BASE)/*.patch; do \
		[ -f "$$patch" ] || continue; \
		cp "$$patch" $$PATCH_DST/; \
		printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) Staged kernel patch: $$(basename $$patch)"; \
	done
	@printf "%b\n" "$(COLOR_GREEN)Kernel patch staging complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Configure Layers: Add meta-mali-gpu-xen to bblayers.conf
#===============================================================================

configure-layers: configure-xen configure-kernel-patches
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Configuring build layers ===$(COLOR_RESET)"
	@if [ ! -f $(YOCTO_DIR)/build/conf/bblayers.conf ]; then \
		echo "Initializing build environment..."; \
		cd $(YOCTO_DIR) && source edf-init-build-env; \
	fi
	@META_LAYER_PATH=$$(cd $(BUILD_BASE)/meta-mali-gpu-xen && pwd); \
	if ! grep -q "meta-mali-gpu-xen" $(YOCTO_DIR)/build/conf/bblayers.conf 2>/dev/null; then \
		echo "Adding meta-mali-gpu-xen layer to bblayers.conf..."; \
		echo "BBLAYERS += \"$$META_LAYER_PATH\"" >> $(YOCTO_DIR)/build/conf/bblayers.conf; \
		echo "  Added: $$META_LAYER_PATH"; \
	else \
		echo "meta-mali-gpu-xen layer already configured"; \
	fi
	@printf "%b\n" "$(COLOR_GREEN)Layer configuration complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Configure Local: Set up local.conf with GPU packages
#===============================================================================

configure-local: configure-layers
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Configuring local.conf ===$(COLOR_RESET)"
	@if [ ! -f $(YOCTO_DIR)/build/conf/local.conf ]; then \
		printf "%b\n" "$(COLOR_YELLOW)Error: local.conf not found$(COLOR_RESET)"; \
		exit 1; \
	fi
	@# Set TMPDIR
	@if ! grep -q '^TMPDIR = ' $(YOCTO_DIR)/build/conf/local.conf 2>/dev/null; then \
		echo 'TMPDIR = "$(YOCTO_TMP_DIR)"' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '  Added TMPDIR = $(YOCTO_TMP_DIR)'; \
	fi
	@# Set parallel build options
	@if ! grep -q '^PARALLEL_MAKE = ' $(YOCTO_DIR)/build/conf/local.conf 2>/dev/null; then \
		echo 'PARALLEL_MAKE = "-j $(PARALLEL_MAKE)"' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '  Set PARALLEL_MAKE to -j$(PARALLEL_MAKE)'; \
	fi
	@if ! grep -q '^BB_NUMBER_THREADS = ' $(YOCTO_DIR)/build/conf/local.conf 2>/dev/null; then \
		echo 'BB_NUMBER_THREADS = "$(BB_NUMBER_THREADS)"' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '  Set BB_NUMBER_THREADS to $(BB_NUMBER_THREADS)'; \
	fi
	@# Add GPU and demo packages
	@if ! grep -q 'IMAGE_INSTALL:append.*glmark2' $(YOCTO_DIR)/build/conf/local.conf 2>/dev/null; then \
		echo '' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '# GPU Dual-VM Demo Packages' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo 'IMAGE_INSTALL:append = " \' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '    glmark2 kmscube kernel-module-hdmi21 packagegroup-xilinx-gstreamer \' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '    libdrm libdrm-tests v4l-utils media-ctl yavta clinfo \' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '    packagegroup-core-weston vulkan-loader packagegroup-xilinx-qt \' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '    devmem2 mesa-demos ydotool \' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '    kernel-module-mmi-dc kernel-module-mmi-dcdma kernel-module-mmi-dptx \' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '     \' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '"' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '  Added GPU packages to IMAGE_INSTALL'; \
	fi
	@# Add Qt and Weston configuration
	@if ! grep -q 'PACKAGECONFIG:append:pn-qtbase' $(YOCTO_DIR)/build/conf/local.conf 2>/dev/null; then \
		echo 'PACKAGECONFIG:append:pn-qtbase = " linuxfb gles2 eglfs"' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo 'PACKAGECONFIG:append:pn-weston = " screenshare rdp"' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '  Added Qt and Weston configurations'; \
	fi
	@# Add image format for DomU
	@if ! grep -q 'IMAGE_FSTYPES:append.*cpio.gz' $(YOCTO_DIR)/build/conf/local.conf 2>/dev/null; then \
		echo 'IMAGE_FSTYPES:append = " cpio.gz cpio.gz.u-boot "' >> $(YOCTO_DIR)/build/conf/local.conf; \
		echo '  Added cpio.gz image format for DomU'; \
	fi
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)local.conf configuration complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Generate SDT: Generate System Device Tree from XSA using sdtgen
# NOTE: User must source Vitis tools before running this target
#===============================================================================

gen-sdt: configure-local
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Checking SDT directory ===$(COLOR_RESET)"
	@if [ ! -d "$(SDT_DIR)" ]; then \
		printf "%b\n" "$(COLOR_YELLOW)Error: SDT directory not found at $(SDT_DIR)$(COLOR_RESET)"; \
		echo ""; \
		echo "Please run 'make' in ../hw/ directory first to generate SDT"; \
		echo ""; \
		exit 1; \
	fi
	@echo "SDT directory found: $(SDT_DIR)"
	@printf "%b\n" "$(COLOR_GREEN)SDT check complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Generate Machine: Parse SDT and generate machine configuration
#===============================================================================

gen-machine: gen-sdt
	@if [ ! -d $(YOCTO_DIR)/build/conf/dts ]; then \
		printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Generating machine configuration ===$(COLOR_RESET)"; \
		echo ""; \
		echo "Machine:  $(MACHINE_BOOTBIN)"; \
		echo "Template: $(VEK385_TEMPLATE)"; \
		echo "SDT Dir:  $(BUILD_BASE)/gpu_sdt"; \
		echo ""; \
		echo "Parsing hardware description and generating device tree..."; \
		cd $(YOCTO_DIR) && \
		source edf-init-build-env && \
		gen-machineconf parse-sdt \
			--template ../$(VEK385_TEMPLATE) \
			--hw-description $(BUILD_BASE)/../hw/gpu_sdt || { \
			printf "%b\n" "$(COLOR_YELLOW)Error: Failed to generate machine configuration$(COLOR_RESET)"; \
			exit 1; \
		}; \
		echo ""; \
		printf "%b\n" "$(COLOR_GREEN)Machine configuration generated: $(MACHINE_BOOTBIN)$(COLOR_RESET)"; \
		echo ""; \
	else \
		echo ""; \
		echo "Machine configuration already exists"; \
	fi
	@printf "%b\n" "$(COLOR_GREEN)gen-machineconf complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Build boot.bin: Build OSPI boot image
#===============================================================================

build-bootbin: gen-machine
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Building OSPI image ===$(COLOR_RESET)"
	@echo ""
	@echo "Target:  $(IMAGE_OSPI)"
	@echo "Machine: $(MACHINE_BOOTBIN)"
	@echo ""
	@cd $(YOCTO_DIR) && \
		bash -c "source edf-init-build-env && \
		MACHINE=$(MACHINE_BOOTBIN) bitbake $(IMAGE_OSPI)" || { \
		printf "%b\n" "$(COLOR_YELLOW)Error: OSPI image build failed$(COLOR_RESET)"; \
		exit 1; \
	}
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)OSPI image build complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Build DomU: Build DomU image (core-image-minimal)
#===============================================================================

build-domu: configure-local
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Building DomU image ===$(COLOR_RESET)"
	@echo ""
	@echo "Target:  $(IMAGE_DOMU)"
	@echo "Machine: $(MACHINE_ROOTFS)"
	@echo ""
	@cd $(YOCTO_DIR) && \
		bash -c "source edf-init-build-env && \
		MACHINE=$(MACHINE_ROOTFS) bitbake $(IMAGE_DOMU)" || { \
		printf "%b\n" "$(COLOR_YELLOW)Error: DomU image build failed$(COLOR_RESET)"; \
		exit 1; \
	}
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)DomU image build complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Build RootFS: Build Dom0 root filesystem (edf-linux-disk-image)
#===============================================================================

build-rootfs: configure-local
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Building Dom0 root filesystem ===$(COLOR_RESET)"
	@echo ""
	@echo "Target:  $(IMAGE_ROOTFS)"
	@echo "Machine: $(MACHINE_ROOTFS)"
	@echo ""
	@cd $(YOCTO_DIR) && \
		bash -c "source edf-init-build-env && \
		MACHINE=$(MACHINE_ROOTFS) bitbake $(IMAGE_ROOTFS)" || { \
		printf "%b\n" "$(COLOR_YELLOW)Error: Root filesystem build failed$(COLOR_RESET)"; \
		exit 1; \
	}
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)Root filesystem build complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Build: Build all images (boot.bin, DomU, Dom0)
#===============================================================================

build: build-bootbin build-domu build-rootfs artifacts
	@printf "%b\n" "$(COLOR_GREEN)$(COLOR_BOLD)=== All images built successfully ===$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Artifacts: Copy built images to artifacts directory
#===============================================================================

artifacts: build-bootbin build-domu build-rootfs
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Copying artifacts ===$(COLOR_RESET)"
	@mkdir -p $(BUILD_BASE)/artifacts
	@set -e; \
	DEPLOY_DIR_OSPI="$(YOCTO_TMP_DIR)/deploy/images/$(MACHINE_BOOTBIN)"; \
	DEPLOY_DIR_ROOTFS="$(YOCTO_TMP_DIR)/deploy/images/$(MACHINE_ROOTFS)"; \
	echo "Copying from:"; \
	echo "  OSPI:     $$DEPLOY_DIR_OSPI"; \
	echo "  Images:   $$DEPLOY_DIR_ROOTFS"; \
	echo ""; \
	OSPI_SRC="$$DEPLOY_DIR_OSPI/edf-ospi-$(MACHINE_BOOTBIN).bin"; \
	if [ -f "$$OSPI_SRC" ]; then \
		cp "$$OSPI_SRC" $(BUILD_BASE)/artifacts/; \
		printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) Copied edf-ospi-$(MACHINE_BOOTBIN).bin"; \
	else \
		printf "%b\n" "$(COLOR_YELLOW)⚠$(COLOR_RESET) OSPI bin not found: $$OSPI_SRC"; \
	fi; \
	if [ -f "$$DEPLOY_DIR_ROOTFS/edf-linux-disk-image-$(MACHINE_ROOTFS).rootfs.wic" ]; then \
		cp "$$DEPLOY_DIR_ROOTFS/edf-linux-disk-image-$(MACHINE_ROOTFS).rootfs.wic" $(BUILD_BASE)/artifacts/; \
		printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) Copied edf-linux-disk-image.wic"; \
	else \
		printf "%b\n" "$(COLOR_YELLOW)⚠$(COLOR_RESET) .wic image not found"; \
	fi; \
	if [ -f "$$DEPLOY_DIR_ROOTFS/edf-linux-disk-image-$(MACHINE_ROOTFS).rootfs.wic.bmap" ]; then \
		cp "$$DEPLOY_DIR_ROOTFS/edf-linux-disk-image-$(MACHINE_ROOTFS).rootfs.wic.bmap" $(BUILD_BASE)/artifacts/; \
		printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) Copied .wic.bmap"; \
	else \
		printf "%b\n" "$(COLOR_YELLOW)⚠$(COLOR_RESET) .wic.bmap not found"; \
	fi; \
	if [ -f "$$DEPLOY_DIR_ROOTFS/core-image-minimal-$(MACHINE_ROOTFS).rootfs.cpio.gz" ]; then \
		cp "$$DEPLOY_DIR_ROOTFS/core-image-minimal-$(MACHINE_ROOTFS).rootfs.cpio.gz" $(BUILD_BASE)/artifacts/; \
		printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) Copied DomU cpio.gz"; \
	else \
		printf "%b\n" "$(COLOR_YELLOW)⚠$(COLOR_RESET) DomU cpio.gz not found"; \
	fi; \
	if [ -f "$$DEPLOY_DIR_ROOTFS/Image" ]; then \
		cp "$$DEPLOY_DIR_ROOTFS/Image" $(BUILD_BASE)/artifacts/; \
		printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) Copied Image"; \
	else \
		printf "%b\n" "$(COLOR_YELLOW)⚠$(COLOR_RESET) Image not found"; \
	fi; \
	PL_DTSI="$(YOCTO_DIR)/build/conf/dts/$(MACHINE_BOOTBIN)/pl-overlay-full/pl.dtsi"; \
	if [ -f "$$PL_DTSI" ]; then \
		cp "$$PL_DTSI" $(BUILD_BASE)/artifacts/pl.dtsi; \
		printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) Copied pl.dtsi"; \
	else \
		printf "%b\n" "$(COLOR_YELLOW)⚠$(COLOR_RESET) pl.dtsi not found"; \
	fi; \
	if [ -f "$$DEPLOY_DIR_OSPI/system.dts" ]; then \
		cp "$$DEPLOY_DIR_OSPI/system.dts" $(BUILD_BASE)/artifacts/; \
		printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) Copied system.dts"; \
	fi; \
	if [ -f "$$DEPLOY_DIR_OSPI/system.dtb" ]; then \
		cp "$$DEPLOY_DIR_OSPI/system.dtb" $(BUILD_BASE)/artifacts/; \
		printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) Copied system.dtb"; \
	fi
	@echo ""
	@echo "Generating MD5 checksums..."
	@cd $(BUILD_BASE)/artifacts && md5sum edf-ospi-*.bin edf-linux-disk-image-*.wic edf-linux-disk-image-*.wic.bmap > MD5SUMS.txt 2>/dev/null || true
	@printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) Generated MD5SUMS.txt"
	@echo ""
	@echo "Artifacts directory contents:"
	@ls -lh $(BUILD_BASE)/artifacts/
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)Artifacts copy complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Clean Machine Configuration: Remove generated machine config files
#===============================================================================

clean-machineconf:
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Cleaning machine configuration ===$(COLOR_RESET)"
	@if [ -d "$(YOCTO_DIR)/build/conf/dts" ]; then \
		rm -rf "$(YOCTO_DIR)/build/conf/dts"; \
		printf "%b\n" "$(COLOR_GREEN)Removed: $(YOCTO_DIR)/build/conf/dts$(COLOR_RESET)"; \
	else \
		printf "%b\n" "$(COLOR_YELLOW)Directory does not exist: $(YOCTO_DIR)/build/conf/dts$(COLOR_RESET)"; \
	fi
	@if [ -d "$(BUILD_BASE)/gpu_sdt" ]; then \
		rm -rf "$(BUILD_BASE)/gpu_sdt"; \
		printf "%b\n" "$(COLOR_GREEN)Removed: $(BUILD_BASE)/gpu_sdt$(COLOR_RESET)"; \
	fi
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)Machine configuration cleanup complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Information Display
#===============================================================================

info:
	@echo "GPU Dual-VM TRD Build Configuration:"
	@echo "======================================"
	@echo "Working Directory:    $(WORK_DIR)"
	@echo "Yocto Directory:      $(YOCTO_DIR)"
	@echo "TMP Directory:        $(YOCTO_TMP_DIR)"
	@echo "NFS Detected:         $(IS_NFS)"
	@echo ""
	@echo "Build Targets:"
	@echo "  Boot.bin Machine:   $(MACHINE_BOOTBIN)"
	@echo "  RootFS Machine:     $(MACHINE_ROOTFS)"
	@echo "  Boot Image:         $(IMAGE_OSPI)"
	@echo "  Dom0 Image:         $(IMAGE_ROOTFS)"
	@echo "  DomU Image:         $(IMAGE_DOMU)"
	@echo ""
	@echo "Hardware:"
	@echo "  SDT Directory:      $(BUILD_BASE)/gpu_sdt"
	@echo "  XSA Location:       ../../hw/*.xsa"
	@echo ""
	@echo "Parallel Build:"
	@echo "  PARALLEL_MAKE:      -j$(PARALLEL_MAKE)"
	@echo "  BB_NUMBER_THREADS:  $(BB_NUMBER_THREADS)"
	@echo ""
	@echo "Custom Layers:"
	@echo "  meta-mali-gpu-xen:  $(BUILD_BASE)/meta-mali-gpu-xen"
	@echo ""
