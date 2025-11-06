# Brev.dev Setup Guide - CLI Only

## Overview

You have CLI-only access via Brev → Perfect for headless Isaac Lab with WebRTC!

**No GUI needed** - Everything runs in terminal, view in your browser via SSH tunnel.

---

## Step 1: Transfer Files to Brev Instance

### Option A: Git (Recommended)

On your **local machine**, create a git repo:

```bash
cd /home/bhavesh/rented
git init
git add .
git commit -m "Initial setup"

# Push to GitHub (or GitLab, etc)
# Create a repo on GitHub first, then:
git remote add origin https://github.com/YOUR_USERNAME/g1-setup.git
git push -u origin main
```

Then on your **Brev instance**:

```bash
# Clone the repo
cd ~
git clone https://github.com/YOUR_USERNAME/g1-setup.git
cd g1-setup
```

### Option B: SCP (Direct Upload)

From your **local machine**:

```bash
# Get your Brev instance address (from Brev dashboard)
# It looks like: user@instance-id.brev.dev

# Upload all files
cd /home/bhavesh/rented
scp *.sh *.py *.js *.html *.json *.md *.env user@your-instance.brev.dev:~/
```

### Option C: Manual Copy-Paste (If Small Files)

For each file:
1. On local: `cat filename.sh`
2. Copy the output
3. On Brev: `nano filename.sh`
4. Paste content
5. Save (Ctrl+X, Y, Enter)
6. Repeat for all files

Then make scripts executable:
```bash
chmod +x *.sh
```

---

## Step 2: Verify Your Brev Instance

```bash
# Check GPU
nvidia-smi

# Should show your L40S or RTX 6000

# Check system
./check_system.sh
```

**Expected output:**
- ✓ L40S detected
- ✓ CUDA available
- ✓ Disk space OK
- ✓ RAM OK

---

## Step 3: Run Setup (One Time)

```bash
# This takes 30-60 minutes
# You can let it run in background
./setup_g1_cloud.sh
```

**Important for Brev:**
- Setup runs entirely headless ✅
- No display/GUI needed ✅
- Downloads ~30GB (check your Brev data limits)
- Uses sudo (should work on Brev instances)

### If Session Disconnects:

Use `screen` or `tmux` to keep it running:

```bash
# Install screen if not available
sudo apt-get install -y screen

# Start screen session
screen -S setup

# Run setup
./setup_g1_cloud.sh

# Detach: Ctrl+A, then D
# Reattach later: screen -r setup
```

---

## Step 4: Setup SSH Tunnel (Critical for Brev!)

Since Brev gives CLI-only access, you need SSH tunnel to view WebRTC.

### On Your Local Machine:

```bash
# Get your Brev instance address
# From Brev dashboard, it's like: user@xyz123.brev.dev

# Create SSH tunnel for WebRTC port
ssh -L 8080:localhost:8080 user@xyz123.brev.dev
```

**Keep this terminal open!**

Now `localhost:8080` on your local machine → port 8080 on Brev instance.

---

## Step 5: Launch Simulation

### In Your Brev SSH Session:

```bash
# Make sure you're in the right directory
cd ~/g1-setup  # or wherever you put the files

# Launch in WebRTC mode (headless)
./launch_g1.sh webrtc
```

**Expected output:**
```
========================================
Unitree G1 Launch Script
========================================
[INFO] Using IsaacLab at: /home/user/g1_workspace/IsaacLab
[INFO] Starting WebRTC server on port 8080...
WebRTC viewer available at:
  Local:  http://localhost:8080
  Remote: http://YOUR_IP:8080
[INFO] Launching Isaac Lab simulation...
```

---

## Step 6: View in Browser

### On Your Local Machine:

Open browser → `http://localhost:8080`

You should see:
- ✅ Unitree G1 Viewer interface
- ✅ "Connected" status (green dot)
- ✅ Video stream appears after ~10 seconds
- ✅ FPS counter shows ~30 FPS

### Control the Robot:

Use keyboard in browser:
- **W/A/S/D** - Move
- **Q/E** - Turn
- **R** - Reset
- **P** - Pause

---

## Brev-Specific Considerations

