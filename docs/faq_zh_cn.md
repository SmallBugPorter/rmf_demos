# 常见问题

问候，

本页旨在记录与本仓库中展示的机器人中间件框架演示相关的常见问题。`rmf_core` 仓库还有一个额外的 [FAQ 页面](https://github.com/open-rmf/rmf_ros2/blob/master/docs/faq.md)，其中讨论了一些重要的高层主题。

#### 在启动时 Gazebo 崩溃并出现 `No namespace found` 错误

已知该错误在使用 `Gazebo 9.0.0` 启动演示时会出现。该版本是 Ubuntu bionic 版本默认提供的 Gazebo。演示需要 `Gazebo 9.12.0` 或 `Gazebo 9.13.0`。要从 `Gazebo 9.0.0` 更新，首先确保您的软件包源是最新的。

```
sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
wget https://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
```
然后运行
```
sudo apt-get update
sudo apt-get upgrade
```


#### 在启动 Airport Terminal 世界时 Gazebo 无法加载多个模型

Airport Terminal 世界中包含的多个模型托管在 [这里](https://github.com/osrf/gazebo_models)，因此未包含在 `rmf_demo_assets` 中，以避免维护重复项。可以将单个模型文件夹下载到 `~/.gazebo/models/` 或使用以下命令下载整个集合。

```bash
cd ~/.
git clone https://github.com/osrf/gazebo_models
cd gazebo_models
cp -r ./* ~/.gazebo/models/.
```
现在重新启动演示后，Gazebo 将能够找到所需模型。


#### 在 Gazebo 世界中添加/修改模型

模型的位置和朝向使用 `traffic_editor` 定义。将所需的 `.project.yaml` 文件加载到 `traffic_editor` 中，可将模型添加到楼层平面图或修改模型。


#### 使用 Ignition 运行仿真

正在进行对 Ignition 仿真支持的工作。设置说明将在不久的将来更新。


#### RMF 是否适用于运行导航栈的机器人？演示中的机器人仅沿直线段移动。

是的。RMF 与机器人用于定位自身和在地图中导航的技术无关。这是因为 RMF 处理的是更高层次的交通规划，考虑了在同一空间中其他机器人舰队的存在。RMF 维护一个 `schedule database`，记录同一环境中所有机器人预定路径，并监控这些路径是否可能发生冲突。成本地图不是传感器检测到障碍物的占据网格，而是机器人轨迹的时空表示数据库。这些轨迹被插值为三次样条，并考虑了各机器人运动学。

轨迹由 `rmf_fleet_adapter` 提交到 `schedule database`，该适配器与专有的 `fleet manager` 或机器人 API 交互。`rmf_fleet_adapter` 可根据供应商机器人舰队提供的控制级别进行配置。通常，`rmf_fleet_adapter` 跟踪其机器人轨迹，并在检测到冲突时与冲突机器人对应的 `rmf_fleet_adapter` 进入协商，从而计算新计划。这之所以可行，是因为每个 `rmf_fleet_adapter` 都维护一个 `schedule database` 的镜像，因此了解空间中所有活动轨迹。生成的计划可能要求机器人在某个节点等待，或沿图中的其他车道重新规划路线。计划结果通过 `PathRequest` 消息传达给机器人的 `fleet manager`。预期供应商 `fleet manager` 将遵从传入请求，并命令相应机器人遵循 `PathRequest` 消息中的航点前往目的地，以实现无冲突。此时机器人将使用其导航栈和驱动程序驱动至每个航点，同时避开传感器检测到的障碍物。与此同时，`rmf_fleet_adapter` 期望 `fleet manager` 通过 `RobotState` 消息将机器人当前位置及其剩余路径更新回适配器。例如，如果机器人因路径中的动态障碍暂停，则该信息会通过 `RobotState` 消息隐式传达，该延迟会提交到 `schedule database`，现在对其他 `rmf_fleet_adapter` 可见，并且如果受延迟影响，它们可以重新规划机器人路线。

为了在仿真中复制 `rmf_fleet_adapter` 与供应商机器人之间的这种交互，我们提供了 `slotcar` 插件。该插件执行两项工作：1）通过上述消息与 `rmf_fleet_adapter` 交互；2）通过驱动模型关节将机器人导航到请求的航点。对于后者，它实现了简单的“轨道式”导航，将机器人沿从当前位置到航点的直线加速和减速。我们假设机器人车道没有其他静态障碍物。这样做的目的是最小化运行演示系统时的计算负载，因为对于仿真中的每个机器人运行 ROS1/2 导航栈会显著提高负载。由于这里关注的是异构舰队的交通管理，而不是机器人导航，因此 `slotcar` 插件使我们能够高效测试各种场景。

然而，确实可以使用由导航栈驱动的机器人运行这些演示。这将需要运行一个单独节点，该节点：1）像 `slotcar` 一样发送和接收 `RobotState` 和 `PathRequest` 消息；2）将 `PathRequest` 消息中接收到的航点发送给导航栈的动作服务器，并在过程中更新机器人的状态。如有必要，可对目标坐标应用变换（旋转、平移或缩放），以适应 onboard `.pgm` 地图与 `traffic_editor` 注释的楼层平面图之间的差异。这些差异可以通过将 `.pgm` 文件导入 `traffic_editor` 来检查。这也是我们在真实机器人上测试 RMF 的方式。


#### RMF 如何检测冲突并为移动机器人重新规划路线？

请参阅 `rmf_core` 中的 [FAQ](https://github.com/open-rmf/rmf_ros2/blob/master/docs/faq.md#how-does-rmf_traffic-avoid-mobile-robot-traffic-conflicts)


#### RMF 是否已在真实机器人上测试？

是的，RMF 已在多种品牌（基于 ROS 和非 ROS）的机器人上进行了测试，并且这些机器人在同一空间中共同运行。在这些机器人中，有两种变体提供 `full control` 集成，另一种为 `read_only`。有关集成的更多信息将在不久的将来记录。