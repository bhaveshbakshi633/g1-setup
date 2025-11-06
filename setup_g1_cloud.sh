#!/bin/bash
set -e

echo "========================================"
echo "Starting Isaac Lab + Unitree G1 Setup"
echo "========================================"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running with CUDA
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
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    python3-venv \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libglu1-mesa \
    libxi6 \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
    libx11-6 \
    libegl1 \
    nodejs \
    npm

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

# Install Isaac Lab
print_status "Installing Isaac Lab (this will take a while)..."
./isaaclab.sh --install

print_success "Isaac Lab installed!"

# Verify installation
print_status "Verifying Isaac Lab installation..."
./isaaclab.sh -p source/standalone/tutorials/00_sim/create_empty.py --headless

print_success "Isaac Lab verification complete!"

# Clone Isaac Lab extension template for custom environments
print_status "Setting up custom G1 extension..."
cd "$WORKSPACE_DIR"
if [ ! -d "g1_extension" ]; then
    mkdir -p g1_extension
fi

# Install additional Python packages
print_status "Installing additional Python packages..."
cd "$ISAACLAB_DIR"
./isaaclab.sh -p -m pip install \
    transformers \
    huggingface-hub \
    gymnasium \
    opencv-python \
    websockets \
    aiortc \
    aiohttp \
    numpy \
    torch

print_success "Additional packages installed!"

# Download Unitree G1 assets
print_status "Downloading Unitree G1 assets..."
cd "$WORKSPACE_DIR"
if [ ! -d "unitree_robots" ]; then
    git clone https://github.com/unitreerobotics/unitree_ros.git unitree_robots || print_status "Trying alternative source..."
fi

# Create assets directory in IsaacLab
ASSETS_DIR="$ISAACLAB_DIR/source/extensions/omni.isaac.lab_assets/data/Robots/Unitree"
mkdir -p "$ASSETS_DIR"

print_success "Unitree G1 assets prepared!"

# Setup WebRTC streaming server
print_status "Setting up WebRTC streaming server..."
cd "$WORKSPACE_DIR"
if [ ! -d "webrtc_server" ]; then
    mkdir webrtc_server
fi
cd webrtc_server

# Install STUN/TURN server (coturn) for WebRTC
sudo apt-get install -y coturn

# Create simple web server for WebRTC viewer
cat > package.json <<EOF
{
  "name": "isaaclab-webrtc-viewer",
  "version": "1.0.0",
  "description": "WebRTC viewer for Isaac Lab",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "ws": "^8.14.2"
  }
}
EOF

npm install

print_success "WebRTC server setup complete!"

# Create project directory for our scripts
print_status "Creating project scripts directory..."
cd "$WORKSPACE_DIR"
mkdir -p g1_project
cd g1_project

print_success "Project directory created!"

# Create environment activation script
print_status "Creating environment activation helper..."
cat > activate_env.sh <<EOF
#!/bin/bash
export ISAACLAB_DIR="$ISAACLAB_DIR"
export WORKSPACE_DIR="$WORKSPACE_DIR"
export PROJECT_DIR="$WORKSPACE_DIR/g1_project"
echo "Environment variables set:"
echo "  ISAACLAB_DIR: \$ISAACLAB_DIR"
echo "  WORKSPACE_DIR: \$WORKSPACE_DIR"
echo "  PROJECT_DIR: \$PROJECT_DIR"
EOF

chmod +x activate_env.sh

print_success "Environment helper created!"

# Summary
echo ""
echo "========================================"
print_success "Setup Complete!"
echo "========================================"
echo ""
echo "Environment Details:"
echo "  Workspace: $WORKSPACE_DIR"
echo "  Isaac Lab: $ISAACLAB_DIR"
echo "  Project: $WORKSPACE_DIR/g1_project"
echo ""
echo "Next steps:"
echo "  1. cd $WORKSPACE_DIR/g1_project"
echo "  2. Run the launch script (coming next)"
echo ""
print_success "Ready to run Isaac Lab with Unitree G1!"
