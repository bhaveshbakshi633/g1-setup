#!/usr/bin/env python3
"""
Unitree G1 Humanoid Robot Simulation with Pretrained WBC and WebRTC Streaming

This script:
1. Loads Unitree G1 robot in Isaac Lab
2. Loads pretrained whole-body control (WBC) policy from HuggingFace
3. Implements teleop controls
4. Streams visualization via WebRTC
"""

import argparse
import asyncio
import numpy as np
import torch
from datetime import datetime

# Isaac Lab imports
import omni.isaac.lab.sim as sim_utils
from omni.isaac.lab.actuators import ImplicitActuatorCfg
from omni.isaac.lab.assets import ArticulationCfg, Articulation
from omni.isaac.lab.scene import InteractiveScene, InteractiveSceneCfg
from omni.isaac.lab.sim import SimulationContext
from omni.isaac.lab.utils import configclass
from omni.isaac.lab.sensors import CameraCfg, Camera

# HuggingFace imports
from huggingface_hub import hf_hub_download
import sys
import os


@configclass
class UnitreeG1SceneCfg(InteractiveSceneCfg):
    """Configuration for Unitree G1 scene"""

    # Ground plane
    ground = sim_utils.GroundPlaneCfg()

    # Dome light
    dome_light = sim_utils.DomeLightCfg(
        intensity=3000.0,
        color=(0.9, 0.9, 0.9)
    )

    # Unitree G1 robot
    robot: ArticulationCfg = ArticulationCfg(
        prim_path="{ENV_REGEX_NS}/Robot",
        spawn=sim_utils.UsdFileCfg(
            # This will use built-in Unitree G1 asset if available
            # Otherwise, you'll need to provide the path
            usd_path=f"{os.environ.get('ISAACLAB_DIR', '')}/source/extensions/omni.isaac.lab_assets/data/Robots/Unitree/G1/g1.usd",
            rigid_props=sim_utils.RigidBodyPropertiesCfg(
                disable_gravity=False,
                max_depenetration_velocity=10.0,
            ),
            articulation_props=sim_utils.ArticulationRootPropertiesCfg(
                enabled_self_collisions=True,
                solver_position_iteration_count=4,
                solver_velocity_iteration_count=0,
            ),
        ),
        init_state=ArticulationCfg.InitialStateCfg(
            pos=(0.0, 0.0, 1.0),
            joint_pos={
                # Initial standing pose
                ".*_hip_yaw": 0.0,
                ".*_hip_roll": 0.0,
                ".*_hip_pitch": -0.3,
                ".*_knee": 0.6,
                ".*_ankle_pitch": -0.3,
                ".*_ankle_roll": 0.0,
                # Arms
                ".*_shoulder_pitch": 0.3,
                ".*_shoulder_roll": 0.0,
                ".*_shoulder_yaw": 0.0,
                ".*_elbow": -0.5,
            },
        ),
        actuators={
            "legs": ImplicitActuatorCfg(
                joint_names_expr=[".*_hip_.*", ".*_knee", ".*_ankle_.*"],
                stiffness={
                    ".*_hip_yaw": 150.0,
                    ".*_hip_roll": 150.0,
                    ".*_hip_pitch": 200.0,
                    ".*_knee": 200.0,
                    ".*_ankle_.*": 40.0,
                },
                damping={
                    ".*_hip_.*": 5.0,
                    ".*_knee": 5.0,
                    ".*_ankle_.*": 2.0,
                },
            ),
            "arms": ImplicitActuatorCfg(
                joint_names_expr=[".*_shoulder_.*", ".*_elbow", ".*_wrist_.*"],
                stiffness=40.0,
                damping=10.0,
            ),
        },
    )

    # Camera for visualization
    camera: CameraCfg = CameraCfg(
        prim_path="{ENV_REGEX_NS}/Camera",
        update_period=0.033,  # 30 FPS
        height=720,
        width=1280,
        data_types=["rgb"],
        spawn=sim_utils.PinholeCameraCfg(
            focal_length=24.0,
            focus_distance=400.0,
            horizontal_aperture=20.955,
            clipping_range=(0.1, 1000.0),
        ),
        offset=CameraCfg.OffsetCfg(
            pos=(5.0, 5.0, 3.0),
            rot=(0.9238, 0.0, 0.0, -0.3827),  # Looking at origin
            convention="world"
        ),
    )


