# RMF Demos 新手入门（Jazzy 分支）

这份文档面向第一次接触 `rmf_demos` 的用户，目标是带你从零跑通一个最小示例，并理解这个项目最常见的使用方式。

本文基于当前 `jazzy` 分支，对应 README 中的推荐环境：

- Ubuntu 24.04
- ROS 2 Jazzy
- Gazebo Harmonic

## 1. 这个项目是什么

`rmf_demos` 是 Open-RMF 的示例项目，用来演示多机器人调度、路径避让、任务分发，以及门、电梯等楼宇资源协同。

可以把它简单理解成三部分：

- `Gazebo`：负责仿真世界和机器人
- `RMF`：负责调度、避让、任务和设施协同
- `rmf_demos_tasks`：负责从命令行下发任务

你最常见的使用流程只有三步：

1. 启动一个 demo 世界
2. 打开新终端发送任务
3. 观察机器人在仿真中执行任务

## 2. 先准备环境

### 2.1 安装 ROS 2 Jazzy

先按 ROS 2 官方文档完成 Jazzy 安装，并确认下面命令可用：

```bash
source /opt/ros/jazzy/setup.bash
ros2 --help
```

### 2.2 安装 Open-RMF 基础依赖

```bash
sudo apt update
sudo apt install -y ros-dev-tools
sudo rosdep init   # 仅第一次使用 rosdep 时需要
rosdep update

colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml
colcon mixin update default
```

### 2.3 安装 Open-RMF 二进制包

对新手来说，最省事的方式是安装 Open-RMF 二进制包，再单独编译 `rmf_demos`：

```bash
sudo apt update
sudo apt install -y ros-jazzy-rmf-dev
```

> `rmf_demos` 通常仍然建议在工作区里单独源码编译。

## 3. 获取并编译 rmf_demos

如果你还没有工作区，可以这样创建：

```bash
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws/src
git clone https://github.com/open-rmf/rmf_demos.git -b jazzy
```

如果仓库已经存在于 `~/ros2_ws/src/rmf_demos`，可以直接跳到依赖安装和编译。

### 3.1 安装源码依赖

```bash
cd ~/ros2_ws
source /opt/ros/jazzy/setup.bash
rosdep install --from-paths src --ignore-src --rosdistro $ROS_DISTRO -y
```

### 3.2 编译工作区

```bash
cd ~/ros2_ws
source /opt/ros/jazzy/setup.bash
colcon build
```

编译完成后，加载工作区环境：

```bash
source ~/ros2_ws/install/setup.bash
```

> 以后每开一个新终端，在运行 demo 前都要先执行一次 `source ~/ros2_ws/install/setup.bash`。

## 4. 第一次运行：Office World

对于新手，最推荐先跑 `Office World`。这个场景相对简单，任务也最容易理解。

### 4.1 终端 1：启动场景

```bash
source /opt/ros/jazzy/setup.bash
source ~/ros2_ws/install/setup.bash
ros2 launch rmf_demos_gz office.launch.xml
```

启动成功后，你会看到办公场景、机器人和 RMF 调度节点运行起来。

### 4.2 终端 2：发送巡逻任务

```bash
source /opt/ros/jazzy/setup.bash
source ~/ros2_ws/install/setup.bash
ros2 run rmf_demos_tasks dispatch_patrol -p coe lounge -n 3 --use_sim_time
```

这个命令表示让机器人在 `coe` 和 `lounge` 之间往返 3 次。

### 4.3 终端 2：发送配送任务

```bash
source /opt/ros/jazzy/setup.bash
source ~/ros2_ws/install/setup.bash
ros2 run rmf_demos_tasks dispatch_delivery -p pantry -ph coke_dispenser -d hardware_2 -dh coke_ingestor --use_sim_time
```

这个命令表示让机器人从 `pantry` 取货，再送到 `hardware_2`。

如果这两类任务都能跑通，就已经完成了这个项目最基础的上手。

## 5. 最常用的任务命令

### 5.1 巡逻任务

```bash
ros2 run rmf_demos_tasks dispatch_patrol -p coe lounge -n 3 --use_sim_time
```

### 5.2 清洁任务

```bash
ros2 run rmf_demos_tasks dispatch_clean -cs clean_lobby --use_sim_time
```

### 5.3 前往指定地点

```bash
ros2 run rmf_demos_tasks dispatch_go_to_place -p lounge -o 105 --use_sim_time
```

### 5.4 取消任务

```bash
ros2 run rmf_demos_tasks cancel_task -id patrol.dispatch-0
```

更多任务脚本说明见 [`rmf_demos_tasks/README.md`](../rmf_demos_tasks/README.md)。

## 6. 跑通后再尝试的场景

### 6.1 Hotel World

启动场景：

```bash
source /opt/ros/jazzy/setup.bash
source ~/ros2_ws/install/setup.bash
ros2 launch rmf_demos_gz office.launch.xml server_uri:="ws://localhost:8000/_internal"
```

发送任务：

```bash
ros2 run rmf_demos_tasks dispatch_patrol -p restaurant L3_master_suite -n 1 --use_sim_time
ros2 run rmf_demos_tasks dispatch_clean -cs clean_lobby --use_sim_time
```

这个场景适合观察多楼层、电梯和多车队协同。

### 6.2 Airport Terminal World

启动场景：

```bash
source /opt/ros/jazzy/setup.bash
source ~/ros2_ws/install/setup.bash
ros2 launch rmf_demos_gz airport_terminal.launch.xml
```

发送任务：

```bash
ros2 run rmf_demos_tasks dispatch_patrol -p s07 n12 -n 3 --use_sim_time
ros2 run rmf_demos_tasks dispatch_clean -cs zone_3 --use_sim_time
```

这个场景更大，适合后续观察复杂交通交互。