### 1. Data Transfer Limits

Brev may have data limits. Setup downloads ~30GB:
- Isaac Lab: ~20GB
- Dependencies: ~10GB
- CUDA libraries: already installed ✅

**Check your Brev plan limits!**

### 2. Instance Types

Brev offers different GPUs:

| GPU | VRAM | Good For |
|-----|------|----------|
| RTX 4090 | 24GB | Excellent |
| L40S | 48GB | Overkill (your current) |
| A100 | 40GB | Overkill |
| RTX 3090 | 24GB | Great |
| RTX 3060 | 12GB | Fine for testing |

**For testing:** RTX 3060 is plenty and much cheaper!

### 3. Port Access

Brev instances are firewalled by default.
- ✅ SSH tunnel bypasses this
- ❌ Don't try to open port 8080 directly
- ✅ All access via `ssh -L`

### 4. Persistent Storage

Check if your Brev instance has persistent storage:

```bash
# Check mounted volumes
df -h

# Your workspace should be on persistent storage
# Usually /home/user or /workspace
```

**Install to persistent location:**
- Default: `~/g1_workspace` (usually persistent)
- If not, edit `config.env`:
  ```bash
  export WORKSPACE_DIR="/workspace/g1_workspace"
  ```

### 5. Session Management

Brev CLI sessions may timeout. Use `tmux` or `screen`:

```bash
# Install tmux
sudo apt-get install -y tmux

# Start tmux session
tmux new -s g1

# Run simulation
./launch_g1.sh webrtc

# Detach: Ctrl+B, then D
# Reattach: tmux attach -t g1
# List sessions: tmux ls
```

---

## Complete Brev Workflow

### One-Time Setup:

```bash
# On local machine
cd /home/bhavesh/rented
git init && git add . && git commit -m "setup"
# Push to GitHub

# SSH to Brev
ssh user@xyz.brev.dev

# On Brev instance
git clone https://github.com/YOUR_USERNAME/g1-setup.git
cd g1-setup
chmod +x *.sh

# Start screen session
screen -S setup

# Run setup (takes 30-60 min)
./setup_g1_cloud.sh

# Detach screen: Ctrl+A, then D
# Check progress later: screen -r setup
```

### Every Time You Run:

**Terminal 1 (local machine):**
```bash
# SSH tunnel
ssh -L 8080:localhost:8080 user@xyz.brev.dev

# Or combined with tmux
ssh -L 8080:localhost:8080 user@xyz.brev.dev -t "tmux attach -t g1 || tmux new -s g1"
```

**Terminal 2 (in SSH session):**
```bash
cd ~/g1-setup
./launch_g1.sh webrtc
```

**Browser (local machine):**
```
http://localhost:8080
```

---

## Troubleshooting for Brev

### "Permission denied" during setup

```bash
# Make sure sudo works
sudo whoami
# Should print: root

# If not, contact Brev support
```

### "Out of disk space"

```bash
# Check space
df -h

# Clean apt cache
sudo apt-get clean

# Remove old packages
sudo apt-get autoremove
```

### "Cannot connect to WebRTC server"

```bash
# Check if server is running
ps aux | grep node

# Check if port is listening
sudo netstat -tlnp | grep 8080

# Check SSH tunnel is active (on local machine)
ps aux | grep "ssh.*8080"
```

### "GPU not detected"

```bash
# Check GPU
nvidia-smi

# If not working, restart Brev instance
# (through Brev dashboard)
```

### Session keeps disconnecting

```bash
# Use tmux with automatic reconnection
# Add to ~/.bashrc on Brev:
alias start-g1='tmux new -A -s g1'

# Then just run:
start-g1
./launch_g1.sh webrtc
```

---

## Optimized Brev Setup (Minimal Cost)

### For Testing Only (Your Use Case):

1. **Use smallest GPU first:**
   - Start with RTX 3060 (12GB)
   - Cost: ~$0.20-0.30/hr
   - Perfect for testing

2. **Run setup once:**
   ```bash
   screen -S setup
   ./setup_g1_cloud.sh
   # Detach, let it run
   ```

3. **Take a snapshot:**
   - After setup completes
   - Save the instance state
   - Destroy instance
   - Spin up from snapshot next time

