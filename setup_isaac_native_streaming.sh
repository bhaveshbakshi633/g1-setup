#!/bin/bash
set -e

echo "========================================"
echo "Isaac Lab + Native WebRTC Setup"
echo "For Remote GPU Rendering"
echo "========================================"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check GPU
print_status "Checking CUDA availability..."
if ! command -v nvidia-smi &> /dev/null; then
    print_error "nvidia-smi not found. Make sure you're on a GPU instance."
    exit 1
fi
nvidia-smi
print_success "CUDA detected!"

# Update system
print_status "Updating system packages..."
sudo apt-get update
sudo apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3-dev \
    python3-pip \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libglu1-mesa \
    libxi6 \
    libxrandr2

print_success "System packages updated!"

# Set up workspace
WORKSPACE_DIR="$HOME/g1_workspace"
print_status "Creating workspace at $WORKSPACE_DIR..."
mkdir -p "$WORKSPACE_DIR"
cd "$WORKSPACE_DIR"

# Clone Isaac Lab
print_status "Cloning Isaac Lab..."
if [ ! -d "IsaacLab" ]; then
    git clone https://github.com/isaac-sim/IsaacLab.git
    cd IsaacLab
else
    print_status "IsaacLab already exists, pulling latest changes..."
    cd IsaacLab
    git pull
fi

ISAACLAB_DIR="$(pwd)"
print_success "Isaac Lab cloned to $ISAACLAB_DIR"

# Install Isaac Lab (this downloads Isaac Sim)
print_status "Installing Isaac Lab with Isaac Sim..."
print_warning "This will download ~20GB and take 20-40 minutes"
print_status "You can detach from screen if needed (Ctrl+A, D)"
echo ""

./isaaclab.sh --install

print_success "Isaac Lab installed!"

# Enable native streaming in Isaac Sim
print_status "Configuring Isaac Sim for native WebRTC streaming..."

ISAAC_SIM_DIR="$ISAACLAB_DIR/_isaac_sim"

if [ ! -d "$ISAAC_SIM_DIR" ]; then
    print_error "Isaac Sim not found at $ISAAC_SIM_DIR"
    print_error "Installation may have failed. Please check logs above."
    exit 1
fi

# Create streaming configuration
print_status "Creating streaming configuration..."
mkdir -p "$ISAAC_SIM_DIR/kit/configs"

cat > "$ISAAC_SIM_DIR/kit/configs/streaming.toml" <<'EOF'
[settings]
# Enable native streaming
"exts/omni.kit.streamer.webrtc/enabled" = true
"exts/omni.services.streamclient.webrtc/enabled" = true

# Streaming quality
"exts/omni.kit.streamer.webrtc/videoEncodeWidth" = 1920
"exts/omni.kit.streamer.webrtc/videoEncodeHeight" = 1080
"exts/omni.kit.streamer.webrtc/videoEncodeFPS" = 60
"exts/omni.kit.streamer.webrtc/videoBitrate" = 10000000

# Network settings
"exts/omni.services.streamclient.webrtc/port" = 8211
"exts/omni.services.streamclient.webrtc/hostIP" = "0.0.0.0"
EOF

print_success "Streaming configuration created!"

# Create project directory
print_status "Creating project directory..."
cd "$WORKSPACE_DIR"
mkdir -p g1_project
cd g1_project

print_success "Project directory created!"

# Summary
echo ""
echo "========================================"
print_success "Setup Complete!"
echo "========================================"
echo ""
echo "Installation Details:"
echo "  Workspace:     $WORKSPACE_DIR"
echo "  Isaac Lab:     $ISAACLAB_DIR"
echo "  Isaac Sim:     $ISAAC_SIM_DIR"
echo "  Project:       $WORKSPACE_DIR/g1_project"
echo ""
echo "Native WebRTC Streaming:"
echo "  Status:        Enabled"
echo "  Port:          8211"
echo "  Resolution:    1920x1080"
echo "  FPS:           60"
echo ""
echo "Next steps:"
echo "  1. Copy your simulation scripts to g1_project/"
echo "  2. Run simulation with native streaming"
echo "  3. Connect with Isaac Sim WebRTC Client from local machine"
echo ""
echo "Server IP: $(hostname -I | awk '{print $1}')"
echo "Streaming Port: 8211"
echo ""
print_success "Ready to run Isaac Lab with Native Streaming!"