class PretrainedWBCPolicy:
    """Wrapper for pretrained whole-body control policy"""

    def __init__(self, model_name="unitree-g1-wbc", device="cuda"):
        self.device = device
        self.model = None
        self.model_name = model_name
        self.loaded = False

    def load_from_huggingface(self, repo_id="unitreerobotics/g1-wbc-model"):
        """
        Load pretrained model from HuggingFace Hub

        Args:
            repo_id: HuggingFace repository ID
        """
        try:
            print(f"Loading pretrained WBC model from {repo_id}...")

            # Try to download the model
            # Note: Adjust the filename based on actual HuggingFace repo
            model_path = hf_hub_download(
                repo_id=repo_id,
                filename="policy.pt",
                cache_dir="./models"
            )

            # Load the model
            checkpoint = torch.load(model_path, map_location=self.device)

            # Extract model state
            if isinstance(checkpoint, dict):
                if 'model_state_dict' in checkpoint:
                    self.model = checkpoint['model_state_dict']
                elif 'policy' in checkpoint:
                    self.model = checkpoint['policy']
                else:
                    self.model = checkpoint
            else:
                self.model = checkpoint

            self.loaded = True
            print("✓ Pretrained WBC model loaded successfully!")

        except Exception as e:
            print(f"Warning: Could not load pretrained model from HuggingFace: {e}")
            print("Falling back to default controller...")
            self.loaded = False

    def compute_action(self, obs):
        """
        Compute action from observation

        Args:
            obs: Robot observation (joint positions, velocities, etc.)

        Returns:
            action: Joint torques or position targets
        """
        if not self.loaded:
            # Default standing controller
            return self._default_controller(obs)

        # Run the neural network policy
        with torch.no_grad():
            obs_tensor = torch.FloatTensor(obs).to(self.device).unsqueeze(0)
            action = self.model(obs_tensor)
            return action.cpu().numpy().squeeze()

    def _default_controller(self, obs):
        """Simple PD controller for standing"""
        # This is a placeholder - implement basic standing balance
        num_joints = len(obs) // 2  # Assuming obs is [pos, vel]
        return np.zeros(num_joints)


class TeleopController:
    """Keyboard-based teleoperation controller"""

    def __init__(self):
        self.commands = {
            'linear_x': 0.0,
            'linear_y': 0.0,
            'angular_z': 0.0,
            'body_height': 0.0,
        }
        self.speed_scale = 0.5

    def update_from_keyboard(self, key_command):
        """Update velocities from keyboard input"""

        # Reset commands
        self.commands = {k: 0.0 for k in self.commands}

        if key_command == 'forward':
            self.commands['linear_x'] = self.speed_scale
        elif key_command == 'backward':
            self.commands['linear_x'] = -self.speed_scale
        elif key_command == 'left':
            self.commands['linear_y'] = self.speed_scale
        elif key_command == 'right':
            self.commands['linear_y'] = -self.speed_scale
        elif key_command == 'turn_left':
            self.commands['angular_z'] = self.speed_scale
        elif key_command == 'turn_right':
            self.commands['angular_z'] = -self.speed_scale

    def get_command_velocity(self):
        """Get current command velocity"""
        return (
            self.commands['linear_x'],
            self.commands['linear_y'],
            self.commands['angular_z']
        )


