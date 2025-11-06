# Files Overview - Unitree G1 Isaac Lab Setup

Complete guide to all files in this project and what they do.

## 📋 Table of Contents

1. [Setup Scripts](#setup-scripts)
2. [Launch Scripts](#launch-scripts)
3. [Simulation Code](#simulation-code)
4. [WebRTC Components](#webrtc-components)
5. [Documentation](#documentation)
6. [Configuration](#configuration)

---

## Setup Scripts

### `setup_g1_cloud.sh`
**Purpose:** Complete system setup from scratch

**What it does:**
- ✓ Installs system dependencies (build tools, Python, Node.js)
- ✓ Checks CUDA/GPU availability
- ✓ Clones Isaac Lab from GitHub
- ✓ Installs Isaac Lab (downloads Isaac Sim, sets up Python environment)
- ✓ Downloads Unitree G1 robot assets
- ✓ Sets up WebRTC server infrastructure
- ✓ Installs Python packages (PyTorch, HuggingFace, OpenCV, etc.)
- ✓ Creates workspace directory structure

**Usage:**
```bash
chmod +x setup_g1_cloud.sh
./setup_g1_cloud.sh
```

**Time:** 30-60 minutes (one-time only)

**Output:**
- `~/g1_workspace/IsaacLab/` - Isaac Lab installation
- `~/g1_workspace/g1_project/` - Your project directory
- `~/g1_workspace/webrtc_server/` - WebRTC server

---

## Launch Scripts

### `launch_g1.sh`
**Purpose:** Launch the simulation in different modes

**Modes:**

1. **webrtc** (default) - Full WebRTC streaming
   ```bash
   ./launch_g1.sh webrtc
   ```
   - Starts WebRTC server
   - Launches headless simulation
   - Enables remote viewing via browser

2. **simple** - Local viewer only
   ```bash
   ./launch_g1.sh simple
   ```
   - Opens native Isaac Lab viewport
   - No WebRTC (requires display/X11)

3. **test** - Quick verification
   ```bash
   ./launch_g1.sh test
   ```
   - Tests Isaac Lab installation
   - Runs empty scene

**Environment Variables:**
```bash
WEBRTC_PORT=9000 ./launch_g1.sh webrtc
HF_REPO='user/model' ./launch_g1.sh webrtc
```

---

## Simulation Code

### `g1_sim_webrtc.py`
**Purpose:** Main simulation script with full features

**Features:**
- ✓ Loads Unitree G1 robot
- ✓ Implements WBC (Whole Body Control)
- ✓ Loads pretrained models from HuggingFace
- ✓ WebRTC video streaming
- ✓ Teleop control via keyboard
- ✓ Camera rendering

**Key Components:**

1. **UnitreeG1SceneCfg**
   - Scene configuration
   - Robot spawn settings
   - Actuator parameters
   - Camera setup

2. **PretrainedWBCPolicy**
   - Loads models from HuggingFace
   - Runs neural network inference
   - Falls back to default controller

3. **TeleopController**
   - Processes keyboard commands
   - Converts to velocity commands
   - Updates robot control

**Usage:**
```bash
# Via launch script (recommended)
./launch_g1.sh webrtc

# Direct execution
cd ~/g1_workspace/IsaacLab
./isaaclab.sh -p ~/rented/g1_sim_webrtc.py --headless --enable_webrtc
```

**Arguments:**
- `--hf_repo` - HuggingFace model repo
- `--device` - cuda or cpu
- `--enable_webrtc` - Enable streaming
- `--webrtc_host` - WebRTC server host
- `--webrtc_port` - WebRTC server port
- `--stream_every` - Stream every N frames

### `simple_g1_teleop.py`
**Purpose:** Simplified version without external dependencies

**Features:**
- ✓ Basic G1 loading
- ✓ Simple standing controller
- ✓ No WebRTC (easier to debug)
- ✓ Native Isaac Lab viewer

**Use Cases:**
- Quick testing
- Debugging robot issues
- Learning Isaac Lab basics
- Local development

**Usage:**
```bash
./launch_g1.sh simple
```

---

## WebRTC Components

### `webrtc_server.js`
**Purpose:** Node.js WebSocket server for video streaming

**What it does:**
- ✓ Serves web viewer page
- ✓ Manages WebSocket connections
- ✓ Routes video frames from simulation to viewers
- ✓ Routes control commands from viewers to simulation
- ✓ Handles multiple simultaneous viewers

**Architecture:**
```
Viewer 1 ←┐
Viewer 2 ←┼→ WebRTC Server ←→ Isaac Lab Simulation
Viewer 3 ←┘
```

**Endpoints:**
- `http://localhost:8080/` - Web viewer
- `ws://localhost:8080` - WebSocket connection

**Message Types:**
- `simulation` - Identify as simulation client
- `viewer` - Identify as viewer client
- `frame` - Video frame data (base64 JPEG)
- `control` - Control commands (keyboard, buttons)

### `webrtc_streamer.py`
**Purpose:** Python client for streaming from Isaac Lab

**Classes:**

1. **WebRTCStreamer** (async)
   - Connects to WebSocket server
   - Streams numpy arrays as JPEG
   - Receives control messages
   - Async/await interface

2. **SyncWebRTCStreamer** (sync wrapper)
   - Synchronous wrapper for Isaac Lab
   - Blocks during streaming
   - Easy integration with simulation loop

**Usage in Code:**
```python
from webrtc_streamer import SyncWebRTCStreamer

streamer = SyncWebRTCStreamer(host='localhost', port=8080)
streamer.connect()

# In simulation loop
streamer.stream_frame(camera_image)  # numpy array (H, W, 3)

# Check for controls
control = streamer.get_control()
if control:
    handle_control(control)

streamer.disconnect()
```

### `viewer.html`
**Purpose:** Web-based viewer interface

**Features:**
- ✓ Real-time video display
- ✓ Keyboard control input
- ✓ Button controls
- ✓ FPS counter
- ✓ Connection status
- ✓ Responsive design

**Controls:**
- W/A/S/D - Movement
- Q/E - Turning
- Arrow keys - Body orientation
- Space - Jump
- R - Reset
- P - Pause

**UI Elements:**
- Video canvas (main viewport)
- Control panel (right sidebar)
- Status indicator (connection state)
- FPS counter (performance monitor)

### `package.json`
**Purpose:** Node.js dependencies for WebRTC server

**Dependencies:**
- `express` - Web server framework
- `ws` - WebSocket library

**Scripts:**
```bash
npm install        # Install dependencies
npm start         # Start server
```

---

## Documentation

### `README.md`
**Purpose:** Complete project documentation

**Sections:**
- Features overview
- Quick start guide
- File structure
- WebRTC controls
- Advanced usage
- Troubleshooting
- Cost considerations
- Architecture diagram

**Audience:** All users

### `QUICKSTART.md`
**Purpose:** Step-by-step beginner guide

**Sections:**
- Prerequisites
- Setup steps with time estimates
- Verification checklist
- Common issues and fixes
- Cloud provider specific notes
- Cost estimates by provider
- Next steps roadmap

**Audience:** First-time users

### `FILES_OVERVIEW.md`
**Purpose:** This file - technical reference

**Sections:**
- Detailed file descriptions
- Code architecture
- API reference
- Usage examples

**Audience:** Developers and advanced users

---

## Configuration

### `config.env`
**Purpose:** Environment variable configuration

**Categories:**

1. **Workspace paths**
   - WORKSPACE_DIR
   - ISAACLAB_DIR
   - PROJECT_DIR

2. **WebRTC settings**
   - WEBRTC_PORT
   - WEBRTC_HOST

3. **Model settings**
   - HF_REPO
   - HF_TOKEN

4. **Simulation parameters**
   - DEVICE
   - SIM_DT
   - NUM_ENVS

5. **Camera settings**
   - CAMERA_WIDTH
   - CAMERA_HEIGHT
   - CAMERA_FPS

6. **Performance tuning**
   - STREAM_EVERY
   - JPEG_QUALITY

**Usage:**
```bash
# Edit values
nano config.env

# Source before launch
source config.env
./launch_g1.sh webrtc
```

---

## File Dependency Graph

```
setup_g1_cloud.sh
    ├─→ Installs system packages
    ├─→ Clones IsaacLab
    └─→ Sets up workspace structure

launch_g1.sh
    ├─→ webrtc_server.js (starts server)
    │   └─→ viewer.html (serves to browser)
    │
    └─→ g1_sim_webrtc.py (runs simulation)
        ├─→ webrtc_streamer.py (streams video)
        └─→ Uses IsaacLab (from setup)

config.env
    └─→ Sets environment for all scripts
```

---

## Quick Reference

### Essential Files (Must Have)
1. `setup_g1_cloud.sh` - Initial setup
2. `launch_g1.sh` - Run simulation
3. `g1_sim_webrtc.py` - Main simulation
4. `webrtc_server.js` - Video server
5. `viewer.html` - Web interface

### Supporting Files (Important)
6. `webrtc_streamer.py` - Streaming client
7. `package.json` - Node dependencies
8. `README.md` - Documentation

### Optional Files (Helpful)
9. `simple_g1_teleop.py` - Simple version
10. `QUICKSTART.md` - Beginner guide
11. `config.env` - Configuration
12. `FILES_OVERVIEW.md` - This file

---

## Execution Order

1. **First Time Setup:**
   ```bash
   ./setup_g1_cloud.sh    # One time only
   ```

2. **Every Time You Run:**
   ```bash
   ./launch_g1.sh webrtc  # Starts everything
   ```

3. **In Browser:**
   - Open `http://localhost:8080`
   - Use keyboard/buttons to control

4. **Shutdown:**
   - Ctrl+C in terminal
   - Closes simulation and server

---

## File Sizes (Approximate)

| File | Size | Type |
|------|------|------|
| setup_g1_cloud.sh | 6 KB | Bash |
| launch_g1.sh | 4 KB | Bash |
| g1_sim_webrtc.py | 12 KB | Python |
| simple_g1_teleop.py | 5 KB | Python |
| webrtc_streamer.py | 4 KB | Python |
| webrtc_server.js | 2 KB | JavaScript |
| viewer.html | 10 KB | HTML |
| package.json | 1 KB | JSON |
| README.md | 8 KB | Markdown |
| QUICKSTART.md | 6 KB | Markdown |
| config.env | 2 KB | Bash |
| FILES_OVERVIEW.md | 10 KB | Markdown |

**Total:** ~70 KB (scripts only)

**After Installation:**
- Isaac Lab: ~20 GB
- Dependencies: ~10 GB
- Models: ~1-5 GB
- Total: ~35 GB

---

## Support Files Created by Scripts

These are created automatically:

```
~/g1_workspace/
├── IsaacLab/                    (from setup script)
├── g1_project/                  (from setup script)
│   ├── g1_sim_webrtc.py        (copied by launch)
│   ├── simple_g1_teleop.py     (copied by launch)
│   └── webrtc_streamer.py      (copied by launch)
└── webrtc_server/               (from setup script)
    ├── node_modules/            (from npm install)
    ├── webrtc_server.js         (copied by launch)
    ├── package.json             (created by launch)
    └── public/
        └── viewer.html          (copied by launch)
```

---

## Customization Guide

### Want to Change Camera Position?
Edit: `g1_sim_webrtc.py` → `UnitreeG1SceneCfg` → `camera.offset`

### Want Different Robot?
Edit: `g1_sim_webrtc.py` → `UnitreeG1SceneCfg` → `robot.spawn.usd_path`

### Want More Robots?
Edit: `g1_sim_webrtc.py` → `UnitreeG1SceneCfg(num_envs=4)`

### Want Better Quality Stream?
Edit: `webrtc_streamer.py` → `encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 95]`

### Want Custom Controls?
Edit: `viewer.html` → Add keyboard bindings
Edit: `g1_sim_webrtc.py` → `TeleopController.update_from_keyboard()`

---

## Conclusion

All files work together to create a complete Isaac Lab + Unitree G1 system with remote visualization. The modular design allows you to:

- Use different components independently
- Customize any part easily
- Scale to multiple robots
- Add new features without breaking existing code

For questions about specific files, refer to the inline comments in each file.
