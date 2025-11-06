# Unitree G1 Isaac Lab Setup with WebRTC Visualization

Complete setup for running Unitree G1 humanoid robot in Isaac Lab on a cloud GPU (RTX 6000) with remote WebRTC visualization and teleoperation.

## Features

- ✅ Full Isaac Lab installation
- ✅ Unitree G1 robot model
- ✅ Pretrained WBC (Whole Body Control) support from HuggingFace
- ✅ WebRTC streaming for remote visualization
- ✅ Keyboard-based teleoperation
- ✅ Easy deployment on cloud GPU instances

## Quick Start

### 1. Initial Setup (Run Once)

```bash
chmod +x setup_g1_cloud.sh
./setup_g1_cloud.sh
```

This will:
- Install all system dependencies
- Clone and setup Isaac Lab
- Download Unitree G1 models
- Setup WebRTC streaming server
- Install Python packages

**Note:** This takes 30-60 minutes depending on your internet connection.

### 2. Launch Simulation

#### Option A: With WebRTC Streaming (Recommended for Cloud)

```bash
chmod +x launch_g1.sh
./launch_g1.sh webrtc
```

Then open your browser to:
- Local: `http://localhost:8080`
- Remote: `http://<your-server-ip>:8080`

#### Option B: Simple Mode (Local Viewer)

```bash
./launch_g1.sh simple
```

This opens the native Isaac Lab viewer (requires display/X11).

#### Option C: With Pretrained Model from HuggingFace

```bash
HF_REPO='unitreerobotics/g1-wbc-model' ./launch_g1.sh webrtc
```

## File Structure

```
/home/bhavesh/rented/
├── setup_g1_cloud.sh          # Initial setup script
├── launch_g1.sh               # Launch script
├── g1_sim_webrtc.py          # Main simulation with WebRTC
├── simple_g1_teleop.py       # Simple teleop (no WebRTC)
├── webrtc_server.js          # WebRTC server
├── webrtc_streamer.py        # Python WebRTC streamer
├── viewer.html               # Web viewer interface
└── README.md                 # This file

~/g1_workspace/
├── IsaacLab/                 # Isaac Lab installation
├── g1_project/               # Your project files
└── webrtc_server/            # WebRTC server files
```

## WebRTC Viewer Controls

### Keyboard Controls

- **W / S** - Move forward/backward
- **A / D** - Strafe left/right
- **Q / E** - Turn left/right
- **Arrow Keys** - Body pitch/roll
- **Space** - Jump (if implemented)
- **R** - Reset simulation
- **P** - Pause/Resume

### Button Controls

- **Reset Simulation** - Reset robot to initial pose
- **Pause/Resume** - Pause or resume simulation
- **Stand Up** - Return to standing pose

## Advanced Usage

### Using Custom HuggingFace Models

If you have a pretrained WBC model on HuggingFace:

```bash
export HF_REPO='your-username/your-model-name'
./launch_g1.sh webrtc
```

The model should have a `policy.pt` file containing the PyTorch model.

### Changing WebRTC Port

```bash
export WEBRTC_PORT=9000
./launch_g1.sh webrtc
```

### Running Headless

The WebRTC mode already runs headless. For simple mode:

```bash
./launch_g1.sh simple --headless
```

## Troubleshooting

### "CUDA not available"

Check your GPU:
```bash
nvidia-smi
```

Make sure you're on a GPU instance.

### "IsaacLab not found"

Run the setup script again:
```bash
./setup_g1_cloud.sh
```

### "Cannot connect to WebRTC server"

1. Check if server is running:
```bash
ps aux | grep node
```

2. Check firewall settings:
```bash
sudo ufw allow 8080
```

3. Try a different port:
```bash
WEBRTC_PORT=9000 ./launch_g1.sh webrtc
```

### WebRTC viewer shows "Waiting for video stream"

1. Make sure the simulation is running (check terminal for errors)
2. Refresh the browser page
3. Check browser console for errors (F12)

### G1 model not found

The script attempts to use the built-in G1 model from Isaac Lab. If it's not available:

1. Check Isaac Lab version:
```bash
cd ~/g1_workspace/IsaacLab
git log -1
```

2. You may need to download the G1 USD file separately or use a different robot model.

### Performance issues

1. **Lower streaming framerate:**
   ```bash
   # Edit g1_sim_webrtc.py and change --stream_every to a higher value
   # Default is 2 (every 2 frames), try 4 or 6
   ```

2. **Reduce camera resolution:**
   Edit `g1_sim_webrtc.py` and change camera settings:
   ```python
   height=480,  # Down from 720
   width=854,   # Down from 1280
   ```

3. **Use CPU for rendering:**
   ```bash
   # Only if GPU is overloaded
   export CUDA_VISIBLE_DEVICES=""
   ./launch_g1.sh simple
   ```

## Cost Considerations

Running on cloud RTX 6000 (e.g., on RunPod, Lambda Labs, etc.):
- Typical cost: $0.50-$1.50/hour
- Setup time: ~45 minutes (one-time)
- Recommended: Use spot instances to save costs
- Don't forget to shut down your instance when done!

## Architecture

```
┌─────────────────┐
│   Web Browser   │
│   (Viewer)      │
└────────┬────────┘
         │ WebSocket
         ▼
┌─────────────────┐
│  WebRTC Server  │
│   (Node.js)     │
└────────┬────────┘
         │ WebSocket
         ▼
┌─────────────────┐
│  Isaac Lab Sim  │
│  + G1 Robot     │
│  + WBC Policy   │
└─────────────────┘
```

## Next Steps

1. **Implement custom gaits** - Modify `g1_sim_webrtc.py` to add walking gaits
2. **Train your own policy** - Use Isaac Lab's RL framework
3. **Add more sensors** - IMU, force sensors, cameras on robot
4. **Multi-robot** - Change `num_envs` to run multiple robots
5. **Record videos** - Save WebRTC stream to video file

## References

- [Isaac Lab Documentation](https://isaac-sim.github.io/IsaacLab/)
- [Unitree Robotics](https://www.unitree.com/)
- [HuggingFace Hub](https://huggingface.co/)

## Support

For issues:
1. Check the troubleshooting section above
2. Review Isaac Lab documentation
3. Check terminal output for error messages

## License

This setup script is provided as-is for educational and research purposes.
Isaac Lab and Unitree G1 assets have their own respective licenses.
