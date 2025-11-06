#!/bin/bash
# Quick check for Isaac Sim WebRTC streaming status

echo "=========================================="
echo "Isaac Sim WebRTC Streaming Status"
echo "=========================================="
echo ""

# Check if G1 simulation is running
G1_PID=$(ps aux | grep "python.*g1_simple_test.*livestream" | grep -v grep | awk '{print $2}' | head -1)

if [ -z "$G1_PID" ]; then
    echo "❌ G1 simulation is NOT running"
    echo ""
    echo "Start it with:"
    echo "  cd ~/rented && ./launch_native_streaming.sh g1_simple_test.py"
    exit 1
fi

echo "✅ G1 simulation is RUNNING (PID: $G1_PID)"
echo ""

# Check open ports
echo "Checking streaming ports..."
echo ""

PORT_8211=$(lsof -i :8211 2>/dev/null | grep LISTEN)
PORT_8011=$(lsof -i :8011 2>/dev/null | grep LISTEN)

if [ ! -z "$PORT_8211" ]; then
    echo "✅ Port 8211 is OPEN (WebRTC standard port)"
else
    echo "⚠️  Port 8211 is not listening"
fi

if [ ! -z "$PORT_8011" ]; then
    echo "✅ Port 8011 is OPEN (HTTP streaming port)"
else
    echo "⚠️  Port 8011 is not listening"
fi

echo ""
echo "=========================================="
echo "CONNECTION INSTRUCTIONS"
echo "=========================================="
echo ""
echo "1. Open Isaac Sim WebRTC Streaming Client on your local machine"
echo ""
echo "2. Try BOTH connection addresses:"
echo "   → localhost:8211"
echo "   → localhost:8011"
echo ""
echo "3. If connecting from remote machine via SSH, create tunnel first:"
echo "   ssh -L 8211:localhost:8211 -L 8011:localhost:8011 bhavesh@$(hostname -I | awk '{print $1}')"
echo ""
echo "=========================================="
echo ""

# Show recent simulation output
echo "Recent simulation output:"
echo ""
tail -5 /tmp/g1_unbuffered.log 2>/dev/null || tail -5 /tmp/g1_infinite.log 2>/dev/null || echo "(No log found)"
echo ""