## 7. 从已跑通 Office + 巡逻任务切到 Web 面板（从零命令）

你当前已经能在 Gazebo 里看到 Office World，并且已经发出巡逻任务。下面按“从零到可见任务状态”的顺序执行。

### 7.1 终端 3：确认并安装 Docker（如未安装）

先检查 Docker 是否可用：

```bash
docker --version
```

如果提示命令不存在，再执行安装：

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

配置docker代理
```bash
sudo mkdir -p /etc/systemd/system/docker.service.d

sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf >/dev/null <<'EOF'
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7897"
Environment="HTTPS_PROXY=http://127.0.0.1:7897"
Environment="NO_PROXY=localhost,127.0.0.1,::1"
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl show --property=Environment docker
```

执行完 `usermod` 后，建议重新登录一次终端会话（或重启）再继续。

### 7.2 终端 3：设置与 RMF 一致的环境变量

```bash
source /opt/ros/jazzy/setup.bash
source ~/ros2_ws/install/setup.bash

export ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-0}
export RMW_IMPLEMENTATION=${RMW_IMPLEMENTATION:-rmw_fastrtps_cpp}

echo "ROS_DOMAIN_ID=$ROS_DOMAIN_ID"
echo "RMW_IMPLEMENTATION=$RMW_IMPLEMENTATION"
```

### 7.3 终端 3：启动 rmf-web 后端 API

如果你不想手动输入较长的 `docker run` 命令，可以在这一步直接运行仓库自带脚本：

```bash
~/ros2_ws/src/rmf_demos/scripts/run_rmf_web_api_server.bash
```

上面这个脚本和下面的 `docker run` 命令作用相同，二选一即可。

```bash\
rm -rf /tmp/rmf_web_api_run
mkdir -p /tmp/rmf_web_api_run/log
sudo docker run --rm -it \
  --network host \
  --ipc host \
  --user "$(id -u):$(id -g)" \
  -e ROS_DOMAIN_ID=$ROS_DOMAIN_ID \
  -e RMW_IMPLEMENTATION=$RMW_IMPLEMENTATION \
  -e ROS_LOG_DIR=/ws/run/log \
  -v /tmp/rmf_web_api_run:/ws/run \
  ghcr.io/open-rmf/rmf-web/api-server:jazzy-nightly
```

这个终端保持运行，不要关闭。

如果省略 `--ipc host` 或 `--user "$(id -u):$(id -g)"`，在 `rmw_fastrtps_cpp` 下可能出现“Web 能打开，但地图为空白”的情况。这是因为容器虽然能发现 ROS 话题，但收不到 `map` 话题里的实际数据。

### 7.4 终端 4：启动 rmf-web 前端 Dashboard

```bash
sudo docker run --rm -it \
  --network host \
  ghcr.io/open-rmf/rmf-web/demo-dashboard:jazzy-nightly
```

这个终端也保持运行，不要关闭。

如果你想避免页面里出现 `previous fire alarm trigger not available` 的告警，可额外开一个终端运行：

```bash
~/ros2_ws/src/rmf_demos/scripts/run_rmf_web_fire_alarm_latch.bash
```

这个脚本会为 `/fire_alarm_trigger` 提供一个带 `transient_local` QoS 的默认 `false` 状态，并在后续告警状态变化时继续保持最新值可被 rmf-web 缓存。

### 7.5 终端 1：重启 Office，并加上 server_uri

你现在已经在跑 `office.launch.xml`，需要先在终端 1 按 `Ctrl+C` 停掉，再用下面命令重启：

```bash
source /opt/ros/jazzy/setup.bash
source ~/ros2_ws/install/setup.bash
ros2 launch rmf_demos_gz office.launch.xml server_uri:="ws://localhost:8000/_internal"
```

### 7.6 终端 2：重新发送一个任务，方便在 Web 中观察

```bash
source /opt/ros/jazzy/setup.bash
source ~/ros2_ws/install/setup.bash
ros2 run rmf_demos_tasks dispatch_patrol -p coe -n 3 --use_sim_time
```

### 7.7 浏览器查看

在浏览器访问：

- `http://localhost:3000`

若页面可打开，且任务列表/机器人状态有变化，说明 Web 面板接入成功。

## 8. 新手最容易踩的坑

### 8.1 忘记 source 环境

每个终端都需要至少执行：

```bash
source /opt/ros/jazzy/setup.bash
source ~/ros2_ws/install/setup.bash
```

### 8.2 只装了 RMF，没有编译 rmf_demos

即使已经安装了 `ros-jazzy-rmf-dev`，`rmf_demos` 仍然通常需要在工作区里 `colcon build`。

### 8.3 第一次运行比较慢

第一次启动仿真时，Gazebo 可能会下载模型资源，等待时间较长属于正常现象。

## 9. 建议学习顺序

建议按下面顺序熟悉项目：

1. 先跑 `office.launch.xml`
2. 学会发送 `dispatch_patrol`
3. 再试 `dispatch_delivery`
4. 再切到 `hotel.launch.xml`
5. 最后看机场、网页面板和其他高级功能

## 10. 最短可执行流程

如果你已经具备 Jazzy 环境，并且仓库就在 `~/ros2_ws/src/rmf_demos`，最短流程如下：

```bash
cd ~/ros2_ws
source /opt/ros/jazzy/setup.bash
colcon build
source ~/ros2_ws/install/setup.bash
ros2 launch rmf_demos_gz office.launch.xml
```

再开一个终端执行：

```bash
source /opt/ros/jazzy/setup.bash
source ~/ros2_ws/install/setup.bash
ros2 run rmf_demos_tasks dispatch_patrol -p coe lounge -n 3 --use_sim_time
```

做到这里，就算已经成功跑通了 `rmf_demos` 的一个完整示例。
