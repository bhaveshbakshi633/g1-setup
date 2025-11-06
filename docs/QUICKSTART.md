# Quick Start Guide - Unitree G1 on Cloud GPU

## Prerequisites

- Cloud GPU instance with RTX 6000 (or similar)
- Ubuntu 20.04 or 22.04
- At least 50GB disk space
- SSH access to your instance

## Step-by-Step Setup

### 1. Connect to Your Cloud Instance

```bash
ssh user@your-instance-ip
```

### 2. Download the Setup Files

If you have these files locally, upload them:

```bash
# From your local machine
scp *.sh *.py *.js *.html *.md user@your-instance-ip:~/rented/
```

Or clone from a git repository if available.

### 3. Navigate to Directory

```bash
cd ~/rented
```

### 4. Run Setup (30-60 minutes)

```bash
chmod +x setup_g1_cloud.sh
./setup_g1_cloud.sh
```

**What happens during setup:**
- ✓ System packages installation (5 min)
- ✓ Isaac Lab clone and build (20-40 min)
- ✓ Python dependencies (5-10 min)
- ✓ WebRTC server setup (2 min)

**Go get coffee!** ☕

### 5. Launch the Simulation

```bash
chmod +x launch_g1.sh
./launch_g1.sh webrtc
```

Wait for output:
```
WebRTC viewer available at:
  Local:  http://localhost:8080
  Remote: http://YOUR_IP:8080
```

### 6. Open Web Viewer

**Option A: SSH Tunnel (Recommended)**

From your local machine:
```bash
ssh -L 8080:localhost:8080 user@your-instance-ip
```

Then open: `http://localhost:8080`

**Option B: Direct Access**

Open firewall port on cloud instance:
```bash
sudo ufw allow 8080
```

Then open: `http://YOUR_INSTANCE_IP:8080`

### 7. Control the Robot

Use the web viewer:
- **W/A/S/D** - Move
- **Q/E** - Turn
- **R** - Reset
- **P** - Pause

## Verification Checklist

After setup, verify:

- [ ] `nvidia-smi` shows GPU
- [ ] Directory `~/g1_workspace/IsaacLab` exists
- [ ] Can run: `cd ~/g1_workspace/IsaacLab && ./isaaclab.sh -p -c "print('Hello')"`
- [ ] WebRTC server starts: `cd ~/rented && node webrtc_server.js`
- [ ] Can access web viewer at `http://localhost:8080`

## Common Issues

### Setup fails during Isaac Lab installation

```bash
# Check disk space
df -h

# Check CUDA
nvidia-smi

# Retry setup
./setup_g1_cloud.sh
```

### Can't access web viewer

```bash
# Check if WebRTC server is running
ps aux | grep node

# Check port
sudo netstat -tulpn | grep 8080

# Restart with different port
WEBRTC_PORT=9000 ./launch_g1.sh webrtc
```

### Simulation crashes

```bash
# Check GPU memory
nvidia-smi

# Try simple mode first
./launch_g1.sh test

# Check logs
cd ~/g1_workspace/IsaacLab
./isaaclab.sh -p ~/rented/simple_g1_teleop.py
```

## Cloud Provider Specific Notes

### RunPod

1. Use PyTorch template
2. Enable "Start Jupyter Notebook"
3. Use provided IP and port
4. Open firewall: TCP port 8080

### Lambda Labs

1. Use Ubuntu 22.04 + PyTorch image
2. Launch instance with SSH key
3. No firewall needed (all ports open by default)

### Paperspace

1. Use ML-in-a-Box template
2. Enable public IP
3. Open firewall in console: port 8080

### Vast.ai

1. Use NVIDIA runtime
2. Open ports: 8080, 22
3. May need to manually install Node.js

## Estimated Costs

| Provider | GPU | Cost/Hour | Setup | Total (2hrs) |
|----------|-----|-----------|-------|--------------|
| RunPod | RTX 6000 | $0.79 | Free | $1.58 |
| Lambda | RTX 6000 | $1.10 | Free | $2.20 |
| Paperspace | A6000 | $1.38 | Free | $2.76 |
| Vast.ai | RTX 6000 | $0.50 | Free | $1.00 |

**💡 Tip:** Use spot/interruptible instances to save 50-70%!

## What to Do Next

1. **Test basic controls** - Move the robot around
2. **Try different models** - Use HuggingFace models
3. **Modify the code** - Edit `g1_sim_webrtc.py`
4. **Record videos** - Add video capture
5. **Train RL policy** - Use Isaac Lab RL tools

## Stopping Your Instance

**IMPORTANT:** Don't forget to stop your cloud instance!

```bash
# From your local machine
# RunPod: Use web dashboard
# Lambda: lambda-cli terminate <instance-id>
# Or use provider's web interface
```

## Getting Help

1. Check [README.md](README.md) for detailed docs
2. Review error messages in terminal
3. Check Isaac Lab logs: `~/g1_workspace/IsaacLab/logs/`
4. Verify GPU with `nvidia-smi`

## Success Criteria

You should see:
- ✓ Web viewer loads
- ✓ Video stream appears
- ✓ Robot is standing
- ✓ Controls respond
- ✓ FPS counter shows ~30 FPS

## Next Steps Guide

### Beginner
- [ ] Run the test simulation
- [ ] Open web viewer
- [ ] Control robot with keyboard
- [ ] Reset and pause simulation

### Intermediate
- [ ] Modify joint stiffness in code
- [ ] Change camera angle
- [ ] Add custom keyboard commands
- [ ] Record video of simulation

### Advanced
- [ ] Load pretrained model from HuggingFace
- [ ] Implement custom gait pattern
- [ ] Add multiple robots (num_envs > 1)
- [ ] Train RL policy for locomotion

Enjoy your Unitree G1 simulation! 🤖
