# Isaac Sim Native WebRTC Streaming Guide

**Use GPU on remote server, view on your local machine!**

This guide shows you how to use Isaac Sim's **native WebRTC streaming** to run simulations on a cloud GPU (Brev.dev) and view them on your local machine using the official Isaac Sim WebRTC Streaming Client.

---

## 🎯 Architecture

```
┌─────────────────────────┐          ┌─────────────────────────┐
│   LOCAL MACHINE         │          │   REMOTE GPU SERVER     │
│   (Your Laptop/PC)      │          │   (Brev.dev L40S)       │
│                         │          │                         │
│  Isaac Sim WebRTC       │◄────────►│  Isaac Sim + Isaac Lab  │
│  Streaming Client       │  Port    │  + G1 Simulation        │
│                         │  8211    │                         │
│  (Download ~100MB)      │          │  (~23GB installed)      │
└─────────────────────────┘          └─────────────────────────┘
```

**Benefits:**
- ✅ GPU-accelerated encoding on remote server
- ✅ Low latency (10-30ms typical)
- ✅ Official NVIDIA support
- ✅ Works on any OS (Windows, Mac, Linux)
- ✅ No custom WebRTC server needed
- ✅ Direct rendering from Isaac Sim

---

## Part 1: Remote Server Setup (Brev.dev)

### Step 1: Upload Files to Brev

**On your LOCAL machine:**

```bash
cd /home/bhavesh/rented

# Upload to Brev
scp -r * user@YOUR_BREV_INSTANCE.brev.dev:~/g1-setup/

# Or use git
git push origin main
# Then on Brev: git clone https://github.com/bhaveshbakshi633/g1-setup.git
```

### Step 2: SSH to Brev

```bash
ssh user@YOUR_BREV_INSTANCE.brev.dev
```

### Step 3: Run Setup (One Time, 30-60 min)

```bash
cd ~/g1-setup
chmod +x *.sh

# Use screen so you can detach
screen -S setup

# Run setup
./setup_isaac_native_streaming.sh

# This will:
# - Install Isaac Lab
# - Download Isaac Sim (~20GB)
# - Enable native streaming
# - Configure for remote access

# Detach: Ctrl+A, then D
# Reattach: screen -r setup
```

**Wait for:** "Ready to run Isaac Lab with Native Streaming!"

### Step 4: Copy Simulation Scripts

```bash
cd ~/g1-setup
cp g1_simple_test.py ~/g1_workspace/g1_project/
cp *.py ~/g1_workspace/g1_project/
```

---

## Part 2: Local Machine Setup (Your PC)

### Download Isaac Sim WebRTC Streaming Client

Choose your platform:

#### Windows
```powershell
# Download
Invoke-WebRequest -Uri "https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-windows.zip" -OutFile "streaming-client.zip"

# Extract
Expand-Archive streaming-client.zip

# Run
cd streaming-client
.\streaming-client.exe
```

#### macOS (Intel)
```bash
# Download
curl -L "https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-mac.zip" -o streaming-client.zip

# Extract
unzip streaming-client.zip

# Run
open streaming-client.app
```

#### macOS (Apple Silicon)
```bash
# Download
curl -L "https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-mac-arm64.zip" -o streaming-client.zip

# Extract
unzip streaming-client.zip

# Run
open streaming-client.app
```

#### Linux
```bash
# Download
wget https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-linux.AppImage

# Make executable
chmod +x omni-streaming-client-linux.AppImage

# Run
./omni-streaming-client-linux.AppImage
```

---

## Part 3: Running the Simulation

### Option A: Direct Connection (If Port is Open)

**On Brev (Remote Server):**
```bash
cd ~/g1-setup

# Open firewall port
sudo ufw allow 8211

# Launch simulation
./launch_native_streaming.sh ~/g1_workspace/g1_project/g1_simple_test.py
```

**On Your Local Machine:**

1. Open Isaac Sim WebRTC Streaming Client
2. Enter server address: `YOUR_BREV_IP:8211`
3. Click "Connect"
4. You should see the simulation!

### Option B: SSH Tunnel (More Secure, Recommended)

**Terminal 1 (Local Machine) - Create Tunnel:**
```bash
ssh -L 8211:localhost:8211 user@YOUR_BREV_INSTANCE.brev.dev

# Keep this terminal open!
```

**Terminal 2 (SSH to Brev):**
```bash
ssh user@YOUR_BREV_INSTANCE.brev.dev
cd ~/g1-setup
./launch_native_streaming.sh ~/g1_workspace/g1_project/g1_simple_test.py
```

**Isaac Sim WebRTC Client (Local):**
1. Open the client
2. Connect to: `localhost:8211`
3. Watch your G1 robot!

---

## Part 4: Running Your G1 Simulation

### Quick Test

```bash
# On Brev
cd ~/g1-setup
./launch_native_streaming.sh ~/g1_workspace/g1_project/g1_simple_test.py
```

This runs a 5-second test of the G1 robot standing.

### Full Simulation with Controls

Edit the simulation script to add your WBC and teleop:

```bash
# On Brev
nano ~/g1_workspace/g1_project/my_g1_sim.py
```

Then launch:
```bash
./launch_native_streaming.sh ~/g1_workspace/g1_project/my_g1_sim.py
```

---

## Troubleshooting

### "Cannot connect to remote server"

**Check 1: Is simulation running?**
```bash
# On Brev
ps aux | grep isaac
```

**Check 2: Is port accessible?**
```bash
# On Brev
sudo netstat -tlnp | grep 8211

# If using tunnel, check on local machine:
ps aux | grep "ssh.*8211"
```

**Check 3: Firewall**
```bash
# On Brev
sudo ufw status
sudo ufw allow 8211
```

