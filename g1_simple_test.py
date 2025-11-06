#!/usr/bin/env python3
"""
Simple Unitree G1 Test - Verify G1 loads correctly
Minimal version to test if everything works
"""

import argparse

# Isaac Lab imports
import isaaclab.sim as sim_utils
from isaaclab.assets import Articulation
from isaaclab.scene import InteractiveScene, InteractiveSceneCfg
from isaaclab.sim import SimulationContext, SimulationCfg
from isaaclab.utils import configclass

# Import Unitree G1 configuration
from isaaclab_assets.robots import G1_CFG


@configclass
class G1TestSceneCfg(InteractiveSceneCfg):
    """Simple test scene configuration"""

    # Ground plane
    ground = sim_utils.GroundPlaneCfg()

    # Dome light
    dome_light = sim_utils.DomeLightCfg(intensity=3000.0)

    # Unitree G1 robot (using built-in config)
    robot = G1_CFG.replace(prim_path="{ENV_REGEX_NS}/Robot")


def main():
    parser = argparse.ArgumentParser(description="Simple G1 Test")
    parser.add_argument("--num_envs", type=int, default=1, help="Number of environments")
    args = parser.parse_args()

    # Create simulation
    sim_cfg = SimulationCfg(dt=0.01, device="cuda:0")
    sim = SimulationContext(sim_cfg)
    sim.set_camera_view(eye=[3.5, 3.5, 2.5], target=[0.0, 0.0, 0.5])

    # Create scene
    scene_cfg = G1TestSceneCfg(num_envs=args.num_envs, env_spacing=2.0)
    scene = InteractiveScene(scene_cfg)

    # Get robot
    robot: Articulation = scene["robot"]

    print("\n" + "=" * 80)
    print("Unitree G1 Loaded Successfully!")
    print("=" * 80)
    print(f"Number of joints: {robot.num_joints}")
    print(f"Number of bodies: {robot.num_bodies}")
    print(f"Joint names: {robot.joint_names[:5]}... (showing first 5)")
    print("=" * 80 + "\n")

    # Reset and run for 500 steps
    sim.reset()
    print("Running simulation for 5 seconds...")

    for i in range(500):
        # Step simulation
        scene.write_data_to_sim()
        sim.step()
        scene.update(sim.dt)

        if i % 100 == 0:
            height = robot.data.root_pos_w[0, 2].item()
            print(f"Step {i}: Robot height = {height:.3f}m")

    print("\n✓ Test completed successfully!")
    print("G1 robot is working in Isaac Lab\n")


if __name__ == "__main__":
    main()
