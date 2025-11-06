# 🚀 START HERE - Unitree G1 Isaac Lab Setup

Welcome! This guide will get you running Unitree G1 with pretrained WBC in Isaac Lab with WebRTC visualization.

---

## 🌐 Using Brev.dev CLI? ⭐ NEW: Native Streaming!

**⭐ RECOMMENDED: Isaac Sim Native WebRTC Streaming**
→ Read **[NATIVE_STREAMING_GUIDE.md](NATIVE_STREAMING_GUIDE.md)** - Use GPU on cloud, view on your PC!
- Lower latency (10-30ms)
- GPU-accelerated encoding
- Official NVIDIA client

**Alternative: Custom Browser-Based Streaming**
→ Read [BREV_SETUP.md](BREV_SETUP.md) or [BREV_CHEATSHEET.txt](BREV_CHEATSHEET.txt)

Everything works perfectly with CLI-only access via Brev. No GUI needed!

---

## 📊 Your Current Setup

**GPU:** L40S (48GB) ✅ Excellent!
**Cost:** ~$0.90-1.40/hour
**Capability:** Can run 16-32 parallel robots

> **Note:** Your GPU is actually more powerful than needed for basic testing. See [GPU_COMPATIBILITY.md](GPU_COMPATIBILITY.md) for cheaper alternatives.

---

## ⚡ Quick Start (30 seconds)

```bash
# 1. Setup (first time only - takes 30-60 minutes)
./setup_g1_cloud.sh

# 2. Launch simulation
./launch_g1.sh webrtc

# 3. Open browser
# http://localhost:8080 (if using SSH tunnel)
# http://<your-server-ip>:8080 (if port is open)
```

That's it! 🎉

---

## 📁 What You Have

All the files you need are in `/home/bhavesh/rented/`:

### Essential Files
- ✅ `setup_g1_cloud.sh` - One-time setup
- ✅ `launch_g1.sh` - Launch script
- ✅ `g1_sim_webrtc.py` - Main simulation
- ✅ `webrtc_server.js` - Streaming server
- ✅ `viewer.html` - Web interface

### Documentation
- 📖 `README.md` - Complete documentation
- 🚀 `QUICKSTART.md` - Step-by-step guide
- 💻 `GPU_COMPATIBILITY.md` - GPU options & costs
- 📋 `FILES_OVERVIEW.md` - Technical reference
- 👉 `START_HERE.md` - This file

### Supporting Files
- `simple_g1_teleop.py` - Simple version (no WebRTC)
- `webrtc_streamer.py` - Streaming client
- `package.json` - Node.js dependencies
- `config.env` - Configuration options

---

## 🎯 Your Goal

> "Test if I can load a G1 with pretrained WBC from HuggingFace and teleop it, visualized via WebRTC"

### What This Setup Does

✅ Loads Unitree G1 humanoid robot in Isaac Lab
✅ Supports pretrained WBC models from HuggingFace
✅ Enables keyboard teleoperation
✅ Streams video via WebRTC for remote viewing
✅ Works on any cloud GPU (including your L40S)

---

## 📝 Step-by-Step Instructions

### Step 1: Initial Setup (30-60 minutes)

```bash
# Run the setup script
./setup_g1_cloud.sh
```

**What happens:**
- Checks GPU (your L40S will be detected)
- Installs system packages
- Clones and builds Isaac Lab
- Downloads Unitree G1 assets
- Sets up WebRTC server
- Installs Python packages

**Go get coffee!** ☕ This takes 30-60 minutes.

### Step 2: Launch Simulation (2 minutes)

```bash
# Start everything
./launch_g1.sh webrtc
```

**What happens:**
- Starts WebRTC server on port 8080
- Launches Isaac Lab in headless mode
- Loads G1 robot
- Begins streaming

**Look for this output:**
```
WebRTC viewer available at:
  Local:  http://localhost:8080
  Remote: http://YOUR_IP:8080
```

### Step 3: Access Web Viewer

**Option A: SSH Tunnel (Recommended)**

From your **local machine**:
```bash
ssh -L 8080:localhost:8080 user@your-cloud-ip
```

Then open: `http://localhost:8080`

**Option B: Direct Access**

On cloud instance:
```bash
sudo ufw allow 8080
```

Then open: `http://YOUR_CLOUD_IP:8080`

### Step 4: Control the Robot

In the web viewer:

**Keyboard:**
- W/A/S/D - Move
- Q/E - Turn
- Arrow keys - Body orientation
- R - Reset
- P - Pause

**Buttons:**
- Reset Simulation
- Pause/Resume
- Stand Up

---

## 🎓 Learning Path

### Beginner (First 30 minutes)
1. ✅ Run setup script
2. ✅ Launch in simple mode: `./launch_g1.sh simple`
3. ✅ Verify robot loads
4. ✅ Try WebRTC mode: `./launch_g1.sh webrtc`
5. ✅ Control robot with keyboard

