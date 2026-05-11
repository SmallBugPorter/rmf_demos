#### 安全 ROS 2 办公演示

办公演示可以使用 [ROS 2 DDS-Security 集成](https://design.ros2.org/articles/ros2_dds_security.html)（SROS2）以安全模式运行。此安全功能将为整个 RMF 的 ROS2 设置提供加密、身份验证和访问控制。

由于 RMF 正处于快速开发阶段，变更非常频繁。因此，`office.policy.xml` 文件中声明的 ROS 2 访问控制策略仅保证与 RMF 1.1.X 版本一起工作，因此请将 RMF 工作区中的所有 git 仓库指向标签 `1.1.0`。或者，您也可以自行将这些策略更新为任何更高版本的 RMF（欢迎提交 PR :smirk:）。

有一个基于 `tmux` 的脚本，可自动拆分窗格并执行运行办公演示所需的所有命令。要以这种方式运行，只需打开一个 tmux 终端并运行该脚本。

```
bash ./install/rmf_demos/share/rmf_demos/sros2/office_deploy.bash
```

此外，以下步骤可用于单独运行所有所需命令。

要使用 ROS 2 保护办公演示，需要设置一些环境变量。将它们添加到脚本中，可便于在需要运行 ROS 2 安全节点的 shell 中 source。

```bash
echo 'export ROS_SECURITY_KEYSTORE=~/rmf_demos_ws/keystore
export ROS_SECURITY_ENABLE=true
export ROS_SECURITY_STRATEGY=Enforce
export ROS_DOMAIN_ID=42' > sros2_environment.sh
```

启用 DDS Security 需要一些安全工件，例如签名权限文件、身份证书和证书颁发机构（CA）。它们可以使用 ROS2 CLI 的安全工具生成。由于 [#242](https://github.com/ros2/sros2/issues/242) 以及在其解决方案 [#238](https://github.com/ros2/sros2/pull/238) 发布之前，建议在切换到 `cyclone_dds` 之前先生成安全工件。

```
source sros2_environment.sh
mkdir keystore
ros2 security generate_artifacts -k keystore -p ./install/rmf_demos/share/rmf_demos/sros2/policies/office.policy.xml
```

建议使用带有安全版本演示的 `cyclone dds`，确保其正确安装、支持安全功能，并通过相应环境变量进行选择（[这里](https://index.ros.org/doc/ros2/Installation/DDS-Implementations/Working-with-Eclipse-CycloneDDS/) 可找到说明）。将其添加到环境脚本中，以便在可能需要的终端中更容易 source。

```bash
echo 'export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp' >> sros2_environment.sh
```

由于 SROS2 目前尚不支持 `ros2 launch`，因此所有不同节点必须单独启动。建议每个执行使用一个终端，以便更容易调试系统。请确保在每个终端中执行不同命令之前先 `source ~/rmf_demos_ws/install/setup.bash`。

```bash
source sros2_environment.sh
ros2 run rmf_traffic_ros2 rmf_traffic_schedule --ros-args --params-file ./install/rmf_demos/share/rmf_demos/sros2/office.params.yaml --enclave /office/rmf_traffic_schedule_node
```

```bash
source sros2_environment.sh
ros2 run rmf_building_map_tools building_map_server ./install/rmf_demos_maps/share/rmf_demos_maps/office/office.building.yaml --ros-args --enclave /office/building_map_server
```

```bash
source sros2_environment.sh
ros2 run rmf_schedule_visualizer rviz2 -r 10 -m L1 --ros-args --params-file ./install/rmf_demos/share/rmf_demos/sros2/office.params.yaml --enclave /office/rviz2_node
```

```bash
source sros2_environment.sh
ros2 run building_systems_visualizer building_systems_visualizer -m L1 --ros-args --params-file ./install/rmf_demos/share/rmf_demos/sros2/office.params.yaml --enclave /office/building_systems_visualizer
```

```bash
source sros2_environment.sh
ros2 run fleet_state_visualizer fleet_state_visualizer -m L1 --ros-args --params-file ./install/rmf_demos/share/rmf_demos/sros2/office.params.yaml --enclave /office/fleet_state_visualizer
```

```bash
source sros2_environment.sh
rviz2 -d ./install/rmf_demos/share/rmf_demos/include/office/office.rviz --ros-args --enclave /office/rviz2
```

```bash
source sros2_environment.sh
ros2 run rmf_fleet_adapter door_supervisor --ros-args --enclave /office/door_supervisor
```

Gazebo 需要环境变量来定位文件并设置服务器与客户端之间的通信。可以将它们添加到脚本中，便于重复使用。

```bash
echo 'export GAZEBO_MODEL_PATH=~/rmf_demos_ws/install/rmf_demos_maps/share/rmf_demos_maps/maps/office/models:~/rmf_demos_ws/install/rmf_demos_assets/share/rmf_demos_assets/models:/usr/share/gazebo-11/models
export GAZEBO_RESOURCE_PATH=~/rmf_demos_ws/install/rmf_demos_assets/share/rmf_demos_assets:/usr/share/gazebo-11
export GAZEBO_PLUGIN_PATH=~/rmf_robot_sim_gz_classic_plugins/lib:~/rmf_demos_ws/install/building_gazebo_plugins/lib/
export GAZEBO_MODEL_DATABASE_URI=""' > gazebo_environment.sh
```

```bash
source sros2_environment.sh
source gazebo_environment.sh
gzserver --verbose -s libgazebo_ros_factory.so -s libgazebo_ros_init.so ./install/rmf_demos_maps/share/rmf_demos_maps/maps/office/office.world --ros-args --enclave /office/gzserver
```

由于 [#151](https://github.com/osrf/rmf_rmf_demos/issues/151)，由 gzclient 运行的插件创建的 ros 节点将被排除在安全网络之外。这应该只影响在 gzclient 上运行的 `toggle_floors` 插件，该插件用于多层演示。

```bash
source gazebo_environment.sh
gzclient --verbose ./install/rmf_demos_maps/share/rmf_demos_maps/maps/office/office.world
```

```bash
source sros2_environment.sh
ros2 run rmf_fleet_adapter full_control --ros-args -r __node:=tinyRobot_fleet_adapter --params-file ./install/rmf_demos/share/rmf_demos/sros2/office.params.yaml --enclave /office/tinyRobot_fleet_adapter
```

```bash
source sros2_environment.sh
ros2 run rmf_fleet_adapter robot_state_aggregator --ros-args -r __node:=tinyRobot_state_aggregator --params-file ./install/rmf_demos/share/rmf_demos/sros2/office.params.yaml --enclave /office/tinyRobot_state_aggregator
```

系统现在已准备好以通常方式处理模拟交付请求，同时具有 [DDS-security](https://www.omg.org/spec/DDS-SECURITY/1.1/PDF) 的所有保障！