def run_simulation(args):
    """Main simulation loop"""

    # Import WebRTC streamer
    sys.path.append(os.path.dirname(__file__))
    from webrtc_streamer import SyncWebRTCStreamer

    # Create simulation context
    sim_cfg = sim_utils.SimulationCfg(dt=0.01)
    sim = SimulationContext(sim_cfg)

    # Create scene
    scene_cfg = UnitreeG1SceneCfg(num_envs=1, env_spacing=5.0)
    scene = InteractiveScene(scene_cfg)

    # Print robot info
    robot: Articulation = scene["robot"]
    print("\n" + "=" * 80)
    print("Unitree G1 Robot Information")
    print("=" * 80)
    print(f"Number of joints: {robot.num_joints}")
    print(f"Joint names: {robot.joint_names}")
    print(f"Number of bodies: {robot.num_bodies}")
    print("=" * 80 + "\n")

    # Load pretrained WBC policy
    policy = PretrainedWBCPolicy(device=args.device)

    if args.hf_repo:
        policy.load_from_huggingface(args.hf_repo)
    else:
        print("No HuggingFace repo specified, using default controller")

    # Initialize teleop controller
    teleop = TeleopController()

    # Initialize WebRTC streamer
    streamer = None
    if args.enable_webrtc:
        print(f"Connecting to WebRTC server at {args.webrtc_host}:{args.webrtc_port}...")
        streamer = SyncWebRTCStreamer(host=args.webrtc_host, port=args.webrtc_port)
        if streamer.connect():
            print("✓ WebRTC streaming enabled!")
        else:
            print("✗ Failed to connect to WebRTC server")
            streamer = None

    # Get camera
    camera: Camera = scene["camera"]

    # Simulation loop
    sim_time = 0.0
    count = 0
    paused = False

    print("\nStarting simulation...")
    print("Commands will be received via WebRTC viewer")

    sim.reset()

    while sim.is_playing():
        # Process WebRTC controls
        if streamer:
            control = streamer.get_control()
            if control:
                action = control.get('action')
                if action == 'reset':
                    print("Resetting simulation...")
                    scene.reset()
                    sim_time = 0.0
                    count = 0
                elif action == 'pause':
                    paused = not paused
                    print(f"Simulation {'paused' if paused else 'resumed'}")
                elif action == 'stand':
                    print("Standing up...")
                    # Reset to standing pose
                    scene.reset()
                elif action == 'keyboard':
                    key_cmd = control.get('data', {}).get('key')
                    if key_cmd:
                        teleop.update_from_keyboard(key_cmd)

        if not paused:
            # Get robot state
            joint_pos = robot.data.joint_pos.cpu().numpy()[0]
            joint_vel = robot.data.joint_vel.cpu().numpy()[0]

            # Combine observation
            obs = np.concatenate([joint_pos, joint_vel])

            # Get teleop commands
            lin_x, lin_y, ang_z = teleop.get_command_velocity()

            # Compute actions from policy
            # Note: You'll need to incorporate teleop commands into the policy
            action = policy.compute_action(obs)

            # Apply actions
            if action is not None:
                robot.set_joint_effort_target(torch.from_numpy(action).to(args.device))

            # Step simulation
            scene.write_data_to_sim()
            sim.step()
            scene.update(sim.dt)

            sim_time += sim.dt
            count += 1

        # Stream camera feed via WebRTC
        if streamer and count % args.stream_every == 0:
            # Get camera image
            camera.update(sim.dt)
            rgb_data = camera.data.output["rgb"][0].cpu().numpy()

            # Convert from (H, W, C) and ensure uint8
            if rgb_data.dtype == np.float32:
                rgb_data = (rgb_data * 255).astype(np.uint8)

            # Stream frame
            streamer.stream_frame(rgb_data)

        # Print status
        if count % 100 == 0:
            print(f"Sim time: {sim_time:.2f}s | Steps: {count}", end='\r')

    # Cleanup
    if streamer:
        streamer.disconnect()

    print("\nSimulation ended.")


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description="Unitree G1 with Pretrained WBC and WebRTC")
    parser.add_argument("--hf_repo", type=str, default=None,
                        help="HuggingFace repo ID for pretrained model (e.g., 'unitreerobotics/g1-wbc')")
    parser.add_argument("--device", type=str, default="cuda",
                        help="Device to run on (cuda/cpu)")
    parser.add_argument("--enable_webrtc", action="store_true", default=True,
                        help="Enable WebRTC streaming")
    parser.add_argument("--webrtc_host", type=str, default="localhost",
                        help="WebRTC server host")
    parser.add_argument("--webrtc_port", type=int, default=8080,
                        help="WebRTC server port")
    parser.add_argument("--stream_every", type=int, default=2,
                        help="Stream every N frames")

    args = parser.parse_args()

    # Check device
    if args.device == "cuda" and not torch.cuda.is_available():
        print("CUDA not available, falling back to CPU")
        args.device = "cpu"

    print("\n" + "=" * 80)
    print("Unitree G1 Simulation with Pretrained WBC")
    print("=" * 80)
    print(f"Device: {args.device}")
    print(f"WebRTC: {'Enabled' if args.enable_webrtc else 'Disabled'}")
    if args.hf_repo:
        print(f"Loading model from: {args.hf_repo}")
    print("=" * 80 + "\n")

    # Run simulation
    run_simulation(args)


if __name__ == "__main__":
    main()
