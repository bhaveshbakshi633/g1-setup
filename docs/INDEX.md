# File Index - Quick Reference

## 🚀 Start Here

1. **First, read:** [START_HERE.md](START_HERE.md)
2. **Then run:** `./check_system.sh`
3. **If ready, run:** `./setup_g1_cloud.sh`
4. **Finally, launch:** `./launch_g1.sh webrtc`

---

## 📁 All Files

```
/home/bhavesh/rented/
│
├── 🚀 GETTING STARTED
│   ├── START_HERE.md          ⭐ Read this first!
│   ├── QUICKSTART.md          📖 Step-by-step guide
│   ├── check_system.sh        🔍 Check if your system is ready
│   └── setup_g1_cloud.sh      ⚙️  Setup everything (run once)
│
├── 🎮 RUNNING THE SIMULATION
│   ├── launch_g1.sh           🚀 Launch script (main entry point)
│   ├── g1_sim_webrtc.py       🤖 Full simulation with WebRTC
│   └── simple_g1_teleop.py    🎯 Simple version (no WebRTC)
│
├── 🌐 WEBRTC COMPONENTS
│   ├── webrtc_server.js       📡 WebSocket server
│   ├── webrtc_streamer.py     📹 Python streaming client
│   ├── viewer.html            🖥️  Web viewer interface
│   └── package.json           📦 Node.js dependencies
│
├── ⚙️ CONFIGURATION
│   └── config.env             🔧 Environment variables
│
└── 📚 DOCUMENTATION
    ├── README.md              📖 Complete documentation
    ├── GPU_COMPATIBILITY.md   💻 GPU options & costs
    ├── FILES_OVERVIEW.md      📋 Technical reference
    └── INDEX.md               📑 This file
```

---

## 📝 File Descriptions

### Getting Started Files

| File | Purpose | When to Use |
|------|---------|-------------|
| **START_HERE.md** | Quick start guide | Read first |
| **QUICKSTART.md** | Detailed step-by-step | For beginners |
| **check_system.sh** | Verify system requirements | Before setup |
| **setup_g1_cloud.sh** | Install everything | Once, at start |

### Running Files

| File | Purpose | When to Use |
|------|---------|-------------|
| **launch_g1.sh** | Launch simulation | Every time you run |
| **g1_sim_webrtc.py** | Main simulation | Auto-launched |
| **simple_g1_teleop.py** | Basic simulation | For testing |

### WebRTC Files

| File | Purpose | When to Use |
|------|---------|-------------|
| **webrtc_server.js** | Streaming server | Auto-launched |
| **webrtc_streamer.py** | Python client | Auto-used |
| **viewer.html** | Web interface | Auto-served |
| **package.json** | Node deps | Auto-installed |

### Documentation Files

| File | Purpose | When to Read |
|------|---------|-------------|
| **README.md** | Full reference | For details |
| **GPU_COMPATIBILITY.md** | GPU info | Before renting GPU |
| **FILES_OVERVIEW.md** | Technical docs | For developers |
| **INDEX.md** | This file | For navigation |

### Configuration Files

| File | Purpose | When to Edit |
|------|---------|-------------|
| **config.env** | Settings | To customize |

---

## 🎯 Usage Scenarios

### Scenario 1: First Time Setup
```bash
1. Read START_HERE.md
2. Run ./check_system.sh
3. Run ./setup_g1_cloud.sh (wait 30-60 min)
4. Run ./launch_g1.sh webrtc
```

### Scenario 2: Daily Usage
```bash
1. Run ./launch_g1.sh webrtc
2. Open browser to http://localhost:8080
3. Control robot, experiment, develop
4. Ctrl+C to stop
```

### Scenario 3: Debugging
```bash
1. Run ./check_system.sh (verify system)
2. Run ./launch_g1.sh test (test Isaac Lab)
3. Run ./launch_g1.sh simple (test without WebRTC)
4. Run ./launch_g1.sh webrtc (test full setup)
```

### Scenario 4: Using HuggingFace Model
```bash
HF_REPO='username/model-name' ./launch_g1.sh webrtc
```

