# Fully Automated Isaac Sim 5.1 + Isaac Lab Setup

## 🎯 One Command Installation

This script installs **everything automatically**:
- ✅ Isaac Sim 5.1.0 (via pip)
- ✅ Isaac Lab (latest)
- ✅ PyTorch 2.7.0 + CUDA 12.8
- ✅ Python 3.11 virtual environment
- ✅ Native WebRTC streaming configured
- ✅ Full debug logging

---

## 🚀 Quick Start

### On Your Brev Server:

```bash
cd ~/g1-setup

# Run the automated setup
./setup_complete_automated.sh
```

**That's it!** Everything will be installed automatically.

⏱️ **Time:** 20-40 minutes (mostly downloading)

---

## 📋 What It Does

### 1. System Checks
- ✅ Verifies GLIBC 2.35+ (required for Isaac Sim 5.1)
- ✅ Detects GPU (RTX 6000, L40S, etc.)
- ✅ Checks disk space (warns if < 50GB)
- ✅ Validates CUDA installation

### 2. System Dependencies
- ✅ Installs build tools
- ✅ Installs Python 3.11
- ✅ Installs system libraries

### 3. Isaac Lab Setup
- ✅ Clones Isaac Lab repository
- ✅ Creates Python 3.11 virtual environment
- ✅ Upgrades pip, setuptools, wheel

### 4. Isaac Sim 5.1 Installation
- ✅ Installs via pip (~6GB download)
- ✅ Includes all extensions and extras
- ✅ Verifies installation

### 5. PyTorch Installation
- ✅ Installs PyTorch 2.7.0
- ✅ Includes CUDA 12.8 support
- ✅ Verifies CUDA availability

### 6. Isaac Lab Installation
- ✅ Runs ./isaaclab.sh --install
- ✅ Installs all extensions
- ✅ Verifies installation

### 7. WebRTC Configuration
- ✅ Locates Isaac Sim installation
- ✅ Creates streaming.toml config
- ✅ Enables native WebRTC (port 8211)
- ✅ Configures 1080p60 streaming

### 8. Project Setup
- ✅ Creates g1_project directory
- ✅ Creates activation helper script
- ✅ Shows quick start instructions

---

## 📊 Debug Logging

The script logs **everything** to:
```
~/isaac_setup_YYYYMMDD_HHMMSS.log
```

### Log Features:
- ✅ Timestamps for every step
- ✅ Debug information
- ✅ Error messages with context
- ✅ System information
- ✅ Installation verification

### If Something Fails:

```bash
# View the log
cat ~/isaac_setup_*.log

# Check last 50 lines
tail -50 ~/isaac_setup_*.log

# Search for errors
grep -i error ~/isaac_setup_*.log
```

The script will tell you:
- ❌ What failed
- 📍 Line number in script
- 💡 Troubleshooting steps
- 📝 Log file location

---

## 🔍 Error Handling

### Automatic Failure Detection:
```bash
# Script stops on any error (set -e)
# Catches errors with trap
# Shows line number where it failed
# Provides troubleshooting steps
```

### Common Failure Points:

**1. GLIBC Version Too Old**
```
[ERROR] GLIBC version 2.31 is too old (need 2.35+)
```
**Solution:** Upgrade to Ubuntu 22.04+ or use binary installation

**2. Isaac Sim pip Install Fails**
```
[ERROR] Isaac Sim installation failed!
```
**Debug:** Check log for network errors or PyPI issues
**Manual:** `pip install 'isaacsim[all,extscache]==5.1.0' --extra-index-url https://pypi.nvidia.com`

**3. PyTorch Install Fails**
```
[ERROR] PyTorch installation failed!
```
**Debug:** Check CUDA version compatibility
**Manual:** `pip install torch==2.7.0 --index-url https://download.pytorch.org/whl/cu128`

**4. Isaac Lab Install Fails**
```
[ERROR] Isaac Lab installation failed!
```
**Debug:** Check the Isaac Lab output in log
**Manual:** `cd ~/g1_workspace/IsaacLab && ./isaaclab.sh --install`

---

## 📦 After Installation

### Activate Environment:
```bash
source ~/g1_workspace/activate.sh
```

### Test Installation:
```bash
cd ~/g1_workspace/IsaacLab
./isaaclab.sh -p scripts/tutorials/00_sim/create_empty.py --headless
```

### Launch G1 Simulation:
```bash
cd ~/g1-setup
./launch_native_streaming.sh g1_simple_test.py
```

---

## 🌐 WebRTC Streaming

### On Local Machine:

1. **Download Isaac Sim WebRTC Client:**
   - Windows: https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-windows.zip
   - Mac: https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-mac.zip
   - Linux: https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-linux.AppImage

2. **Create SSH Tunnel:**
   ```bash
   ssh -L 8211:localhost:8211 user@your-brev-server.brev.dev
   ```

3. **Connect Client:**
   - Open Isaac Sim WebRTC Client
   - Connect to: `localhost:8211`
   - See your simulation!

---

## 💾 Disk Space Requirements

