#!/bin/bash
# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------
# setup-imagebuilder.sh
#
# Clones the Xilinx imagebuilder repository and applies the
# GPU + DP enablement patch.
#
# Usage: bash setup-imagebuilder.sh [ARTIFACTS_DIR]
#
# ARTIFACTS_DIR defaults to <script-dir>/artifacts

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARTIFACTS_DIR="${1:-$SCRIPT_DIR/artifacts}"
IMAGEBUILDER_DIR="$ARTIFACTS_DIR/imagebuilder"

IMAGEBUILDER_URL="https://github.com/Xilinx/imagebuilder.git"
IMAGEBUILDER_BRANCH="xlnx_rel_v2025.2"

PATCH="$SCRIPT_DIR/0001-GPU-DP-enablement.patch"

# Colors
COLOR_RESET='\033[0m'
COLOR_GREEN='\033[32m'
COLOR_YELLOW='\033[33m'
COLOR_CYAN='\033[36m'
COLOR_BOLD='\033[1m'

printf "%b\n" "${COLOR_CYAN}${COLOR_BOLD}=== Setting up imagebuilder ===${COLOR_RESET}"
echo ""
echo "  Target dir : $IMAGEBUILDER_DIR"
echo "  Branch     : $IMAGEBUILDER_BRANCH"
echo "  Patch      : $PATCH"
echo ""

# --- Validate patch exists ---
if [ ! -f "$PATCH" ]; then
    printf "%b\n" "${COLOR_YELLOW}Error: patch file not found: $PATCH${COLOR_RESET}"
    exit 1
fi

# --- Create artifacts dir ---
mkdir -p "$ARTIFACTS_DIR"

# --- Clone or update ---
if [ ! -d "$IMAGEBUILDER_DIR/.git" ]; then
    echo "Cloning imagebuilder (branch: $IMAGEBUILDER_BRANCH)..."
    git clone \
        --branch "$IMAGEBUILDER_BRANCH" \
        --single-branch \
        --depth 1 \
        "$IMAGEBUILDER_URL" \
        "$IMAGEBUILDER_DIR" || {
        printf "%b\n" "${COLOR_YELLOW}Error: git clone failed${COLOR_RESET}"
        exit 1
    }
    printf "%b\n" "${COLOR_GREEN}✓${COLOR_RESET} Cloned imagebuilder"
else
    echo "imagebuilder already cloned at $IMAGEBUILDER_DIR, skipping clone"
fi

# --- Check if patch already applied ---
cd "$IMAGEBUILDER_DIR"

if git log --oneline | grep -q "GPU + DP enablement"; then
    printf "%b\n" "${COLOR_GREEN}✓${COLOR_RESET} Patch already applied, skipping"
else
    echo "Applying patch: 0001-GPU-DP-enablement.patch ..."
    git am "$PATCH" || {
        printf "%b\n" "${COLOR_YELLOW}Warning: git am failed, trying patch -p1${COLOR_RESET}"
        git am --abort 2>/dev/null || true
        patch -p1 < "$PATCH" || {
            printf "%b\n" "${COLOR_YELLOW}Error: patch failed to apply${COLOR_RESET}"
            exit 1
        }
    }
    printf "%b\n" "${COLOR_GREEN}✓${COLOR_RESET} Patch applied successfully"
fi

echo ""
printf "%b\n" "${COLOR_GREEN}${COLOR_BOLD}imagebuilder setup complete${COLOR_RESET}"
echo ""
echo "  Location : $IMAGEBUILDER_DIR"
echo "  Scripts  : $IMAGEBUILDER_DIR/scripts/"
echo ""