### Scenario 5: Customization
```bash
1. Edit config.env (set your preferences)
2. Source config.env
3. Run ./launch_g1.sh webrtc
```

---

## 🔄 File Dependencies

```
check_system.sh (independent)
    ↓
setup_g1_cloud.sh
    ├── Creates ~/g1_workspace/
    ├── Installs IsaacLab
    └── Sets up WebRTC server
    ↓
launch_g1.sh
    ├── webrtc_server.js
    │   └── viewer.html
    └── g1_sim_webrtc.py
        └── webrtc_streamer.py

config.env (optional, used by all scripts)
```

---

## 📏 File Sizes

| File | Size | Type |
|------|------|------|
| check_system.sh | 5 KB | Bash |
| setup_g1_cloud.sh | 6 KB | Bash |
| launch_g1.sh | 4 KB | Bash |
| g1_sim_webrtc.py | 12 KB | Python |
| simple_g1_teleop.py | 5 KB | Python |
| webrtc_server.js | 2 KB | JavaScript |
| webrtc_streamer.py | 4 KB | Python |
| viewer.html | 10 KB | HTML |
| package.json | 1 KB | JSON |
| config.env | 2 KB | Bash |
| START_HERE.md | 8 KB | Markdown |
| QUICKSTART.md | 6 KB | Markdown |
| README.md | 8 KB | Markdown |
| GPU_COMPATIBILITY.md | 12 KB | Markdown |
| FILES_OVERVIEW.md | 10 KB | Markdown |
| INDEX.md | 3 KB | Markdown |

**Total:** ~98 KB (tiny!)

---

## 🎓 Learning Order

### Beginner
1. ✅ START_HERE.md
2. ✅ Run check_system.sh
3. ✅ Run setup_g1_cloud.sh
4. ✅ QUICKSTART.md
5. ✅ Run launch_g1.sh

### Intermediate
1. ✅ GPU_COMPATIBILITY.md (understand costs)
2. ✅ config.env (customize settings)
3. ✅ Edit g1_sim_webrtc.py (change parameters)
4. ✅ README.md (advanced features)

### Advanced
1. ✅ FILES_OVERVIEW.md (architecture)
2. ✅ Modify webrtc_streamer.py
3. ✅ Create custom gaits
4. ✅ Train RL policies

---

## 🔍 Finding Information

### "How do I start?"
→ **START_HERE.md**

### "What GPU should I use?"
→ **GPU_COMPATIBILITY.md**

### "Step-by-step instructions?"
→ **QUICKSTART.md**

### "What does each file do?"
→ **FILES_OVERVIEW.md** (or this file)

### "How do I customize?"
→ **config.env** + **README.md**

### "Something's broken!"
→ **check_system.sh** + **QUICKSTART.md** (Troubleshooting)

---

## ⚡ Quick Commands

```bash
# Check system
./check_system.sh

# Setup (once)
./setup_g1_cloud.sh

# Launch
./launch_g1.sh webrtc

# Test
./launch_g1.sh test

# Simple mode
./launch_g1.sh simple

# With HuggingFace
HF_REPO='user/model' ./launch_g1.sh webrtc

# Custom port
WEBRTC_PORT=9000 ./launch_g1.sh webrtc

# Check GPU
nvidia-smi
```

---

## 📊 File Importance

### Must Read
- ⭐⭐⭐ START_HERE.md
- ⭐⭐⭐ QUICKSTART.md

### Should Read
- ⭐⭐ GPU_COMPATIBILITY.md
- ⭐⭐ README.md

### Reference
- ⭐ FILES_OVERVIEW.md
- ⭐ INDEX.md (this file)

### Configuration
- config.env (edit as needed)

### Run
- check_system.sh (before setup)
- setup_g1_cloud.sh (once)
- launch_g1.sh (every time)

---

## 🎯 Next Step

**Run this command:**
```bash
./check_system.sh
```

This will verify your L40S GPU and system requirements before you start the full setup.

Good luck! 🚀
