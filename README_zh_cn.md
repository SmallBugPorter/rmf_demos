# RMF Demos

![](https://github.com/open-rmf/rmf_demos/workflows/build/badge.svg)
![](https://github.com/open-rmf/rmf_demos/workflows/style/badge.svg)

Open Robotics Middleware Framework (Open-RMF) 使得异构机器人舰队之间能够互操作，同时管理共享空间、建筑基础设施系统（如电梯、门等）和同一设施内其他自动化系统的机器人交通。Open-RMF 还负责参与者之间的任务分配与冲突解决（例如解除交通车道和其他资源的冲突）。这些功能由 [Open-RMF](https://github.com/open-rmf/rmf) 中的各种库提供。
有关 Open RMF 的详细信息，请参阅 [这里](https://osrf.github.io/ros2multirobotbook/intro.html) 提供的完整文档。

本仓库包含 RMF 上述能力的演示。它作为开始使用并集成 Open-RMF 的起点。

您还可以在 [Ionic Release Demo](https://github.com/gazebosim/ionic_demo) 中找到使用 `Nav2` 和 `MoveIt!` 构建的 Open-RMF 演示。

[![Robotics Middleware Framework](../media/thumbnail.png?raw=true)](https://vimeo.com/405803151)

#### (点击观看视频)

## 系统要求

这些演示已在以下环境中构建并测试：

* [Ubuntu 24.04 LTS](https://releases.ubuntu.com/24.04/)

* [ROS 2 - Jazzy](https://docs.ros.org/en/jazzy/Releases/Release-Jazzy-Jalisco.html)

* [Gazebo Harmonic](https://gazebosim.org/docs/harmonic)
> 注意：RMF 也完全支持 ROS 2 Humble 和 Iron，但这些版本需要从源代码构建 [ros_gz](https://github.com/gazebosim/ros_gz)。

## 安装

说明可在 [这里](https://github.com/open-rmf/rmf) 找到。

## 初学者指南

有关 `jazzy` 分支的逐步中文初学者指南，请参阅 [docs/beginner_guide_zh_cn.md](docs/beginner_guide_zh_cn.md)。

## 常见问题

有关常见问题的答案，请参阅 [这里](docs/faq.md)。

## 路线图

Open-RMF 项目的近期路线图可在用户手册 [这里](https://osrf.github.io/ros2multirobotbook/roadmap.html) 找到。

## RMF-Web 快速入门

Open-RMF 的完整 Web 应用：[rmf-web](https://github.com/open-rmf/rmf-web)。

使用默认配置通过 `docker` 启动后端 API 服务器，并启用主机网络访问。API 服务器默认可以通过 `localhost:8000` 访问。

```bash
mkdir -p /tmp/rmf_web_api_run/log

docker run \
  --network host -it --rm \
  --ipc host \
  --user "$(id -u):$(id -g)" \
  -e ROS_DOMAIN_ID=<ROS_DOMAIN_ID> \
  -e RMW_IMPLEMENTATION=<RMW_IMPLEMENTATION> \
  -e ROS_LOG_DIR=/ws/run/log \
  -v /tmp/rmf_web_api_run:/ws/run \
  ghcr.io/open-rmf/rmf-web/api-server:jazzy-nightly

# 对于不同 ROS 2 发行版请使用适当的标签
```

> 注意：当 `RMW_IMPLEMENTATION=rmw_fastrtps_cpp` 时，API 服务器容器需要与宿主机共享 IPC，并以宿主机相同的 UID/GID 运行。否则 Fast DDS 可能只能发现 ROS 图谱，却收不到 `transient_local` 的 `map` 话题，最终表现为 Web 地图空白。这里挂载的 `/tmp/rmf_web_api_run` 会保存本地 sqlite 数据库、缓存地图图片和 ROS 日志，并确保它们在重启后仍可写。

> 注意：通过挂载配置文件并设置环境变量 `RMF_API_SERVER_CONFIG`，也可以配置 API 服务器。

你也可以直接使用辅助脚本 [scripts/run_rmf_web_api_server.bash](scripts/run_rmf_web_api_server.bash) 启动 API 服务器。

如果当前演示环境里没有组件持续发布 `/fire_alarm_trigger`，dashboard 启动时可能会打印 `previous fire alarm trigger not available`。若希望 rmf-web 始终拿到一个默认的 `false` 状态，可在另一个终端运行 [scripts/run_rmf_web_fire_alarm_latch.bash](scripts/run_rmf_web_fire_alarm_latch.bash)。

通过 `docker` 启动前端仪表板，并启用主机网络访问。仪表板默认可以通过 `localhost:3000` 访问。

```bash
docker run \
  --network host -it --rm \
  ghcr.io/open-rmf/rmf-web/demo-dashboard:jazzy-nightly

# 对于不同 ROS 2 发行版请使用适当的标签
```

> 注意：通过 `docker` 运行的仪表板不可运行时配置，适合快速集成和测试。如需配置仪表板，请查看 [rmf-web-dashboard-resources](https://github.com/open-rmf/rmf_demos/tree/rmf-web-dashboard-resources/rmf_demos_dashboard_resources) 和 [仪表板配置部分](https://github.com/open-rmf/rmf-web/tree/main/packages/dashboard#configuration)。

为了与 Web 应用的默认配置交互，需要将 `server_uri` 启动参数更改为 `ws://localhost:8000/_internal`，例如：

```bash
ros2 launch rmf_demos_gz office.launch.xml server_uri:="ws://localhost:8000/_internal"
```

通过指定 `server_uri`，fleetadapter 将使用最新的任务和机器人状态更新 `rmf-web` `api-server`。然后用户即可通过交互式 Web 仪表板监控运行状态并发起 rmf 任务。

## 演示世界

* [Hotel World](#Hotel-World)
* [Office World](#Office-World)
* [Airport Terminal World](#Airport-Terminal-World)
* [Clinic World](#Clinic-World)
* [Campus World](#Campus-World)
* [Manufacturing & Logistics World](#Manufacturing-&-Logistics-World)

---

### Hotel World

该酒店世界由大堂和两个客房层组成。酒店配备两部电梯、多个门和 3 个机器人舰队（4 个机器人）。
这展示了具有不同能力的多个舰队机器人在多层建筑中协同工作的集成。

![](../media/hotel_world.png)

#### 演示场景

要启动该世界和计划可视化工具：

```bash
source ~/rmf_ws/install/setup.bash
ros2 launch rmf_demos_gz hotel.launch.xml

# 或使用 ignition 仿真运行
ros2 launch rmf_demos_gz hotel.launch.xml
```

在这里，我们将展示两种任务类型：**Loop** 和 **Clean**，您可以通过 CLI 发起它们，如下所示：
```bash
ros2 run rmf_demos_tasks dispatch_patrol -p restaurant  L3_master_suite -n 1 --use_sim_time
ros2 run rmf_demos_tasks dispatch_clean -cs clean_lobby --use_sim_time
```

运行 Clean 和 Loop 任务的机器人：

![](../media/hotel_scenarios.gif)

---

### Office World

一个室内办公环境，供机器人在其中导航。它包括饮料分配站、可控门和集成到 RMF 的车道。

```bash
source ~/rmf_demos_ws/install/setup.bash
ros2 launch rmf_demos_gz office.launch.xml

# 或使用 ignition 仿真运行
ros2 launch rmf_demos_gz office.launch.xml
```

现在我们将展示两种任务类型：**Delivery** 和 **Loop**

![](../media/delivery_request.gif?raw=true)

您可以通过以下方式请求机器人将一罐可乐从 `pantry` 送到 `hardware_2`：
```bash
ros2 run rmf_demos_tasks dispatch_delivery -p pantry -ph coke_dispenser -d hardware_2 -dh coke_ingestor --use_sim_time
```

您还可以通过以下方式请求机器人在 `coe` 和 `lounge` 之间来回移动：
```bash
ros2 run rmf_demos_tasks dispatch_patrol -p coe lounge -n 3 --use_sim_time
```

![](../media/loop_request.gif)

办公演示可以使用 ROS 2 DDS-Security 集成以安全模式运行。更多信息请点击 [这里](docs/secure_office_world.md)。

---

### Airport Terminal World

此演示世界展示了机器人在更大地图上的交互，具有更多车道、目的地、机器人以及来自不同舰队的机器人、基础设施和用户之间的可能交互。下面的插图从上到下依次显示了在 `traffic_editor` 中的世界外观、`rviz` 中的计划可视化器以及 `gazebo` 中的完整仿真。

![](../media/airport_terminal_traffic_editor_screenshot.png)
![](../media/airport_terminal_demo_screenshot.png)

#### 演示场景

在机场世界中，我们引入了新的 RMF 任务类型：`Clean`。要启动该世界：

```bash
source ~/rmf_ws/install/setup.bash
ros2 launch rmf_demos_gz airport_terminal.launch.xml
```

您可以通过 CLI 提交 `loop`、`delivery` 或 `clean` 任务：
```bash
ros2 run rmf_demos_tasks dispatch_patrol -p s07 n12 -n 3 --use_sim_time
ros2 run rmf_demos_tasks dispatch_delivery -p mopcart_pickup -ph mopcart_dispenser -d spill -dh mopcart_collector --use_sim_time
ros2 run rmf_demos_tasks dispatch_clean -cs zone_3 --use_sim_time
```

要查看人群仿真效果，请启用 crowd sim：
```bash
ros2 launch rmf_demos_gz airport_terminal.launch.xml use_crowdsim:=1
```

如果非自主车辆的位姿可以在该世界中定位，则也可以将其集成到 Open-RMF 中。这在空间由自主机器人和手动操作车辆（如叉车或运输车）共享的设施中可能非常有价值。在此演示中，我们可以引入一辆可通过键盘/操纵杆遥控驾驶的车辆（caddy）。在 Open-RMF 术语中，该车辆被分类为 `read_only` 类型，即 Open-RMF 只能推断其在世界中的位置，而无法控制其运动。这里的目标是让其他可控机器人在需要时通过重新规划路线来避免该车辆的路径。该模型配备了一个插件，该插件根据当前航向生成车辆路径预测。它被配置为占用与 `tinyRobot` 机器人相同的车道。然后，`read_only_fleet_adapter` 将来自插件的预测提交到 Open-RMF 的计划中。

在机场航站楼地图中，`Caddy` 被生成在最右侧角落，并可以通过发布到 `cmd_vel` 话题的 `geometry_msgs/Twist` 消息进行控制。

运行 `teleop_twist_keyboard` 以使用键盘控制 `caddy`：
```bash
# 默认使用 gazebo 启动
ros2 run teleop_twist_keyboard teleop_twist_keyboard

ros2 launch rmf_demos_gz airport_terminal_caddy.launch.xml
```

![](../media/caddy.gif)

---

### Clinic World

这是一个具有两层和两部电梯的诊所世界。两种不同角色的机器人舰队通过电梯在两层之间导航。下面的插图显示了 `traffic_editor` 中的第 1 层视图（左上）、`rviz` 中的计划可视化器（右）和 `gazebo` 中的完整仿真（左下）。

![](../media/clinic.png)

#### 演示场景

要启动该世界和计划可视化工具：

```bash
source ~/rmf_ws/install/setup.bash
ros2 launch rmf_demos_gz clinic.launch.xml
```

您可以通过 CLI 提交任务：
```bash
ros2 run rmf_demos_tasks dispatch_patrol -p L1_left_nurse_center L2_right_nurse_center -n 5 --use_sim_time
ros2 run rmf_demos_tasks dispatch_patrol -p L2_north_counter L1_right_nurse_center -n 5 --use_sim_time
```

机器人乘坐电梯：

![](../media/robot_taking_lift.gif)

多舰队演示：

![](../media/clinic.gif)

---
### Campus World

这是一个更大规模的“Campus”世界。在该世界中，有多台送货机器人在运行。该世界经过设计，交通车道以行星尺度的 GPS WGS84 坐标进行了标注。每个机器人也以 WGS84 坐标流式传输其位置信息，由其舰队适配器进行处理。本演示旨在展示 Open-RMF 在大规模地图上的潜力。

![](../media/campus.gif)

#### 演示场景

要启动该世界和计划可视化工具：

```bash
source ~/rmf_ws/install/setup.bash
ros2 launch rmf_demos_gz campus.launch.xml

ros2 run rmf_demos_tasks  dispatch_patrol -p room_5 campus_4 -n 10 --use_sim_time
ros2 run rmf_demos_tasks  dispatch_patrol -p campus_5 room_3 -n 10 --use_sim_time
ros2 run rmf_demos_tasks  dispatch_patrol -p room_2 dead_end -n 10 --use_sim_time
```

#### RobotManager 集成

`fleet_robotmanager_mqtt_bridge` (参见 [rmf_demos_bridges](https://github.com/open-rmf/rmf_demos/tree/main/rmf_demos_bridges/rmf_demos_bridges)) 可用于发布机器人位置、电量百分比和状态到 `/robot/status/ROBOT-ID` websocket 端点。可以配置 RobotManager 实例订阅该服务器以接收 json 消息，从而对机器人进行可视化。

```bash
# 安装先决条件
sudo apt install mosquitto mosquitto-clients

# 启动 bridge
ros2 run rmf_demos_bridges fleet_robotmanager_mqtt_bridge -y 31500 -x 22000
```

可以使用以下示例命令回显第一台机器人的 json 消息：

```bash
mosquitto_sub -t /robot/status/00000000-0000-0000-0000-000000000001
```

---
### Manufacturing & Logistics World

由 ROS-Industrial Asia Pacific 创建的 Open-RMF 仿真演示，展示了工作单元（传送带和固定机械臂）、多舰队 AMR 和基础设施互操作性，使用 Open Robotics Middleware Framework (Open-RMF)。

<p align="center">
[![Alt text](https://img.youtube.com/vi/oSVQrjx_4w4/0.jpg)](https://www.youtube.com/watch?v=oSVQrjx_4w4)
</p>

## 其他工具和功能演示

* [Traffic Light Robot Demos](#Traffic-Light-Robot-Demos)
* [Additional Features](#Additional-Features)
* [Task Dispatching in Open-RMF](#Task-Dispatching-in-Open-RMF)

### Traffic Light Robot Demos

Open-RMF 还可以管理其 API 或舰队管理器仅提供暂停和恢复命令来控制其机器人舰队。这类舰队被分类为 `traffic_light`。要集成 `traffic_light` 舰队，用户应基于此 [API](https://github.com/open-rmf/rmf_ros2/blob/main/rmf_fleet_adapter/include/rmf_fleet_adapter/agv/EasyTrafficLight.hpp) 实现 `traffic_light` 舰队适配器。`rmf_demos` 仓库包含各种场景中的 `traffic_light` 舰队演示。这些演示中使用了简化的 `mock_traffic_light` 适配器。

#### Triple-H 场景：
```bash
$ ros2 launch rmf_demos_gz triple_H.launch.xml
(new terminal) $ ros2 launch rmf_demos the_pedigree.launch.xml
```
#### Battle Royale 场景：

```bash
$ ros2 launch rmf_demos_gz battle_royale.launch.xml
(new terminal) $ ros2 launch rmf_demos battle_go.launch.xml
```

#### Office 场景：
请注意 `tinyRobot1` 是标准的“full control”机器人，而 `tinyRobot2` 是“traffic light”机器人。
```bash
$ ros2 launch rmf_demos_gz office_mock_traffic_light.launch.xml
(new terminal) $ ros2 launch rmf_demos office_traffic_light_test.launch.xml
```

### Additional Features
 - **Flexible Tasks Scripts**
   有关更多[详细信息](rmf_demos_tasks/README.md)。

 - **lift watchdog**
   - 机器人可以在 `LiftSession` 阶段查询外部 `lift_watchdog_server` 是否允许进入电梯舱。
   - 命令行：
    ```bash
    # 在 hotel world 中启用 lift_watch_dog
    ros2 launch rmf_demos_gz hotel.launch.xml enable_experimental_lift_watchdog:=1

    ## 在另一个终端，将电梯设置为拥挤状态
    ros2 launch rmf_demos experimental_crowded_lift.launch.xml

    # 从 level1 调度机器人到 level3，机器人将会在电梯舱前等待
    ros2 run rmf_demos_tasks dispatch_patrol -p L3_room1  L3_room1 -n 1 --use_sim_time

    # 电梯已清空。授权机器人进入电梯
    ros2 launch rmf_demos experimental_clear_lift.launch.xml
    ```

 - **Custom Docking Sequence**
    - 当机器人到达“dock”航点时，fleet adapter 将通过 `dock()` api/ModeRequest 通知机器人执行其自定义对接序列。
    - 实现类似于清洁任务，请参阅文档 [这里](https://osrf.github.io/ros2multirobotbook/task_types.html?highlight=docking#step-1-defining-waypoints-for-cleaning-in-traffic-editor)

 - **Emergency Alarm**
   - 触发紧急警报时，所有机器人将被引导到最近的停车点。
   - 命令行：
    ```bash
    # 打开警报
    ros2 topic pub -1 /fire_alarm_trigger std_msgs/Bool '{data: true}'

    # 关闭警报
    ros2 topic pub -1 /fire_alarm_trigger std_msgs/Bool '{data: false}'
    ```

## Task Dispatching in Open-RMF
![](../media/RMF_Bidding.png)

在 Open-RMF 版本 `21.04` 及以上，任务根据由 Dispatcher 节点 `rmf_dispatcher_node` 协调的竞标过程授予给机器人舰队。当 Dispatcher 从 UI 收到新任务请求时，它会向所有舰队适配器发送 `rmf_task_msgs/BidNotice` 消息。如果某个舰队适配器能够处理该请求，它会向 Dispatcher 提交带有任务成本的 `rmf_task_msgs/BidProposal` 消息。舰队适配器使用 `rmf_task::agv::TaskPlanner` 实例来确定如何最好地处理新请求。Dispatcher 比较所有收到的 `BidProposal`，然后提交包含获胜舰队名称的 `rmf_task_msgs/DispatchRequest` 消息。Dispatcher 可通过多种配置方式评估方案，例如最快完成、最低成本等。

电池充电与新的任务规划器紧密集成。当机器人电量不足以完成一系列任务时，`ChargeBattery` 任务会被优化性地插入到机器人计划中。目前我们假定地图中的每个机器人都有一个专用充电位置，该位置在 traffic editor 地图中使用 `is_charger` 选项进行注释。

