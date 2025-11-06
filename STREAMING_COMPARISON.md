# WebRTC Streaming Options Comparison

## Two Ways to Stream from Cloud GPU

### Option 1: Isaac Sim Native Streaming ⭐ RECOMMENDED

**What it is:** NVIDIA's official WebRTC streaming built into Isaac Sim

**Setup:**
- Remote (Brev): `./setup_isaac_native_streaming.sh`
- Local: Download Isaac Sim WebRTC Streaming Client (~100MB)

**Pros:**
- ✅ Lower latency (10-30ms typical)
- ✅ GPU-accelerated video encoding
- ✅ Official NVIDIA support
- ✅ Better video quality
- ✅ Mouse and keyboard controls in client
- ✅ Direct from Isaac Sim rendering pipeline

**Cons:**
- ❌ Need to download client on local machine
- ❌ Slightly more setup steps

**Best for:**
- Production work
- Training RL policies
- Long development sessions
- When you need best performance

**Guide:** [NATIVE_STREAMING_GUIDE.md](NATIVE_STREAMING_GUIDE.md)

---

### Option 2: Custom Browser-Based Streaming

**What it is:** Custom Node.js WebRTC server + browser viewer

**Setup:**
- Remote (Brev): `./setup_g1_cloud.sh`
- Local: Just use any web browser

**Pros:**
- ✅ No client download needed
- ✅ Works in any browser
- ✅ Simpler setup
- ✅ Good for quick demos

**Cons:**
- ❌ Higher latency (30-100ms)
- ❌ CPU-based encoding (slower)
- ❌ Lower video quality
- ❌ Keyboard-only controls
- ❌ Additional Node.js server needed

**Best for:**
- Quick testing
- Demos and showcases
- When you can't install software locally
- Simple visualizations

**Guide:** [BREV_SETUP.md](BREV_SETUP.md)

---

## Side-by-Side Comparison

| Feature | Native (Option 1) | Custom (Option 2) |
|---------|-------------------|-------------------|
| **Latency** | 10-30ms | 30-100ms |
| **Video Quality** | Excellent (GPU) | Good (CPU) |
| **Resolution** | Up to 4K | Up to 1080p |
| **FPS** | Up to 60 | Up to 30 |
| **Local Client** | ~100MB download | Web browser (0MB) |
| **Controls** | Mouse + Keyboard | Keyboard only |
| **Setup Time** | 5 min | 2 min |
| **Encoding** | GPU (NVENC) | CPU (software) |
| **Port** | 8211 | 8080 |
| **Dependencies** | None (built-in) | Node.js server |

---

## Quick Setup Commands

### Native Streaming (Recommended)

**Remote (Brev):**
```bash
cd ~/g1-setup
./setup_isaac_native_streaming.sh  # One time
./launch_native_streaming.sh script.py
```

**Local:**
```bash
# Download client (one time)
# See NATIVE_STREAMING_GUIDE.md for links

# Create SSH tunnel
ssh -L 8211:localhost:8211 user@BREV

# Run client, connect to: localhost:8211
```

### Custom Browser Streaming

**Remote (Brev):**
```bash
cd ~/g1-setup
./setup_g1_cloud.sh  # One time
./launch_g1.sh webrtc
```

**Local:**
```bash
# Create SSH tunnel
ssh -L 8080:localhost:8080 user@BREV

# Open browser: http://localhost:8080
```

---

## Performance Comparison

### Native Streaming
```
Remote GPU (L40S): Renders scene at 1080p60
                   ↓
                   GPU encodes to H.264 (hardware)
                   ↓
                   WebRTC stream (~5Mbps)
                   ↓
Local Machine:     Decodes and displays

Total Latency:     10-30ms
CPU Usage (Local): Low (hardware decode)
Quality:           Excellent
```

### Custom Streaming
```
Remote GPU (L40S): Renders scene
                   ↓
                   CPU captures frame
                   ↓
                   CPU encodes to JPEG
                   ↓
                   WebSocket sends base64
                   ↓
Local Machine:     Browser decodes and displays

Total Latency:     30-100ms
CPU Usage (Local): Medium
Quality:           Good
```

---

## When to Use Each

### Use Native Streaming If:
- You're doing serious development work
- You want best performance
- You can install software on local machine
- You'll be using it for multiple sessions
- You need low latency for RL training visualization
- You want GPU-accelerated encoding

### Use Custom Streaming If:
- You just want to quickly test something
- You can't install software locally
- You're on a locked-down corporate machine
- You want to share link with others
- You need to work from different devices
- You're doing simple demos

---

## My Recommendation

**Start with Native Streaming** (Option 1)

Why?
1. You're on a **powerful GPU (L40S)** - make full use of it!
2. Better experience for development
3. Official NVIDIA support
4. One-time client download (~5 min)
5. Will save you time in the long run

The custom browser version is great for quick tests, but if you're doing serious work with G1 and WBC, the native streaming is worth the small extra setup.

---

## Can I Use Both?

**Yes!** They use different ports and can coexist:

```bash
# Terminal 1: Native streaming
./launch_native_streaming.sh script.py  # Port 8211

# Terminal 2: Custom streaming
./launch_g1.sh webrtc  # Port 8080
```

Connect to either one from your local machine.

---

## Quick Start (Absolute Beginner)

**If you just want to get started RIGHT NOW:**

1. Use **Custom Browser Streaming** (Option 2)
   - Faster initial setup
   - Works in browser
   - Good enough for first test

2. Once you verify it works, switch to **Native Streaming** (Option 1)
   - Better for everything else
   - Download client (5 min)
   - Much better experience

---

## Files Reference

| Purpose | Native Streaming | Custom Streaming |
|---------|------------------|------------------|
| Setup Script | `setup_isaac_native_streaming.sh` | `setup_g1_cloud.sh` |
| Launch Script | `launch_native_streaming.sh` | `launch_g1.sh webrtc` |
| Guide | `NATIVE_STREAMING_GUIDE.md` | `BREV_SETUP.md` |
| Port | 8211 | 8080 |

---

## Summary

- **Native Streaming = Professional grade** (like Zoom for robotics)
- **Custom Streaming = Good enough** (like screen sharing)

Both work, both are reliable. Native is better if you can use it.

Choose based on your needs! 🚀
