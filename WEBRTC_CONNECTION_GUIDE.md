# Isaac Sim WebRTC Streaming - Connection Guide

## ✅ WebRTC Server Status

**The streaming server is running!**

- Server IP: `172.16.7.159`
- Port: `8211`
- Status: **Streaming server started** ✓
- G1 Robot: Loading (simulation running)

---

## 🔗 How to Connect

### If Client is on Same Network (Direct):

1. **Open Isaac Sim WebRTC Client** (from your Downloads)

2. **Connect to:**
   ```
   172.16.7.159:8211
   ```

3. You should see the G1 robot in the Isaac Sim environment!

---

### If Using SSH (Remote Connection):

1. **Create SSH Tunnel** (in a terminal on your local machine):
   ```bash
   ssh -L 8211:localhost:8211 bhavesh@172.16.7.159
   ```

   Leave this terminal open while streaming.

2. **Open Isaac Sim WebRTC Client**

3. **Connect to:**
   ```
   localhost:8211
   ```

---

## 📥 Isaac Sim WebRTC Client Download

If you need to download it:

### Linux:
```bash
cd ~/Downloads
wget https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-linux.AppImage
chmod +x omni-streaming-client-linux.AppImage
./omni-streaming-client-linux.AppImage
```

### Windows:
https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-windows.zip

### Mac (Intel):
https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-mac.zip

### Mac (Apple Silicon):
https://install.launcher.omniverse.nvidia.com/installers/omni-streaming-client-mac-arm64.zip

---

## 🎮 Controls Once Connected

When you see the G1 robot:

- **Mouse**: Rotate camera
- **WASD**: Move camera
- **Q/E**: Up/Down
- **Shift**: Speed up camera movement

---

## 🔍 Troubleshooting

### Can't Connect?

1. **Check if streaming server is running:**
   ```bash
   ps aux | grep g1_simple_test | grep -v grep
   ```

2. **Check port 8211:**
   ```bash
   sudo netstat -tlnp | grep 8211
   ```

3. **Restart streaming:**
   ```bash
   pkill -f g1_simple_test
   ./launch_native_streaming.sh g1_simple_test.py
   ```

### Connection Timeout?

- Make sure firewall allows port 8211
- Verify SSH tunnel is running (if using SSH)
- Check server IP is correct: `hostname -I`

### Black Screen?

- The G1 robot might still be loading assets
- Wait 1-2 minutes for initial load
- Check simulation log: `tail -f /tmp/stream.log`

---

## 📊 Current Test Details

**Running simulation:**
- Script: `g1_simple_test.py`
- Environment: Conda `isaaclab`
- Duration: 500 steps (5 seconds of simulation time)
- Robot: Unitree G1 (37 joints, 44 bodies)

---

## 🚀 Next Steps

Once you connect and see the G1 robot:

1. **Verify the robot is visible** in the Isaac Sim viewport
2. **Watch it for 5 seconds** as the test runs
3. The robot should be standing on a ground plane with lighting

After this test completes:
- Implement keyboard teleoperation
- Load pretrained WBC models from HuggingFace
- Deploy to Brev.dev cloud GPU

---

## 🎯 Quick Commands

**Launch streaming:**
```bash
cd ~/g1-setup
./launch_native_streaming.sh g1_simple_test.py
```

**Stop streaming:**
```bash
pkill -f g1_simple_test
```

**Check status:**
```bash
ps aux | grep g1_simple | grep -v grep
tail /tmp/stream.log
```

---

## 📝 Server Info

- **Server IP:** `172.16.7.159`
- **Streaming Port:** `8211`
- **GPU:** NVIDIA GeForce RTX 4070 Laptop (8GB)
- **Environment:** Conda `isaaclab`
- **Isaac Sim:** 5.1.0
- **Isaac Lab:** Latest

---

**Ready to connect!** Open your Isaac Sim WebRTC Client and connect to `172.16.7.159:8211` (or `localhost:8211` if using SSH tunnel).
