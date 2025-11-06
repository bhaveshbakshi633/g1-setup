#!/bin/bash

# System Check Script - Run before setup
# Verifies your system meets requirements

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
WARN=0
FAIL=0

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}System Requirements Check${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Function to check and report
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASS++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAIL++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARN++))
}

# 1. Check OS
echo "Checking Operating System..."
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]]; then
        check_pass "Ubuntu detected: $VERSION"
    else
        check_warn "Not Ubuntu ($ID), may work but untested"
    fi
else
    check_warn "Cannot detect OS version"
fi
echo ""

# 2. Check GPU
echo "Checking GPU..."
if command -v nvidia-smi &> /dev/null; then
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
    GPU_MEMORY=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader | head -1)
    CUDA_VERSION=$(nvidia-smi | grep "CUDA Version" | awk '{print $9}')

    check_pass "NVIDIA GPU detected: $GPU_NAME"
    check_pass "GPU Memory: $GPU_MEMORY"
    check_pass "CUDA Version: $CUDA_VERSION"

    # Extract memory in GB
    MEMORY_GB=$(echo $GPU_MEMORY | awk '{print $1}')
    if (( $(echo "$MEMORY_GB < 8000" | bc -l) )); then
        check_warn "GPU memory < 8GB, may struggle with high-res rendering"
    fi
else
    check_fail "nvidia-smi not found - No GPU detected!"
fi
echo ""

# 3. Check disk space
echo "Checking Disk Space..."
AVAILABLE_GB=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [[ $AVAILABLE_GB -ge 50 ]]; then
    check_pass "Disk space: ${AVAILABLE_GB}GB available (need 50GB)"
elif [[ $AVAILABLE_GB -ge 30 ]]; then
    check_warn "Disk space: ${AVAILABLE_GB}GB available (tight, recommend 50GB)"
else
    check_fail "Disk space: ${AVAILABLE_GB}GB available (need at least 50GB)"
fi
echo ""

# 4. Check RAM
echo "Checking RAM..."
TOTAL_RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
if [[ $TOTAL_RAM_GB -ge 16 ]]; then
    check_pass "RAM: ${TOTAL_RAM_GB}GB (recommended 16GB+)"
elif [[ $TOTAL_RAM_GB -ge 8 ]]; then
    check_warn "RAM: ${TOTAL_RAM_GB}GB (works, but 16GB recommended)"
else
    check_warn "RAM: ${TOTAL_RAM_GB}GB (may be insufficient)"
fi
echo ""

# 5. Check internet
echo "Checking Internet Connection..."
if ping -c 1 google.com &> /dev/null; then
    check_pass "Internet connection working"
else
    check_fail "No internet connection"
fi

if ping -c 1 github.com &> /dev/null; then
    check_pass "Can reach GitHub"
else
    check_fail "Cannot reach GitHub (needed for Isaac Lab)"
fi
echo ""

# 6. Check Python
echo "Checking Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    check_pass "Python3 installed: $PYTHON_VERSION"
else
    check_warn "Python3 not found (will be installed by setup script)"
fi
echo ""

# 7. Check Git
echo "Checking Git..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    check_pass "Git installed: $GIT_VERSION"
else
    check_warn "Git not found (will be installed by setup script)"
fi
echo ""

# 8. Check Node.js
echo "Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    check_pass "Node.js installed: $NODE_VERSION"
else
    check_warn "Node.js not found (will be installed by setup script)"
fi
echo ""

# 9. Check sudo access
echo "Checking Permissions..."
if sudo -n true 2>/dev/null; then
    check_pass "Passwordless sudo available"
elif sudo -v 2>/dev/null; then
    check_pass "Sudo access available (may prompt for password)"
else
    check_fail "No sudo access (required for setup)"
fi
echo ""

# Summary
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""
echo -e "${GREEN}Passed:${NC} $PASS checks"
if [[ $WARN -gt 0 ]]; then
    echo -e "${YELLOW}Warnings:${NC} $WARN (may work, but not ideal)"
fi
if [[ $FAIL -gt 0 ]]; then
    echo -e "${RED}Failed:${NC} $FAIL (need to fix)"
fi
echo ""

# Recommendation
if [[ $FAIL -gt 0 ]]; then
    echo -e "${RED}❌ System NOT ready${NC}"
    echo "Please fix the failed checks before running setup."
    echo ""
    if ! command -v nvidia-smi &> /dev/null; then
        echo "CRITICAL: No GPU detected. Make sure you're on a GPU instance."
    fi
    exit 1
elif [[ $WARN -gt 0 ]]; then
    echo -e "${YELLOW}⚠ System mostly ready${NC}"
    echo "You can proceed, but check the warnings above."
    echo ""
    echo "To continue with setup:"
    echo "  ./setup_g1_cloud.sh"
    exit 0
else
    echo -e "${GREEN}✓ System ready!${NC}"
    echo ""
    echo "Everything looks good. You can proceed with setup:"
    echo "  ./setup_g1_cloud.sh"
    exit 0
fi
