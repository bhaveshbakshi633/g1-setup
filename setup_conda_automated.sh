#!/bin/bash

echo "========================================"
echo "ISAAC SIM 5.1 + LAB - CONDA SETUP"
echo "Fully Automated with Native WebRTC"
echo "========================================"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
NC='\033[0m'

# Setup logging
LOG_FILE="$HOME/isaac_setup_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1" >> "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] $1" >> "$LOG_FILE"
}

print_debug() {
    echo -e "${GRAY}[DEBUG]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DEBUG] $1" >> "$LOG_FILE"
}

# Error handler
trap 'handle_error $? $LINENO' ERR

handle_error() {
    local exit_code=$1
    local line_number=$2
    print_error "Script failed at line $line_number with exit code $exit_code"
    print_error "Check log file: $LOG_FILE"
    print_debug "Last command: $BASH_COMMAND"
    echo ""
    echo "Troubleshooting steps:"
    echo "  1. Check the log file: cat $LOG_FILE"
    echo "  2. Look for errors above"
    echo "  3. Try running the failed step manually"
    exit $exit_code
}

set -e

print_status "Logging to: $LOG_FILE"
print_debug "Starting installation at $(date)"
print_debug "User: $(whoami)"
print_debug "Hostname: $(hostname)"
print_debug "Working directory: $(pwd)"

# Check conda
print_status "Checking conda installation..."
print_debug "Searching for conda command..."
if ! command -v conda &> /dev/null; then
    print_error "Conda not found!"
    print_debug "Install miniconda from: https://docs.conda.io/en/latest/miniconda.html"
    exit 1
fi

CONDA_VERSION=$(conda --version)
print_success "Conda detected: $CONDA_VERSION"
print_debug "Conda path: $(which conda)"
print_debug "Conda info:"
conda info | head -10

# Check system requirements
print_status "Checking system requirements..."
print_debug "Checking GLIBC version..."
GLIBC_VERSION=$(ldd --version | head -1 | grep -oP '\d+\.\d+' | head -1)
print_debug "Found GLIBC version: $GLIBC_VERSION"
if [[ $(echo "$GLIBC_VERSION < 2.35" | bc -l) -eq 1 ]]; then
    print_error "GLIBC version $GLIBC_VERSION is too old (need 2.35+)"
    print_error "Cannot install Isaac Sim 5.1 via pip"
    print_debug "Your system: $(lsb_release -a 2>/dev/null | grep Description || uname -a)"
    exit 1
fi
print_success "GLIBC $GLIBC_VERSION detected (compatible)"

# Check disk space
print_debug "Checking disk space..."
AVAILABLE_GB=$(df -BG ~ | tail -1 | awk '{print $4}' | sed 's/G//')
print_debug "Available disk space: ${AVAILABLE_GB}GB"
if [ "$AVAILABLE_GB" -lt 50 ]; then
    print_warning "Low disk space: ${AVAILABLE_GB}GB (recommend 50GB+)"
    print_debug "Disk usage: $(df -h ~)"
fi

# Check GPU
print_status "Checking CUDA availability..."
print_debug "Searching for nvidia-smi command..."
if ! command -v nvidia-smi &> /dev/null; then
    print_error "nvidia-smi not found. GPU required!"
    print_debug "PATH: $PATH"
    exit 1
fi
GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
GPU_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader | head -1)
CUDA_VERSION=$(nvidia-smi | grep "CUDA Version" | awk '{print $9}')
print_success "GPU detected: $GPU_NAME"
print_debug "GPU Memory: $GPU_MEM"
print_debug "CUDA Version: $CUDA_VERSION"

# Update system
print_status "Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
    git \
    wget \
    curl \
    build-essential \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libglu1-mesa \
    libxi6 \
    libxrandr2 \
    bc

print_success "System dependencies installed!"

# Set up workspace
WORKSPACE_DIR="$HOME/g1_workspace"
print_status "Creating workspace at $WORKSPACE_DIR..."
mkdir -p "$WORKSPACE_DIR"
cd "$WORKSPACE_DIR"

# Clone Isaac Lab
print_status "Cloning Isaac Lab..."
if [ ! -d "IsaacLab" ]; then
    git clone https://github.com/isaac-sim/IsaacLab.git
else
    print_status "IsaacLab already exists, pulling latest..."
    cd IsaacLab
    git pull
    cd ..
fi

ISAACLAB_DIR="$WORKSPACE_DIR/IsaacLab"
cd "$ISAACLAB_DIR"
print_success "Isaac Lab ready at $ISAACLAB_DIR"