4. **For production:**
   - Use L40S or RTX 4090
   - Load from snapshot (skip 30min setup)
   - Run your experiments
   - Destroy when done

### Cost Comparison:

| Approach | GPU | Time | Cost |
|----------|-----|------|------|
| Setup on L40S | L40S | 1hr | ~$1.20 |
| Setup on RTX 3060 | RTX 3060 | 1hr | ~$0.25 |
| **Savings** | | | **$0.95** |

---

## File Transfer Best Practices

### Small Changes:

```bash
# Edit on Brev directly
ssh user@xyz.brev.dev
cd ~/g1-setup
nano g1_sim_webrtc.py
# Make changes
# Test
./launch_g1.sh webrtc
```

### Large Changes:

```bash
# On local machine
cd /home/bhavesh/rented
git add .
git commit -m "Updated config"
git push

# On Brev
cd ~/g1-setup
git pull
./launch_g1.sh webrtc
```

---

## Quick Reference Card

```bash
# ====================================
# BREV QUICK REFERENCE
# ====================================

# SSH with tunnel (local machine)
ssh -L 8080:localhost:8080 user@xyz.brev.dev

# Check GPU (on Brev)
nvidia-smi

# Run setup (once)
screen -S setup
./setup_g1_cloud.sh
# Ctrl+A, D to detach

# Launch simulation
tmux new -s g1
./launch_g1.sh webrtc
# Ctrl+B, D to detach

# View in browser (local machine)
http://localhost:8080

# Reattach to session
screen -r setup    # for setup
tmux attach -t g1  # for simulation

# Stop simulation
# Ctrl+C in the tmux session

# ====================================
```

---

## Your Complete Brev Workflow

### Phase 1: First Time (Do Once)

```bash
# 1. On local machine - push to git
cd /home/bhavesh/rented
git init
git add .
git commit -m "g1 setup"
# Push to GitHub

# 2. SSH to Brev (with tunnel)
ssh -L 8080:localhost:8080 user@YOUR_INSTANCE.brev.dev

# 3. Clone repo on Brev
git clone https://github.com/YOUR_USERNAME/g1-setup.git
cd g1-setup
chmod +x *.sh

# 4. Check system
./check_system.sh

# 5. Run setup in screen
screen -S setup
./setup_g1_cloud.sh
# Wait or detach: Ctrl+A, then D

# 6. After setup completes (30-60 min)
screen -r setup  # reattach if detached
# Setup should say "Ready to run!"
```

### Phase 2: Every Time You Use It

```bash
# 1. SSH with tunnel (local machine)
ssh -L 8080:localhost:8080 user@YOUR_INSTANCE.brev.dev

# 2. Navigate and launch (on Brev)
cd ~/g1-setup
./launch_g1.sh webrtc

# 3. Open browser (local machine)
http://localhost:8080

# 4. Control robot, experiment, develop

# 5. Stop when done
# Ctrl+C in terminal

# 6. Don't forget to stop Brev instance!
```

---

## Pro Tips for Brev

1. **Use tmux/screen always** - Sessions can disconnect
2. **Clone via HTTPS** - SSH keys can be tricky on Brev
3. **Keep tunnel open** - Don't close the SSH window
4. **Save snapshots** - After successful setup
5. **Monitor costs** - Check Brev dashboard regularly
6. **Start small** - Test on RTX 3060, scale to L40S if needed

---

## Next Steps

1. **Transfer files to Brev** (git or scp)
2. **Run check_system.sh** (verify GPU)
3. **Run setup_g1_cloud.sh** (in screen session)
4. **Setup SSH tunnel** (from local machine)
5. **Launch simulation** (./launch_g1.sh webrtc)
6. **View in browser** (http://localhost:8080)

---

## Summary

✅ **CLI-only Brev** → Perfect for headless setup
✅ **WebRTC** → View remotely via SSH tunnel
✅ **No GUI needed** → Everything runs in terminal
✅ **Git workflow** → Easy file transfer
✅ **tmux/screen** → Session persistence
✅ **Cost-aware** → Start small, scale up

**You're all set for Brev! 🚀**
