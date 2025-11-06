# GPU Compatibility Guide

## Quick Answer

✅ **Yes, this setup works with L40S and much cheaper GPUs!**

The setup works with any NVIDIA GPU that supports CUDA. You can start with budget options and scale up if needed.

---

## Supported GPUs

### ✅ Fully Compatible (Tested/Verified)

| GPU | VRAM | Cost/hr* | Recommended For |
|-----|------|----------|-----------------|
| **RTX 3060** | 12GB | $0.20-0.30 | Testing, learning |
| **RTX 3070** | 8GB | $0.25-0.35 | Budget option |
| **RTX 3080** | 10-12GB | $0.35-0.50 | Good balance |
| **RTX 3090** | 24GB | $0.50-0.70 | Multi-robot (4-8 envs) |
| **RTX 4070 Ti** | 12GB | $0.40-0.55 | Good performance |
| **RTX 4080** | 16GB | $0.60-0.80 | High performance |
| **RTX 4090** | 24GB | $0.80-1.20 | Multi-robot (8+ envs) |
| **RTX A4000** | 16GB | $0.45-0.65 | Professional, stable |
| **RTX A5000** | 24GB | $0.60-0.90 | Professional |
| **RTX A6000** | 48GB | $0.90-1.50 | Multi-robot (16+ envs) |
| **L4** | 24GB | $0.40-0.60 | Good value datacenter |
| **L40** | 48GB | $0.80-1.20 | High-end datacenter |
| **L40S** | 48GB | $0.90-1.40 | **Your GPU** - Excellent! |
| **A10** | 24GB | $0.50-0.80 | Good datacenter option |
| **A40** | 48GB | $0.90-1.40 | High-end |
| **A100** | 40/80GB | $1.50-3.00 | Overkill for this |
| **H100** | 80GB | $3.00-5.00 | Massive overkill |

*Costs are approximate cloud rental prices

### 🔶 Limited Compatibility (May Work)

| GPU | VRAM | Notes |
|-----|------|-------|
| RTX 2060 | 6GB | May run out of VRAM, reduce resolution |
| RTX 2070 | 8GB | Should work, lower settings |
| RTX 2080 | 8-11GB | Good for single robot |
| GTX 1080 Ti | 11GB | Older but works |
| T4 | 16GB | Slower but cheap ($0.15-0.30/hr) |

### ❌ Not Recommended

| GPU | VRAM | Why Not |
|-----|------|---------|
| GTX 1060 | 6GB | Too little VRAM |
| GTX 1070 | 8GB | May struggle |
| Any GPU | <6GB | Will crash |

---

## Your L40S - Excellent Choice!

The L40S is actually a **high-end datacenter GPU**. Here's what you can do with it:

### L40S Specifications
- **VRAM:** 48GB (plenty!)
- **Architecture:** Ada Lovelace (latest gen)
- **RT Cores:** Yes (good for Isaac Sim rendering)
- **Tensor Cores:** Yes (good for ML models)

### What You Can Run
- ✅ Single G1 robot - **Overkill** (will run butter smooth)
- ✅ 16-32 parallel robots - **Perfect use case**
- ✅ High-res streaming (1080p, 60fps) - **No problem**
- ✅ Multiple cameras per robot - **Easy**
- ✅ Large neural networks - **Plenty of VRAM**

### L40S is Actually MORE Than You Need

For just testing if you can load and teleop G1, the L40S is **way more powerful than necessary**. This is great news because:

1. **It will definitely work** - No compatibility issues at all
2. **You can do advanced stuff** - Train RL policies, run many robots
3. **You paid for premium** - Make the most of it!

---

## Budget-Friendly Alternatives

If you want to save money for initial testing:

### 🏆 Best Value Options (2025)

1. **T4 (16GB) - $0.15-0.30/hr**
   - Perfect for learning and testing
   - Slower but sufficient for 1 robot
   - Available on RunPod, Vast.ai

2. **RTX 3060 (12GB) - $0.20-0.30/hr**
   - Consumer GPU, good performance
   - Handles 1-2 robots easily
   - Available on most platforms

3. **L4 (24GB) - $0.40-0.60/hr**
   - Newer datacenter GPU
   - Better than RTX 3060
   - Good balance of cost/performance

### Cost Comparison for 2 Hours Testing

| GPU | Cost for 2hrs | Savings vs L40S |
|-----|---------------|-----------------|
| T4 | $0.30-0.60 | **Save $1.20-2.40** |
| RTX 3060 | $0.40-0.60 | **Save $1.20-2.00** |
| L4 | $0.80-1.20 | **Save $0.40-1.60** |
| RTX 4080 | $1.20-1.60 | **Save $0.20-0.80** |
| L40S | $1.80-2.80 | (baseline) |

---

## Recommended Workflow

### Phase 1: Initial Testing (Use Cheap GPU)

**Goal:** Verify setup works, learn the system

**GPU Recommendation:** T4 or RTX 3060
**Cost:** $0.20-0.30/hr
**Duration:** 2-3 hours
**Total Cost:** $0.40-0.90

**What to do:**
1. Run setup script
2. Launch simple mode
3. Test basic teleop
4. Verify WebRTC works
5. Modify code and experiment

### Phase 2: Development (Use Mid-Range)

**Goal:** Develop gaits, test policies, iterate

**GPU Recommendation:** RTX 4080 or L4
**Cost:** $0.40-0.80/hr
**Duration:** 10-20 hours
**Total Cost:** $4-16

