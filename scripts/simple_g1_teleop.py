#!/usr/bin/env python3
"""
Simple Unitree G1 Teleoperation Script

A simplified version that focuses on getting the robot running quickly
without external dependencies.
"""

import argparse
import numpy as np
import torch

# Isaac Lab imports
import omni.isaac.lab.sim as sim_utils
from omni.isaac.lab.actuators import ImplicitActuatorCfg
from omni.isaac.lab.assets import ArticulationCfg, Articulation
from omni.isaac.lab.scene import InteractiveScene, InteractiveSceneCfg
from omni.isaac.lab.sim import SimulationContext
from omni.isaac.lab.utils import configclass
import omni.isaac.lab.utils.math as math_utils


@configclass
class G1SceneCfg(InteractiveSceneCfg):
    """Simplified G1 scene configuration"""

    ground = sim_utils.GroundPlaneCfg()
    dome_light = sim_utils.DomeLightCfg(intensity=3000.0, color=(0.9, 0.9, 0.9))

    robot: ArticulationCfg = ArticulationCfg(
        prim_path="{ENV_REGEX_NS}/Robot",
        spawn=sim_utils.UsdFileCfg(
            usd_path=f"{{ISAACLAB_PATH}}/source/extensions/omni.isaac.lab_assets/data/Robots/Unitree/G1/g1.usd",
            rigid_props=sim_utils.RigidBodyPropertiesCfg(
                disable_gravity=False,
                max_depenetration_velocity=10.0,
            ),
            articulation_props=sim_utils.ArticulationRootPropertiesCfg(
                enabled_self_collisions=False,
                solver_position_iteration_count=4,
                solver_velocity_iteration_count=0,
            ),
        ),
        init_state=ArticulationCfg.InitialStateCfg(
            pos=(0.0, 0.0, 0.8),
            joint_pos={
                ".*_hip_pitch": -0.2,
                ".*_knee": 0.4,
                ".*_ankle": -0.2,
                ".*_shoulder_pitch": 0.2,
                ".*_elbow": -0.3,
            },
        ),
        actuators={
            "legs": ImplicitActuatorCfg(
                joint_names_expr=[".*hip.*", ".*knee.*", ".*ankle.*"],
                stiffness=200.0,
                damping=10.0,
            ),
            "arms": ImplicitActuatorCfg(
                joint_names_expr=[".*shoulder.*", ".*elbow.*", ".*wrist.*"],
                stiffness=40.0,
                damping=5.0,
            ),
        },
    )


class SimpleWBCController:
    """Simple Whole-Body Controller for standing and basic motions"""

    def __init__(self, robot: Articulation):
        self.robot = robot
        self.default_joint_pos = robot.data.default_joint_pos.clone()

        # Command velocities
        self.cmd_vel_x = 0.0
        self.cmd_vel_y = 0.0
        self.cmd_vel_yaw = 0.0

    def set_command(self, vel_x, vel_y, vel_yaw):
        """Set command velocities"""
        self.cmd_vel_x = vel_x
        self.cmd_vel_y = vel_y
        self.cmd_vel_yaw = vel_yaw

    def compute_actions(self):
        """Compute joint position targets"""
        # Start with default standing pose
        target_pos = self.default_joint_pos.clone()

        # Modulate joint positions based on commands
        # This is a very simplified gait - you'd want a proper gait generator
        if abs(self.cmd_vel_x) > 0.01:
            # Simple walking motion
            phase = (self.robot.data.joint_pos[:, 0] * 10.0) % (2 * np.pi)
            stride = self.cmd_vel_x * 0.2

            # Hip pitch modulation
            target_pos[:, :6] += torch.sin(phase.unsqueeze(1)) * stride

        return target_pos

    def reset(self):
        """Reset controller state"""
        self.cmd_vel_x = 0.0
        self.cmd_vel_y = 0.0
        self.cmd_vel_yaw = 0.0


def main():
    parser = argparse.ArgumentParser(description="Simple G1 Teleoperation")
    parser.add_argument("--headless", action="store_true", help="Run in headless mode")
    args = parser.parse_args()

    print("=" * 80)
    print("Simple Unitree G1 Teleoperation")
    print("=" * 80)
    print("\nControls:")
    print("  This version uses the default Isaac Lab viewport")
    print("  Robot will maintain standing pose")
    print("\n" + "=" * 80)

    # Create simulation
    sim_cfg = sim_utils.SimulationCfg(dt=0.005, device="cuda:0")
    sim = SimulationContext(sim_cfg)
    sim.set_camera_view(eye=[3.5, 3.5, 2.5], target=[0.0, 0.0, 0.5])

    # Create scene
    scene_cfg = G1SceneCfg(num_envs=1, env_spacing=2.0)
    scene = InteractiveScene(scene_cfg)

    # Get robot
    robot: Articulation = scene["robot"]

    print(f"\nRobot loaded with {robot.num_joints} joints")
    print(f"Joint names: {robot.joint_names}")

    # Create controller
    controller = SimpleWBCController(robot)

    # Play simulation
    sim.reset()
    print("\nSimulation running...")

    count = 0
    while sim.is_playing():
        # Compute actions
        joint_pos_target = controller.compute_actions()

        # Apply actions
        robot.set_joint_position_target(joint_pos_target)

        # Step simulation
        scene.write_data_to_sim()
        sim.step()
        scene.update(sim.dt)

        count += 1

        if count % 200 == 0:
            print(f"Steps: {count} | Root height: {robot.data.root_pos_w[0, 2]:.3f}m", end='\r')

    print("\nSimulation ended")


if __name__ == "__main__":
    main()
