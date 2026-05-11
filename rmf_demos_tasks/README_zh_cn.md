# rmf\_demo\_tasks

本包提供 RMF 演示中用于展示可请求给机器人的任务的脚本。

## 灵活任务

新的任务系统允许用户以更灵活的方式构造并提交自己的任务，例如在循环任务中具有多个停靠点或为清洁任务指定机器人。本包包含一些有助于演示如何组合此类任务的脚本：

- **dispatch_patrol**

  此任务允许用户调度机器人执行巡逻任务。除了起点和终点位置外，您还可以提供舰队名称 `-F` 和机器人名称 `-R`。

  Office 世界的示例：将任务调度给特定机器人。
  ```
  ros2 run rmf_demos_tasks dispatch_patrol -F tinyRobot -R tinyRobot1 -p lounge -n 2 --use_sim_time
  ```

  或者指定多个地点让机器人行驶：
  ```
  ros2 run rmf_demos_tasks dispatch_patrol -p supplies pantry coe --use_sim_time
  ```

- **dispatch_clean**

  此脚本提交清洁任务。`-cs` 标志接受所需清洁区域作为参数。您也可以通过提供舰队名称 `-F` 和机器人名称 `-R` 来选择指定机器人执行该清洁任务。

  Hotel 世界的示例：
  ```
  ros2 run rmf_demos_tasks dispatch_clean -cs clean_lobby -F cleanerBotA -R cleanerBotA_1 --use_sim_time
  ```

- **dispatch_action**

  此脚本演示如何使用 `PerformAction` 遥控功能组合任务。您可以要求机器人前往起点 `-s` 执行一个动作，`-a` 表示动作名称。

  Office 世界示例。以下示例展示了动作名称为 “teleop”。
  ```
  ros2 run rmf_demos_tasks dispatch_action -F tinyRobot -R tinyRobot1 -a teleop -s coe --use_sim_time
  ```

  在完成遥控动作后，您需要发布以下消息以将控制权返回给 RMF：
  ```
  ros2 topic pub /action_execution_notice rmf_fleet_msgs/msg/ModeRequest '{fleet_name:  tinyRobot, robot_name: tinyRobot1, mode: {mode: 0}}' --once
  ```

  此脚本还接受一系列起始点 `-s` 作为参数，并命令机器人在给定点执行相同指定动作。

  Office 世界示例。对 `coe`、`supplies` 和 `pantry` 三个航点运行总共 3 次 “teleop” 动作：
  ```
  ros2 run rmf_demos_tasks dispatch_action -a teleop -s coe supplies pantry --use_sim_time
  ```

  机器人将移动到这些地点中的每一个，并且 RMF 将放弃控制。与前述 `dispatch_action` 类似，您可以执行所需动作（例如使用提供的 `teleop_robot` 脚本），并通过向 `/action_execution_notice` 发布 `ModeRequest` 来结束该动作。然后机器人将移动到下一个点以执行下一个动作。

- **dispatch_delivery**

  此脚本允许用户执行具有一个或多个取货和放货位置的送货。它按提交顺序接收关于取货 `-p` 和放货 `-d` 活动的信息。对于每个活动，您需要分别提供地点、处理器、货物 SKU 和数量。

  Office 世界的示例：
  ```bash
  ros2 run rmf_demos_tasks dispatch_delivery \
  -p pantry pantry \
  -ph coke_dispenser coke_dispenser_2 \
  -d hardware_2 coe \
  -dh coke_ingestor coke_ingestor_2 \
  -pp coke,1 coke,1 \
  -dp coke,1 coke,1 \
  --use_sim_time
  ```

- **cancel_task**
  通过指定任务 ID 取消任务：
  
  示例：在新启动的 `office_world` 中调度一个 `patrol` 任务。
  ```
  ros2 run rmf_demos_tasks dispatch_patrol -p coe lounge --use_sim_time
  ```

  然后尝试使用 id 取消已提交的任务。
  ```bash
  ros2 run rmf_demos_tasks cancel_task -id patrol.dispatch-0
  ```

  **cancel_robot_task**
  取消当前在特定机器人上执行的任务

  示例：在新启动的 `office_world` 中调度一个 `patrol` 任务给指定机器人。
  ```
  ros2 run rmf_demos_tasks dispatch_go_to_place -p pantry -F tinyRobot -R tinyRobot2 --use_sim_time
  ```

  然后尝试使用 id 取消已提交的任务。
  ```bash
  ros2 run rmf_demos_tasks cancel_robot_task -F tinyRobot -R tinyRobot2
  ```

## 附加脚本

- **office_teleop_robot**
  此脚本演示 `teleop` 执行动作任务的能力。设想当机器人执行遥控动作时，用户希望在此期间移动机器人。为模拟此行为，我们将在办公世界中展示该场景。
  
  启动 Office 世界并运行上述 `dispatch_action` 任务，将 `tinyRobot1` 带到 `coe`。在执行动作期间，fleetadapter 将放弃对机器人的控制。要模拟遥控操作，请运行：
  ```
  ros2 launch rmf_demos office_teleop_robot.launch.xml
  ```
  
  `office_teleop_robot` 脚本直接在仿真中控制机器人运动，而不经过 fleet adapter。

  如果您在 Gazebo 中运行此脚本，需要删除房间中的椅子模型，以便仿真物理性能更顺畅。

  您可以通过向 `/action_execution_notice` 话题发布 `ModeRequest` 来结束该动作，如上所示。

- **dispatch_go_to_place**
  与 `dispatch_patrol` 类似，您可以调度机器人前往指定航点。`dispatch_go_to_place` 的有用之处在于可以使用参数 `-o` 指定机器人到达目的地时的朝向。此外，您还可以使用 `-f` 和 `-R` 指定机器人。

  Office 世界示例：
  ```
  ros2 run rmf_demos_tasks  dispatch_go_to_place -p lounge -o 105 --use_sim_time
  ```

## 质量声明

本包声称属于 **Quality Level 4** 类别，详情请参阅 [Quality Declaration](./QUALITY_DECLARATION.md)。