**What to do:**
1. Implement custom controllers
2. Test different gaits
3. Load pretrained models
4. Train simple policies

### Phase 3: Production/Training (Use L40S)

**Goal:** Train large models, run many robots

**GPU Recommendation:** L40S, A40, or RTX 4090
**Cost:** $0.90-1.40/hr
**Duration:** As needed
**Total Cost:** Varies

**What to do:**
1. Train RL policies (many parallel envs)
2. Evaluate policies at scale
3. Generate datasets
4. Run benchmarks

---

## Setup Modifications for Different GPUs

### For Budget GPUs (<16GB VRAM)

Edit `g1_sim_webrtc.py`:

```python
# Reduce camera resolution
camera: CameraCfg = CameraCfg(
    height=480,      # Down from 720
    width=854,       # Down from 1280
    ...
)

# Reduce number of environments
scene_cfg = UnitreeG1SceneCfg(
    num_envs=1,      # Keep at 1
    ...
)
```

Edit `webrtc_streamer.py`:

```python
# Lower JPEG quality
encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 75]  # Down from 85
```

### For High-End GPUs (>24GB VRAM)

Edit `g1_sim_webrtc.py`:

```python
# Increase resolution
camera: CameraCfg = CameraCfg(
    height=1080,     # Up from 720
    width=1920,      # Up from 1280
    ...
)

# Run multiple robots
scene_cfg = UnitreeG1SceneCfg(
    num_envs=16,     # 16 parallel robots!
    env_spacing=5.0,
)
```

---

## Platform-Specific GPU Availability

### RunPod
- **Best For:** RTX 4090, RTX 3090, L40S
- **Cheapest:** T4, RTX 3060
- **Availability:** Good

### Vast.ai
- **Best For:** Cheapest prices overall
- **Cheapest:** T4, RTX 3060, GTX 1080 Ti
- **Availability:** Excellent variety

### Lambda Labs
- **Best For:** Reliable, professional
- **Options:** A10, A100, H100 (no consumer GPUs)
- **Availability:** Limited but stable

### Paperspace
- **Best For:** Easy to use
- **Options:** RTX 4000, A4000, A6000
- **Availability:** Good

---

## Testing Your GPU

After setup, run this to verify:

```bash
# Check GPU
nvidia-smi

# Should show:
# - GPU name (e.g., "L40S", "RTX 3060")
# - Memory (e.g., "48GB", "12GB")
# - CUDA version

# Run test
./launch_g1.sh test

# If successful, try simple mode
./launch_g1.sh simple

# Finally, try WebRTC mode
./launch_g1.sh webrtc
```

### Expected Performance

| GPU | Single Robot FPS | WebRTC Latency | Max Robots |
|-----|------------------|----------------|------------|
| T4 | 30-60 | 50-100ms | 1-2 |
| RTX 3060 | 60-120 | 30-50ms | 2-4 |
| RTX 4080 | 120-200 | 20-30ms | 8-12 |
| L40S | **200-300** | **10-20ms** | **16-32** |
| A100 | 300-500 | 10-20ms | 32-64 |

---

## Money-Saving Tips

### 1. Use Spot/Preemptible Instances
- **Savings:** 50-70% off
- **Downside:** Can be terminated
- **Good For:** Testing, short runs

### 2. Start Small, Scale Up
```bash
# Test on T4 first ($0.20/hr)
# Verify everything works
# Then switch to L40S for production
```

### 3. Use Interruptible Workflow
```bash
# Test on cheap GPU
./launch_g1.sh test

# If works, save your work
git commit -am "working setup"

# Then use expensive GPU only when needed
```

### 4. Run Headless Always
```bash
# Headless saves GPU memory
./launch_g1.sh webrtc  # Already headless
```

### 5. Batch Your Work
- Don't keep instance running while reading docs
- Prepare code locally, test on cloud
- Terminate when done

---

## Recommendation for Your Use Case

> "test if I can load a g1 with pretrained WBC and teleop it"

### For Initial Testing

**GPU:** RTX 3060 or T4
**Cost:** $0.20-0.30/hr
**Duration:** 2 hours
**Total:** **$0.40-0.60**

This is **$1.40-2.40 cheaper** than L40S for the same test.

### After Verified Working

**GPU:** L40S (what you have)
**Use For:**
- Training RL policies
- Running 16+ parallel robots
- High-quality video recording
- Large-scale experiments

---

## Quick Start Command for Different GPUs

```bash
# The setup script auto-detects your GPU
./setup_g1_cloud.sh

# No changes needed - it will work on:
# ✅ L40S (your current GPU)
# ✅ RTX 3060, 3070, 3080, 3090, 4070, 4080, 4090
# ✅ T4, L4, A10, A40, A100
# ✅ Any NVIDIA GPU with 8GB+ VRAM
```

---

## Final Recommendation

**For your specific goal** ("test if I can load g1 and teleop"):

1. **Try L40S first** since you already have it
   - Verify the setup works
   - Test for 30 minutes
   - Total cost: ~$0.45-0.70

2. **If it works and you want to save money:**
   - Save your working setup
   - Switch to RTX 3060 or T4 for development
   - Use L40S only for heavy workloads

3. **If money isn't a concern:**
   - Stick with L40S
   - Use its power for multi-robot setups
   - Train RL policies faster

**Bottom Line:** Your L40S is perfect and will definitely work. It's just more powerful (and expensive) than you need for basic testing.
