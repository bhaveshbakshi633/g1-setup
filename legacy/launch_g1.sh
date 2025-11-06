#!/bin/bash

# Launch script for Unitree G1 with WebRTC visualization
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

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
WEBRTC_PORT="${WEBRTC_PORT:-8080}"
HF_REPO="${HF_REPO:-}"

# Mode selection
MODE="${1:-webrtc}"

print_header "Unitree G1 Launch Script"

# Check if IsaacLab exists
if [ ! -d "$ISAACLAB_DIR" ]; then
    print_error "IsaacLab not found at $ISAACLAB_DIR"
    print_info "Please run setup_g1_cloud.sh first"
    exit 1
fi

print_info "Using IsaacLab at: $ISAACLAB_DIR"
print_info "Using Project dir: $PROJECT_DIR"

# Create necessary directories
mkdir -p "$PROJECT_DIR"
mkdir -p "$WORKSPACE_DIR/webrtc_server/public"

# Copy WebRTC files to server directory
print_info "Setting up WebRTC server..."
cp -f webrtc_server.js "$WORKSPACE_DIR/webrtc_server/" 2>/dev/null || true
cp -f viewer.html "$WORKSPACE_DIR/webrtc_server/public/" 2>/dev/null || true
cp -f webrtc_streamer.py "$PROJECT_DIR/" 2>/dev/null || true
cp -f g1_sim_webrtc.py "$PROJECT_DIR/" 2>/dev/null || true
cp -f simple_g1_teleop.py "$PROJECT_DIR/" 2>/dev/null || true

# Function to cleanup background processes
cleanup() {
    print_info "Cleaning up..."
    jobs -p | xargs -r kill 2>/dev/null || true
    exit 0
}

trap cleanup EXIT INT TERM

# Launch based on mode
case "$MODE" in
    "webrtc")
        print_header "Launching with WebRTC Streaming"

        # Start WebRTC server
        print_info "Starting WebRTC server on port $WEBRTC_PORT..."
        cd "$WORKSPACE_DIR/webrtc_server"

        # Check if package.json exists
        if [ ! -f "package.json" ]; then
            print_warning "WebRTC server not set up, installing..."
            cat > package.json <<EOF
{
  "name": "isaaclab-webrtc-viewer",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.2",
    "ws": "^8.14.2"
  }
}
EOF
            npm install
        fi

        PORT=$WEBRTC_PORT node webrtc_server.js &
        WEBRTC_PID=$!
        sleep 3

        # Get server IP
        SERVER_IP=$(hostname -I | awk '{print $1}')
        print_info "WebRTC viewer available at:"
        print_info "  Local:  http://localhost:$WEBRTC_PORT"
        print_info "  Remote: http://$SERVER_IP:$WEBRTC_PORT"

        # Launch Isaac Lab simulation
        print_info "Launching Isaac Lab simulation..."
        cd "$ISAACLAB_DIR"

        HF_ARG=""
        if [ ! -z "$HF_REPO" ]; then
            HF_ARG="--hf_repo $HF_REPO"
            print_info "Using HuggingFace model: $HF_REPO"
        fi

        ./isaaclab.sh -p "$PROJECT_DIR/g1_sim_webrtc.py" \
            --headless \
            --enable_webrtc \
            --webrtc_host localhost \
            --webrtc_port $WEBRTC_PORT \
            $HF_ARG

        ;;

    "simple")
        print_header "Launching Simple Teleoperation (No WebRTC)"
        print_info "This will open the Isaac Lab viewport directly"

        cd "$ISAACLAB_DIR"
        ./isaaclab.sh -p "$PROJECT_DIR/simple_g1_teleop.py"

        ;;

    "test")
        print_header "Running Test Simulation"
        print_info "Testing Isaac Lab installation..."

        cd "$ISAACLAB_DIR"
        ./isaaclab.sh -p source/standalone/tutorials/00_sim/create_empty.py --headless

        print_info "Test completed successfully!"
        ;;

    *)
        print_error "Unknown mode: $MODE"
        echo ""
        echo "Usage: $0 [mode]"
        echo ""
        echo "Modes:"
        echo "  webrtc  - Launch with WebRTC streaming (default)"
        echo "  simple  - Launch simple teleop with native viewer"
        echo "  test    - Run test simulation"
        echo ""
        echo "Environment variables:"
        echo "  WORKSPACE_DIR - Workspace directory (default: ~/g1_workspace)"
        echo "  WEBRTC_PORT   - WebRTC server port (default: 8080)"
        echo "  HF_REPO       - HuggingFace repo for pretrained model"
        echo ""
        echo "Examples:"
        echo "  $0 webrtc"
        echo "  HF_REPO='unitreerobotics/g1-wbc' $0 webrtc"
        echo "  $0 simple"
        exit 1
        ;;
esac

print_info "Done!"
