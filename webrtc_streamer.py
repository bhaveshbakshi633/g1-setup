"""
WebRTC Streamer for Isaac Lab
Captures viewport and streams to web clients
"""

import asyncio
import websockets
import json
import base64
import cv2
import numpy as np
from datetime import datetime
import sys


class WebRTCStreamer:
    def __init__(self, host='0.0.0.0', port=8080):
        self.host = host
        self.port = port
        self.ws = None
        self.connected = False
        self.control_queue = asyncio.Queue()

    async def connect(self):
        """Connect to WebSocket server"""
        uri = f"ws://{self.host}:{self.port}"
        print(f"Connecting to WebRTC server at {uri}...")

        try:
            self.ws = await websockets.connect(uri)
            # Identify as simulation client
            await self.ws.send(json.dumps({"type": "simulation"}))
            self.connected = True
            print("Connected to WebRTC server!")

            # Start listening for control messages
            asyncio.create_task(self._listen_for_controls())

        except Exception as e:
            print(f"Failed to connect: {e}")
            self.connected = False

    async def _listen_for_controls(self):
        """Listen for control messages from viewers"""
        try:
            async for message in self.ws:
                data = json.loads(message)
                if data.get('type') == 'control':
                    await self.control_queue.put(data)
        except Exception as e:
            print(f"Control listener error: {e}")
            self.connected = False

    async def stream_frame(self, frame):
        """
        Stream a frame to viewers

        Args:
            frame: numpy array (H, W, 3) or (H, W, 4) in RGB/RGBA format
        """
        if not self.connected or self.ws is None:
            return

        try:
            # Convert RGBA to RGB if needed
            if frame.shape[2] == 4:
                frame = cv2.cvtColor(frame, cv2.COLOR_RGBA2RGB)

            # Encode as JPEG
            encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 85]
            _, buffer = cv2.imencode('.jpg', cv2.cvtColor(frame, cv2.COLOR_RGB2BGR), encode_param)

            # Convert to base64
            frame_base64 = base64.b64encode(buffer).decode('utf-8')

            # Send frame
            await self.ws.send(json.dumps({
                "type": "frame",
                "frame": frame_base64,
                "timestamp": datetime.now().isoformat()
            }))

        except Exception as e:
            print(f"Error streaming frame: {e}")
            self.connected = False

    def get_control(self):
        """
        Get next control message (non-blocking)
        Returns None if no control message available
        """
        try:
            return self.control_queue.get_nowait()
        except asyncio.QueueEmpty:
            return None

    async def disconnect(self):
        """Disconnect from server"""
        if self.ws:
            await self.ws.close()
            self.connected = False
            print("Disconnected from WebRTC server")


# Synchronous wrapper for use in Isaac Lab
class SyncWebRTCStreamer:
    def __init__(self, host='localhost', port=8080):
        self.streamer = WebRTCStreamer(host, port)
        self.loop = None
        self.connected = False

    def connect(self):
        """Connect to WebRTC server"""
        try:
            self.loop = asyncio.new_event_loop()
            self.loop.run_until_complete(self.streamer.connect())
            self.connected = self.streamer.connected
            return self.connected
        except Exception as e:
            print(f"Connection error: {e}")
            return False

    def stream_frame(self, frame):
        """Stream a frame (synchronous)"""
        if not self.connected:
            return

        try:
            if self.loop is None:
                self.loop = asyncio.new_event_loop()
            self.loop.run_until_complete(self.streamer.stream_frame(frame))
        except Exception as e:
            print(f"Streaming error: {e}")
            self.connected = False

    def get_control(self):
        """Get control message (synchronous)"""
        return self.streamer.get_control()

    def disconnect(self):
        """Disconnect from server"""
        if self.loop and self.connected:
            self.loop.run_until_complete(self.streamer.disconnect())
            self.loop.close()
            self.connected = False


if __name__ == "__main__":
    # Test the streamer with a dummy video
    import time

    async def test():
        streamer = WebRTCStreamer()
        await streamer.connect()

        print("Streaming test pattern...")
        for i in range(1000):
            # Create test frame
            frame = np.random.randint(0, 255, (480, 640, 3), dtype=np.uint8)

            # Add text
            cv2.putText(frame, f"Frame {i}", (50, 50),
                       cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)

            await streamer.stream_frame(frame)

            # Check for controls
            control = streamer.get_control()
            if control:
                print(f"Received control: {control}")

            await asyncio.sleep(1/30)  # 30 FPS

        await streamer.disconnect()

    asyncio.run(test())