| Component | Size | When |
|-----------|------|------|
| System packages | ~500MB | During install |
| Isaac Sim 5.1 | ~6GB | pip download |
| PyTorch + CUDA | ~3GB | pip download |
| Isaac Lab | ~500MB | git clone |
| Virtual env | ~1GB | Python packages |
| **Total** | **~11GB** | After complete |

**Recommended:** 50GB+ free space

---

## ⏱️ Installation Time

| Step | Time | Network |
|------|------|---------|
| System deps | 2-5 min | Fast |
| Isaac Sim download | 10-20 min | ~6GB |
| Isaac Sim install | 3-5 min | - |
| PyTorch download | 3-5 min | ~3GB |
| Isaac Lab install | 2-5 min | - |
| Configuration | 1 min | - |
| **Total** | **20-40 min** | ~10GB |

---

## 🐛 Debugging Tips

### 1. Check System Requirements
```bash
# GLIBC
ldd --version

# GPU
nvidia-smi

# Disk space
df -h ~

# Python
python3.11 --version
```

### 2. Manual Step-by-Step
If automated script fails, try manually:

```bash
# 1. Create venv
cd ~/g1_workspace/IsaacLab
python3.11 -m venv .venv --upgrade-deps
source .venv/bin/activate

# 2. Install Isaac Sim
pip install "isaacsim[all,extscache]==5.1.0" --extra-index-url https://pypi.nvidia.com

# 3. Install PyTorch
pip install torch==2.7.0 --index-url https://download.pytorch.org/whl/cu128

# 4. Install Isaac Lab
./isaaclab.sh --install
```

### 3. Check Logs
```bash
# Find log file
ls -lt ~/isaac_setup_*.log | head -1

# View full log
cat ~/isaac_setup_*.log

# Search for specific issues
grep -i "error\|fail\|warning" ~/isaac_setup_*.log
```

### 4. Verify Installation
```bash
source ~/g1_workspace/IsaacLab/.venv/bin/activate

# Check Python
python --version

# Check Isaac Sim
python -c "import isaacsim; print(isaacsim.__version__)"

# Check PyTorch
python -c "import torch; print(torch.__version__); print(torch.cuda.is_available())"

# Check Isaac Lab
cd ~/g1_workspace/IsaacLab
./isaaclab.sh -p -c "print('OK')"
```

---

## 📝 Log File Format

```
[2025-11-06 14:30:15] [INFO] Starting installation
[2025-11-06 14:30:16] [DEBUG] User: bhavesh
[2025-11-06 14:30:16] [DEBUG] GPU: NVIDIA L40S
[2025-11-06 14:30:20] [SUCCESS] GLIBC 2.35 detected
...
[2025-11-06 14:55:42] [SUCCESS] Installation complete!
[2025-11-06 14:55:42] [DEBUG] Total time: 1527 seconds
```

---

## 🎯 Success Indicators

After successful installation, you should see:

```
✅ Isaac Sim 5.1.0 verified!
✅ PyTorch installed!
✅ Isaac Lab installed!
✅ Streaming configuration created!
✅ Ready to use Isaac Sim 5.1 + Isaac Lab!
```

And these files should exist:
```bash
~/g1_workspace/IsaacLab/.venv/bin/python
~/g1_workspace/IsaacLab/.venv/lib/python3.11/site-packages/isaacsim/
~/g1_workspace/activate.sh
~/g1_workspace/g1_project/
```

---

## 🔄 Re-running Setup

If you need to re-run:

```bash
# Clean install
rm -rf ~/g1_workspace
./setup_complete_automated.sh

# Or update existing
cd ~/g1_workspace/IsaacLab
git pull
source .venv/bin/activate
./isaaclab.sh --install
```

---

## 💡 Pro Tips

1. **Use screen/tmux:** Setup takes 20-40 min, detach safely
   ```bash
   screen -S isaac
   ./setup_complete_automated.sh
   # Detach: Ctrl+A, D
   ```

2. **Monitor progress:** Check log in another terminal
   ```bash
   tail -f ~/isaac_setup_*.log
   ```

3. **Save bandwidth:** If re-running, pip will cache packages

4. **Check before starting:**
   ```bash
   ./check_system.sh  # Verify requirements first
   ```

---

## 📞 Support

**If automated setup fails:**

1. Check the log file
2. Look for ERROR or FAIL messages
3. Note the line number where it failed
4. Check disk space and network
5. Try manual step-by-step installation

**For Isaac Sim issues:**
- https://docs.isaacsim.omniverse.nvidia.com/
- https://forums.developer.nvidia.com/c/isaac/67

**For Isaac Lab issues:**
- https://isaac-sim.github.io/IsaacLab/
- https://github.com/isaac-sim/IsaacLab/issues

---

## ✅ Quick Reference

```bash
# Run automated setup
./setup_complete_automated.sh

# Activate environment
source ~/g1_workspace/activate.sh

# Test installation
cd ~/g1_workspace/IsaacLab
./isaaclab.sh -p scripts/tutorials/00_sim/create_empty.py --headless

# View logs
cat ~/isaac_setup_*.log

# Launch G1
./launch_native_streaming.sh g1_simple_test.py
```

---

**Ready to install? Run:**
```bash
./setup_complete_automated.sh
```

🎉 Everything will be set up automatically!
