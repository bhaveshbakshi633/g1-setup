# Unitree G1 Isaac Lab - Native Streaming Setup

Complete setup for running Unitree G1 humanoid robot in Isaac Lab on cloud GPU (Brev.dev) with official NVIDIA WebRTC streaming.

---

## 🚀 Quick Start

### ⭐ RECOMMENDED: Conda Setup

```bash
# 1. Read the guide
cat START_HERE.md
cat NATIVE_STREAMING_GUIDE.md

# 2. Check your system
./check_system.sh

# 3. Run automated conda setup (20-30 min, one time)
./setup_conda_automated.sh

# 4. Activate environment
conda activate isaaclab

# 5. Launch simulation
./launch_native_streaming.sh g1_simple_test.py
```

### Alternative: Venv Setup

```bash
./setup_complete_automated.sh  # Uses Python venv instead
```

**Why Conda?** Official Isaac Lab support, better dependencies, you already have it!
See [CONDA_VS_VENV.md](CONDA_VS_VENV.md) for comparison.

---

## 📁 Directory Structure

```
.
├── START_HERE.md                    ⭐ Read this first
├── NATIVE_STREAMING_GUIDE.md        ⭐ Complete streaming guide
├── setup_isaac_native_streaming.sh  ⭐ Main setup script
├── launch_native_streaming.sh       ⭐ Launch with streaming
├── check_system.sh                  🔍 Verify GPU and system
├── g1_simple_test.py                🤖 Test G1 robot
│
├── docs/                            📚 Documentation
│   ├── BREV_SETUP.md               - Brev.dev specific guide
│   ├── GPU_COMPATIBILITY.md        - GPU options and costs
│   ├── STREAMING_COMPARISON.md     - Native vs Custom comparison
│   ├── CURRENT_STATUS.md           - Setup progress tracking
│   └── ... (more docs)
│
├── scripts/                         🛠️ Utility scripts
│   ├── simple_g1_teleop.py         - Simple teleop example
│   ├── upload_to_brev.sh           - Upload files to Brev
│   └── config.env                  - Configuration options
│
└── legacy/                          📦 Old custom WebRTC (not needed)
    ├── setup_g1_cloud.sh           - Old setup (browser-based)
    ├── launch_g1.sh                - Old launcher
    └── ... (custom WebRTC files)
```

---

## ⭐ Recommended Approach: Native Streaming

**Use Isaac Sim's official WebRTC streaming:**

- ✅ 10-30ms latency (GPU-accelerated)
- ✅ Better quality (1080p60 or 4K30)
- ✅ Official NVIDIA support
- ✅ Mouse + keyboard controls

**Guide:** [NATIVE_STREAMING_GUIDE.md](NATIVE_STREAMING_GUIDE.md)

---

## 📦 Alternative: Custom Browser Streaming

**Use custom Node.js WebRTC server (legacy):**

- ✅ No client download needed (browser only)
- ⚠️ Higher latency (30-100ms)
- ⚠️ CPU encoding (slower)

**Files:** `legacy/` folder
**Guide:** [docs/BREV_SETUP.md](docs/BREV_SETUP.md)

---

## 🎯 What You Need

### On Remote Server (Brev.dev):
- GPU with CUDA (RTX 3060+, L40S, etc.)
- Ubuntu 20.04 or 22.04
- 50GB+ disk space
- Run: `./setup_isaac_native_streaming.sh`

### On Your Local Machine:
- Isaac Sim WebRTC Streaming Client (~100MB)
- Download: [Links in NATIVE_STREAMING_GUIDE.md](NATIVE_STREAMING_GUIDE.md#download-isaac-sim-webrtc-streaming-client)

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| **START_HERE.md** | Main entry point - read first |
| **NATIVE_STREAMING_GUIDE.md** | Complete guide for native streaming |
| **docs/STREAMING_COMPARISON.md** | Compare native vs custom |
| **docs/BREV_SETUP.md** | Brev.dev CLI specific setup |
| **docs/GPU_COMPATIBILITY.md** | GPU options and pricing |
| **docs/CURRENT_STATUS.md** | Track setup progress |

---

## 🔧 Setup Process

### Step 1: Upload to Brev
```bash
# Option A: Using upload script
./scripts/upload_to_brev.sh

# Option B: Using git
git clone https://github.com/YOUR_USERNAME/g1-setup.git
```

### Step 2: On Brev Server
```bash
cd ~/g1-setup
./check_system.sh              # Verify system
./setup_isaac_native_streaming.sh  # Setup (30-60 min)
```

### Step 3: On Local Machine
- Download Isaac Sim WebRTC Client
- Create SSH tunnel: `ssh -L 8211:localhost:8211 user@brev`
- Connect client to: `localhost:8211`

### Step 4: Launch
```bash
# On Brev
./launch_native_streaming.sh g1_simple_test.py
```

---

## 💰 Cost Optimization

**For Testing:**
- Use RTX 3060 (12GB) - $0.20-0.30/hr
- Setup once, save snapshot
- **Save 75%** vs L40S

**For Production:**
- Use L40S or RTX 4090
- Load from snapshot
- Multi-robot training

See [docs/GPU_COMPATIBILITY.md](docs/GPU_COMPATIBILITY.md) for details.

---

## 🆘 Troubleshooting

**GPU not detected:**
```bash
nvidia-smi
```

**Setup failed:**
```bash
cat docs/CURRENT_STATUS.md  # Check progress
```

**Cannot connect:**
```bash
# Check SSH tunnel
ps aux | grep "ssh.*8211"

# Check port on server
sudo netstat -tlnp | grep 8211
```

---

## 🎓 Learning Path

1. ✅ **Read** START_HERE.md
2. ✅ **Check** system with check_system.sh
3. ✅ **Setup** with setup_isaac_native_streaming.sh
4. ✅ **Download** Isaac Sim WebRTC Client
5. ✅ **Launch** with launch_native_streaming.sh
6. ✅ **Develop** your G1 simulation!

---

## 🔗 Links

- **Isaac Lab:** https://isaac-sim.github.io/IsaacLab/
- **Unitree G1:** https://www.unitree.com/g1/
- **Isaac Sim Streaming:** https://docs.omniverse.nvidia.com/isaacsim/latest/advanced_tutorials/tutorial_advanced_streaming.html

---

## 📝 License

Educational and research use. Isaac Lab and Unitree assets have their own licenses.

---

## 🚀 Ready?

```bash
cat START_HERE.md
./check_system.sh
```

**That's it! Start your G1 journey!** 🤖