### Intermediate (Next 2 hours)
1. Load pretrained model from HuggingFace
   ```bash
   HF_REPO='unitreerobotics/g1-wbc' ./launch_g1.sh webrtc
   ```
2. Modify camera position in `g1_sim_webrtc.py`
3. Change robot initial pose
4. Customize teleop controls

### Advanced (Ongoing)
1. Implement custom gait patterns
2. Train RL policy with Isaac Lab
3. Run multiple robots: `num_envs=16`
4. Add sensors (IMU, cameras, force sensors)
5. Record and analyze data

---

## 💰 Cost Optimization

Your L40S is powerful but expensive. Consider:

### For Testing (What you're doing now)
**Switch to:** RTX 3060 or T4
**Cost:** $0.20-0.30/hr (vs $1.20/hr on L40S)
**Savings:** ~$1/hr (**Save 75%**)

See [GPU_COMPATIBILITY.md](GPU_COMPATIBILITY.md) for details.

### For Production (Training, multiple robots)
**Use:** L40S (what you have)
**Cost:** $0.90-1.40/hr
**Best for:** 16+ parallel robots, RL training

---

## 🔧 Troubleshooting

### Setup fails
```bash
# Check disk space
df -h

# Check GPU
nvidia-smi

# Re-run setup
./setup_g1_cloud.sh
```

### Can't access web viewer
```bash
# Check if server is running
ps aux | grep node

# Try different port
WEBRTC_PORT=9000 ./launch_g1.sh webrtc
```

### Simulation crashes
```bash
# Check GPU memory
nvidia-smi

# Try simple mode first
./launch_g1.sh simple

# Check Isaac Lab
cd ~/g1_workspace/IsaacLab
./isaaclab.sh -p source/standalone/tutorials/00_sim/create_empty.py
```

### Want to use HuggingFace model
```bash
# Replace with your actual repo
HF_REPO='username/model-name' ./launch_g1.sh webrtc

# For private models
export HF_TOKEN='your_token'
HF_REPO='username/private-model' ./launch_g1.sh webrtc
```

---

## 📚 Documentation Guide

**Just want to start?**
→ Follow this file (START_HERE.md)

**Need step-by-step?**
→ Read [QUICKSTART.md](QUICKSTART.md)

**Want cheaper GPU?**
→ Read [GPU_COMPATIBILITY.md](GPU_COMPATIBILITY.md)

**Need technical details?**
→ Read [FILES_OVERVIEW.md](FILES_OVERVIEW.md)

**Complete reference?**
→ Read [README.md](README.md)

---

## ✅ Success Checklist

After setup, you should have:

- [ ] GPU detected (nvidia-smi shows L40S)
- [ ] Isaac Lab installed at `~/g1_workspace/IsaacLab`
- [ ] Test simulation runs: `./launch_g1.sh test`
- [ ] Simple mode works: `./launch_g1.sh simple`
- [ ] WebRTC server starts (no errors)
- [ ] Web viewer loads in browser
- [ ] Video stream appears
- [ ] Robot responds to keyboard

---

## 🎬 Next Steps

1. **Right Now:**
   ```bash
   ./setup_g1_cloud.sh
   ```

2. **After Setup Completes:**
   ```bash
   ./launch_g1.sh webrtc
   ```

3. **After It Works:**
   - Read [QUICKSTART.md](QUICKSTART.md) for advanced usage
   - Consider switching to cheaper GPU for dev work
   - Start customizing the code

---

## 💡 Pro Tips

1. **Don't waste money** - If just testing, use T4 or RTX 3060
2. **Use spot instances** - Save 50-70% on cloud costs
3. **Run headless** - WebRTC mode is already headless
4. **Save your work** - Use git to save changes
5. **Terminate when done** - Don't forget to stop your instance!

---

## 🆘 Need Help?

1. Check the troubleshooting section above
2. Read the error messages carefully
3. Check GPU with `nvidia-smi`
4. Verify files exist: `ls -la ~/g1_workspace/`
5. Check Isaac Lab logs: `~/g1_workspace/IsaacLab/logs/`

---

## 📞 Quick Reference

```bash
# Setup (once)
./setup_g1_cloud.sh

# Test mode
./launch_g1.sh test

# Simple mode (native viewer)
./launch_g1.sh simple

# WebRTC mode (remote viewer)
./launch_g1.sh webrtc

# With HuggingFace model
HF_REPO='user/model' ./launch_g1.sh webrtc

# Different port
WEBRTC_PORT=9000 ./launch_g1.sh webrtc

# Check GPU
nvidia-smi

# Check running processes
ps aux | grep isaac
ps aux | grep node
```

---

## 🎉 Ready?

Run this command to begin:

```bash
./setup_g1_cloud.sh
```

**Estimated time:** 30-60 minutes
**Cost on L40S:** ~$0.45-1.40 for setup
**Then:** Ready to teleop your G1! 🤖

---

Good luck! The setup is automated - just run the script and wait. See you on the other side! 🚀