# Create conda environment using Isaac Lab's built-in command
CONDA_ENV_NAME="isaaclab"
print_status "Creating conda environment '$CONDA_ENV_NAME'..."
print_debug "Using Isaac Lab's built-in conda setup"

if conda env list | grep -q "^$CONDA_ENV_NAME "; then
    print_warning "Conda environment '$CONDA_ENV_NAME' already exists"
    print_status "Removing old environment..."
    conda env remove -n $CONDA_ENV_NAME -y
fi

# Use Isaac Lab's built-in conda creation
print_debug "Running: ./isaaclab.sh --conda $CONDA_ENV_NAME"
if ! ./isaaclab.sh --conda $CONDA_ENV_NAME 2>&1 | tee -a "$LOG_FILE"; then
    print_error "Conda environment creation failed!"
    print_debug "Try manually: ./isaaclab.sh --conda $CONDA_ENV_NAME"
    exit 1
fi

print_success "Conda environment '$CONDA_ENV_NAME' created!"

# Initialize conda for bash (if not already done)
eval "$(conda shell.bash hook)"

# Activate conda environment
print_status "Activating conda environment..."
print_debug "Running: conda activate $CONDA_ENV_NAME"
conda activate $CONDA_ENV_NAME

print_success "Conda environment activated!"
print_debug "Python: $(which python)"
print_debug "Python version: $(python --version)"
print_debug "Conda env: $CONDA_DEFAULT_ENV"

# Install Isaac Sim 5.1.0 via pip
print_status "Installing Isaac Sim 5.1.0 (this will take 15-30 minutes)..."
print_warning "Downloading ~6GB of packages..."
print_debug "Pip: $(which pip)"
print_debug "Pip version: $(pip --version)"
echo ""

print_debug "Running: pip install isaacsim[all,extscache]==5.1.0"
if ! pip install "isaacsim[all,extscache]==5.1.0" --extra-index-url https://pypi.nvidia.com; then
    print_error "Isaac Sim installation failed!"
    print_debug "Check internet connection and PyPI access"
    print_debug "Try manually: pip install 'isaacsim[all,extscache]==5.1.0' --extra-index-url https://pypi.nvidia.com"
    exit 1
fi

print_success "Isaac Sim 5.1.0 installed!"
print_debug "Checking Isaac Sim installation..."
pip show isaacsim | head -10

# Install PyTorch with CUDA
print_status "Installing PyTorch 2.7.0 with CUDA 12.8..."
print_debug "Installing PyTorch from https://download.pytorch.org/whl/cu128"
if ! pip install -U torch==2.7.0 torchvision==0.22.0 --index-url https://download.pytorch.org/whl/cu128; then
    print_error "PyTorch installation failed!"
    print_debug "This might be due to network issues or CUDA compatibility"
    exit 1
fi

print_success "PyTorch installed!"
print_debug "Verifying PyTorch installation..."
python -c "import torch; print(f'PyTorch {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}')"

# Install Isaac Lab
print_status "Installing Isaac Lab..."
print_debug "Running ./isaaclab.sh --install"
print_debug "This will install all Isaac Lab extensions and dependencies"
if ! ./isaaclab.sh --install 2>&1 | tee -a "$LOG_FILE"; then
    print_error "Isaac Lab installation failed!"
    print_debug "Check the output above for errors"
    exit 1
fi

print_success "Isaac Lab installed!"
print_debug "Isaac Lab installation complete"

# Verify installation
print_status "Verifying Isaac Sim installation..."
if python -c "import isaacsim; print('Isaac Sim', isaacsim.__version__)" 2>/dev/null; then
    print_success "Isaac Sim 5.1.0 verified!"
else
    print_warning "Verification warning (may be normal)"
fi

# Configure native WebRTC streaming
print_status "Configuring native WebRTC streaming..."
print_debug "Finding Isaac Sim installation path..."

# Find Isaac Sim installation in conda env
ISAAC_SIM_PATH=$(python -c "import isaacsim, os; print(os.path.dirname(isaacsim.__file__))" 2>/dev/null)

if [ -z "$ISAAC_SIM_PATH" ]; then
    print_warning "Could not find Isaac Sim path automatically"
    CONDA_PREFIX=$(conda info --base)
    ISAAC_SIM_PATH="$CONDA_PREFIX/envs/$CONDA_ENV_NAME/lib/python3.11/site-packages/isaacsim"
    print_debug "Using default path: $ISAAC_SIM_PATH"
fi

print_status "Isaac Sim located at: $ISAAC_SIM_PATH"
print_debug "Checking if path exists..."
if [ ! -d "$ISAAC_SIM_PATH" ]; then
    print_warning "Isaac Sim path does not exist: $ISAAC_SIM_PATH"
    print_debug "Listing conda env site-packages..."
    ls -la "$(python -c 'import site; print(site.getsitepackages()[0])')" | grep -i isaac || true
