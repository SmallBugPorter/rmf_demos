# rmf_demos_fleet_adapter

这是一个针对选定 RMF 演示世界（Hotel、Office、Airport Terminal 和 Clinic）的 Python 基 [fleet adapter template](https://github.com/open-rmf/fleet_adapter_template) 的实现。

该舰队适配器集成依赖于一个舰队管理器和一个舰队适配器：
- **fleet manager** 由特定端点组成，用于将命令转发给舰队机器人。它通过内部 ROS 2 消息与机器人通信，同时通过用户选择的 API 与适配器交互。对于此演示舰队适配器实现，我们使用基于 FastAPI 框架的 REST API。
- **fleet adapter** 从 RMF 接收命令，并与 fleet manager 交互以接收机器人状态信息，以及向机器人发送任务和导航命令。

## 入门

确保已安装所需依赖项：
```bash
pip3 install fastapi uvicorn

# **确保 py libs 版本为 'fastapi>=0.79.0', 'uvicorn>=0.18.2'.
```

可以使用 FastAPI 的自动文档与端点交互。首先启动演示世界，然后在浏览器中访问基础 URL 并在末尾添加 `/docs`。请注意，每个演示舰队的端口号在 `rmf_demos/rmf_demos/config/` 中指定。

#### 示例

启动 Office 世界：
```bash
source ~/rmf_ws/install/setup.bash
ros2 launch rmf_demos_gz_classic office.launch.xml
```
然后访问 http://127.0.0.1:22011/docs 以在浏览器中与端点交互。

## 请求/响应架构

取决于端点，内容可能有所不同（例如某些项可能会被移除），但遵循一般结构：
##### 请求正文
```json
{
  "map_name": "string",
  "task": "string",
  "destination": {},
  "data": {},
  "speed_limit": 0.0
}
```
##### 响应正文
```json
{
  "data": {},
  "success": true,
  "msg": ""
}1
```

## API 端点

注意：本节中的基础 URL 包含为 tinyRobot 舰队专用的端口号 `22011`。不同舰队的端口号会有所变化。

### 1. 获取机器人状态

`status` 端点允许舰队适配器访问机器人状态信息，例如其当前位置和电量。此端点不需要请求正文。

有两种方式请求舰队机器人状态：

#### a. 获取舰队中所有机器人状态

请求 URL：`http://127.0.0.1:22011/open-rmf/rmf_demos_fm/status/`
##### 响应正文：
```json
{
  "data": {
    "all_robots": [
      {
        "robot_name": "tinyRobot1",
        "map_name": "L1",
        "position": {
          "x": 10.0,
          "y": 20.0,
          "yaw": 1.0
        },
        "battery": 100,
        "last_completed_request": 2,
        "destination_arrival": {
          "cmd_id": 3,
          "duration": 14.3
        }
      },
      {
        "robot_name": "tinyRobot2",
        "map_name": "L1",
        "position": {
          "x": 5.0,
          "y": 25.0,
          "yaw": 1.4
        },
        "battery": 100,
        "last_completed_request": 3,
        "destination_arrival": null,
        "replan": true
      }
    ]
  },
  "success": true,
  "msg": ""
}
```

#### b. 获取指定机器人状态

在 URL 末尾添加 `robot_name` 查询参数。

请求 URL：`http://127.0.0.1:22011/open-rmf/rmf_demos_fm/status/?robot_name=tinyRobot1`
##### 响应正文：
```json
{
  "data": {
    "robot_name": "tinyRobot1",
    "map_name": "L1",
    "position": {
      "x": 10.0,
      "y": 20.0,
      "yaw": 1.0
    },
    "battery": 100,
    "last_completed_request": 2,
    "destination_arrival": {
      "cmd_id": 3,
      "duration": 14.3
    }
  },
  "success": true,
  "msg": ""
}
```

### 2. 发送导航请求

`navigate` 端点允许舰队适配器向指定机器人发送导航航点。此端点需要请求正文和 `robot_name` 查询参数。

请求 URL：`http://127.0.0.1:22011/open-rmf/rmf_demos_fm/navigate/?robot_name=tinyRobot1`
##### 请求正文：
```json
{
  "map_name": "L1",
  "destination": {
    "x": 7.0,
    "y": 3.5,
    "yaw": 0.5
  },
  "speed_limit": 0.0
}
```

##### 响应正文：
```json
{
  "success": true,
  "msg": ""
}
```

### 3. 停止机器人

`stop` 端点允许舰队适配器命令指定机器人停止。此端点仅需要 `robot_name` 查询参数。

请求 URL：`http://127.0.0.1:22011/open-rmf/rmf_demos_fm/stop/?robot_name=tinyRobot1`
##### 响应正文：
```json
{
  "success": true,
  "msg": ""
}
```

### 4. 发送任务请求

`start_activity` 端点允许舰队适配器向指定机器人发送任务请求。此端点需要请求正文和 `robot_name` 查询参数。

请求 URL：`http://127.0.0.1:22011/open-rmf/rmf_demos_fm/start_activity/?robot_name=tinyRobot1`
##### 请求正文：
```json
{
  "map_name": "L1",
  "task": "clean_lobby"
}
```

舰队管理器将通过指示机器人执行任务时将遵循的路径来响应。

##### 响应正文：
```json
{
  "success": true,
  "msg": "",
  "data": {
    "path": {
      "map_name": "L1",
      "path": { ... }
    }
  }
}
```