### "Connection established but no video"

**Check rendering is enabled:**

Your script should **not** have `--headless` flag when using streaming.

The launch script already configures rendering correctly.

### "Low FPS / Laggy"

**Option 1: Reduce resolution**

Edit `/home/bhavesh/g1_workspace/IsaacLab/_isaac_sim/kit/configs/streaming.toml`:

```toml
"exts/omni.kit.streamer.webrtc/videoEncodeWidth" = 1280   # down from 1920
"exts/omni.kit.streamer.webrtc/videoEncodeHeight" = 720   # down from 1080
"exts/omni.kit.streamer.webrtc/videoBitrate" = 5000000    # down from 10000000
```

**Option 2: Lower FPS**

```toml
"exts/omni.kit.streamer.webrtc/videoEncodeFPS" = 30       # down from 60
```

### "Port 8211 already in use"

```bash
# Use different port
STREAMING_PORT=8212 ./launch_native_streaming.sh script.py

# Connect to localhost:8212 in client
```

---

## Performance Tips

### For Best Performance

1. **Use wired ethernet** on local machine (not WiFi)
2. **Close other applications** using network
3. **Use SSH tunnel** instead of direct connection
4. **Start with lower resolution** (720p), increase if smooth
5. **Monitor latency** in streaming client

### Expected Performance

| Connection | Resolution | FPS | Latency |
|------------|------------|-----|---------|
| Gigabit LAN | 1080p | 60 | 10-20ms |
| Fast WiFi | 1080p | 60 | 20-40ms |
| Remote (Good) | 720p | 30 | 40-80ms |
| Remote (Slow) | 480p | 30 | 100-200ms |

---

## Complete Workflow Summary

### One-Time Setup

**Local Machine:**
```bash
# 1. Download Isaac Sim WebRTC Client (100MB)
# See "Part 2" above for your platform

# 2. Upload files to Brev
cd /home/bhavesh/rented
scp -r * user@BREV:~/g1-setup/
```

**Remote (Brev):**
```bash
# 3. Run setup (30-60 min)
cd ~/g1-setup
screen -S setup
./setup_isaac_native_streaming.sh
```

### Every Time You Use It

**Terminal 1 (Local):**
```bash
ssh -L 8211:localhost:8211 user@BREV
```

**Terminal 2 (Remote):**
```bash
ssh user@BREV
cd ~/g1-setup
./launch_native_streaming.sh ~/g1_workspace/g1_project/g1_simple_test.py
```

**Isaac Sim WebRTC Client (Local):**
```
Connect to: localhost:8211
```

---

## Comparison: Native vs Custom WebRTC

| Feature | Native (This Guide) | Custom (Browser) |
|---------|---------------------|------------------|
| **Client** | Isaac Sim Client | Any Browser |
| **Setup** | Medium | Easy |
| **Latency** | Lower (10-30ms) | Higher (30-100ms) |
| **Quality** | Better (GPU encode) | Good (CPU encode) |
| **Controls** | Mouse/keyboard in client | Keyboard in browser |
| **File Size** | ~100MB client | ~0MB (browser) |
| **Best For** | Production work | Quick testing |

**Recommendation:**
- **Use Native** (this guide) for serious work and best performance
- **Use Custom** (browser version) for quick tests and demos

---

## HuggingFace Model Integration

To use pretrained WBC models with native streaming:

```bash
# On Brev
export HF_REPO='unitreerobotics/g1-wbc-model'
./launch_native_streaming.sh ~/g1_workspace/g1_project/g1_sim_webrtc.py
```

Your simulation script can load from HuggingFace as before - streaming is just the viewer!

---

## Cost Optimization

### Development Workflow

1. **Setup phase:** Use RTX 3060 ($0.20-0.30/hr)
   - Run setup_isaac_native_streaming.sh
   - Save Brev snapshot after complete
   - Total: ~$0.50 for setup

2. **Testing phase:** Use RTX 3060
   - Load from snapshot (no re-download)
   - Test your code, iterate
   - Cost: $0.20-0.30/hr

3. **Production phase:** Switch to L40S
   - Load from snapshot
   - Run multiple robots, train RL
   - Cost: $0.90-1.40/hr

**Savings:** ~75% during development!

---

## Next Steps

1. ✅ **Complete setup** on Brev (run setup_isaac_native_streaming.sh)
2. ✅ **Download client** on your local machine
3. ✅ **Test connection** with g1_simple_test.py
4. ✅ **Develop your simulation** with full GPU power
5. ✅ **Add WBC and teleop** as needed

---

## Quick Reference Card

```bash
# ===== REMOTE (BREV) =====

# Setup (once)
./setup_isaac_native_streaming.sh

# Launch simulation
./launch_native_streaming.sh SCRIPT.py

# Check if running
ps aux | grep isaac

# Check port
sudo netstat -tlnp | grep 8211


# ===== LOCAL MACHINE =====

# Create SSH tunnel
ssh -L 8211:localhost:8211 user@BREV

# Run Isaac Sim WebRTC Client
# Connect to: localhost:8211


# ===== BOTH =====

# Default port: 8211
# Change with: STREAMING_PORT=8212
```

---

## Support

**Isaac Sim Native Streaming Docs:**
https://docs.omniverse.nvidia.com/isaacsim/latest/advanced_tutorials/tutorial_advanced_streaming.html

**WebRTC Client Download:**
https://docs.omniverse.nvidia.com/isaacsim/latest/installation/install_faq.html#streaming-client

**This Setup Issues:**
Check CURRENT_STATUS.md and troubleshooting section above

---

**Ready to stream from your cloud GPU!** 🚀