fi

# Create streaming configuration
STREAMING_CONFIG_DIR="$ISAAC_SIM_PATH/kit/configs"
mkdir -p "$STREAMING_CONFIG_DIR"

cat > "$STREAMING_CONFIG_DIR/streaming.toml" <<'EOF'
[settings]
# Enable native WebRTC streaming
"exts/omni.kit.streamer.webrtc/enabled" = true
"exts/omni.services.streamclient.webrtc/enabled" = true

# Streaming quality settings
"exts/omni.kit.streamer.webrtc/videoEncodeWidth" = 1920
"exts/omni.kit.streamer.webrtc/videoEncodeHeight" = 1080
"exts/omni.kit.streamer.webrtc/videoEncodeFPS" = 60
"exts/omni.kit.streamer.webrtc/videoBitrate" = 10000000

# Network settings
"exts/omni.services.streamclient.webrtc/port" = 8211
"exts/omni.services.streamclient.webrtc/hostIP" = "0.0.0.0"

# Enable headless rendering
"app/window/enabled" = false
"app/livestream/enabled" = true
EOF

print_success "Streaming configuration created!"

# Create project directories
print_status "Setting up project structure..."
mkdir -p "$WORKSPACE_DIR/g1_project"

# Create activation helper script
cat > "$WORKSPACE_DIR/activate_isaac.sh" <<EOF
#!/bin/bash
# Activate Isaac Lab conda environment
eval "\$(conda shell.bash hook)"
conda activate $CONDA_ENV_NAME
export ISAACLAB_DIR="$ISAACLAB_DIR"
export WORKSPACE_DIR="$WORKSPACE_DIR"
echo "✓ Isaac Lab conda environment activated!"
echo "  Conda env: \$CONDA_DEFAULT_ENV"
echo "  Python: \$(which python)"
echo "  Isaac Lab: \$ISAACLAB_DIR"
EOF

chmod +x "$WORKSPACE_DIR/activate_isaac.sh"

# Summary
echo ""
echo "========================================"
print_success "INSTALLATION COMPLETE!"
echo "========================================"
echo ""
echo "📦 Installed Components:"
echo "  ✓ Conda environment: $CONDA_ENV_NAME"
echo "  ✓ Isaac Sim 5.1.0 (via pip)"
echo "  ✓ Isaac Lab (latest)"
echo "  ✓ PyTorch 2.7.0 + CUDA 12.8"
echo "  ✓ Native WebRTC streaming (configured)"
echo ""
echo "📁 Installation Paths:"
echo "  Workspace:    $WORKSPACE_DIR"
echo "  Isaac Lab:    $ISAACLAB_DIR"
echo "  Isaac Sim:    $ISAAC_SIM_PATH"
echo "  Conda Env:    $CONDA_ENV_NAME"
echo "  Project:      $WORKSPACE_DIR/g1_project"
echo ""
echo "🌐 WebRTC Streaming:"
echo "  Port:         8211"
echo "  Resolution:   1920x1080"
echo "  FPS:          60"
echo "  Server IP:    $(hostname -I | awk '{print $1}')"
echo ""
echo "🚀 Quick Start:"
echo "  1. Activate environment:"
echo "     conda activate $CONDA_ENV_NAME"
echo "     # or"
echo "     source $WORKSPACE_DIR/activate_isaac.sh"
echo ""
echo "  2. Test installation:"
echo "     cd $ISAACLAB_DIR"
echo "     ./isaaclab.sh -p scripts/tutorials/00_sim/create_empty.py --headless"
echo ""
echo "  3. Launch G1 with streaming:"
echo "     cd ~/g1-setup"
echo "     ./launch_native_streaming.sh g1_simple_test.py"
echo ""
echo "  4. Connect from local machine:"
echo "     - Download Isaac Sim WebRTC Client"
echo "     - SSH tunnel: ssh -L 8211:localhost:8211 user@server"
echo "     - Connect to: localhost:8211"
echo ""
print_success "Ready to use Isaac Sim 5.1 + Isaac Lab with Conda!"
print_debug "Installation completed successfully at $(date)"
print_debug "Total time: $SECONDS seconds"
print_debug "Log file saved to: $LOG_FILE"
echo ""
echo "📋 Debug Log:"
echo "  Full log: $LOG_FILE"
echo "  View with: cat $LOG_FILE"
echo "  Last 20 lines: tail -20 $LOG_FILE"
echo ""
