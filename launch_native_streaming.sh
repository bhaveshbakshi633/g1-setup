#!/bin/bash

# Launch script for Isaac Lab with Native WebRTC Streaming
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/g1_workspace}"
ISAACLAB_DIR="${ISAACLAB_DIR:-$WORKSPACE_DIR/IsaacLab}"
PROJECT_DIR="${PROJECT_DIR:-$WORKSPACE_DIR/g1_project}"
STREAMING_PORT="${STREAMING_PORT:-8211}"

echo "========================================"
echo "Isaac Lab Native Streaming Launcher"
echo "========================================"
echo ""

# Check Isaac Lab
if [ ! -d "$ISAACLAB_DIR" ]; then
    print_error "Isaac Lab not found at $ISAACLAB_DIR"
    print_info "Please run setup_isaac_native_streaming.sh first"
    exit 1
fi

# Get script to run
SCRIPT_FILE="${1:-$PROJECT_DIR/g1_simple_test.py}"

if [ ! -f "$SCRIPT_FILE" ]; then
    print_error "Script not found: $SCRIPT_FILE"
    echo ""
    echo "Usage: $0 [script.py]"
    echo ""
    echo "Available scripts:"
    ls -1 "$PROJECT_DIR"/*.py 2>/dev/null || echo "  (none found)"
    exit 1
fi

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

print_info "Configuration:"
echo "  Isaac Lab:    $ISAACLAB_DIR"
echo "  Script:       $SCRIPT_FILE"
echo "  Server IP:    $SERVER_IP"
echo "  Stream Port:  $STREAMING_PORT"
echo ""

# Instructions for local client
print_info "Instructions for LOCAL machine (your laptop/desktop):"
echo ""
echo "1. Download Isaac Sim WebRTC Streaming Client:"
echo "   https://docs.omniverse.nvidia.com/isaacsim/latest/installation/install_faq.html#streaming-client"
echo ""
echo "   Direct links:"
echo "   - Linux:   https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-linux.AppImage"
echo "   - Windows: https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-windows.zip"
echo "   - Mac x64: https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-mac.zip"
echo "   - Mac ARM: https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-mac-arm64.zip"
echo ""
echo "2. Run the client and connect to:"
echo "   ${SERVER_IP}:${STREAMING_PORT}"
echo ""
echo "3. If using SSH, create tunnel first:"
echo "   ssh -L ${STREAMING_PORT}:localhost:${STREAMING_PORT} user@${SERVER_IP}"
echo "   Then connect to: localhost:${STREAMING_PORT}"
echo ""

print_warning "Make sure port $STREAMING_PORT is accessible!"
print_info "Starting simulation in 5 seconds..."
sleep 5

# Launch with native streaming
cd "$ISAACLAB_DIR"

print_info "Launching Isaac Lab with native streaming..."
echo ""

# Run with streaming enabled
./isaaclab.sh -p "$SCRIPT_FILE" \
    --/app/window/enabled=false \
    --/app/livestream/enabled=true \
    --/app/livestream/port=$STREAMING_PORT \
    --/app/livestream/websocket/enabled=true \
    --/renderer/enabled=true \
    --/renderer/active=true

print_info "Simulation ended."
