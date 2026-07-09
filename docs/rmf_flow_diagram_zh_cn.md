# Open-RMF 项目程序流程图

> 基于 `rmf_demos` office world 场景，展示从 Web 端创建任务到机器人执行、多机器人调度避让的完整流程。

---

## 1. 系统总体架构

```mermaid
graph TB
    subgraph Browser["🌐 浏览器 (localhost:3000)"]
        Dashboard["rmf-web demo-dashboard<br/>React 前端"]
    end

    subgraph APIServer["🖥️ rmf-web api-server (localhost:8000)"]
        API["REST API + WebSocket Server"]
    end

    subgraph ROS2["🤖 ROS 2 系统 (rmf_demos_gz)"]
        subgraph Core["RMF 核心节点"]
            Dispatcher["Task Dispatcher<br/>(rmf_task_ros2)<br/>任务分发器 + 拍卖引擎"]
            TrafficNode["Traffic Schedule Node<br/>(rmf_traffic_ros2)<br/>交通调度核心"]
            Blockade["Traffic Blockade<br/>阻塞区域管理器"]
            BuildingMap["Building Map Server<br/>建筑地图服务器"]
            DoorSupervisor["Door Supervisor<br/>门监督器"]
            LiftSupervisor["Lift Supervisor<br/>电梯监督器"]
        end

        subgraph Fleet["Fleet Adapter 层"]
            FleetAdapter["Fleet Adapter<br/>(rmf_fleet_adapter)<br/>编队适配器"]
            TaskManager["Task Manager<br/>机器人任务队列管理"]
            Negotiator["Negotiator<br/>交通协商器"]
            ScheduleMgr["Schedule Manager<br/>路径提交与调度"]
        end

        subgraph RobotLayer["机器人控制层"]
            RobotCmdHandle["RobotCommandHandle<br/>follow_new_path / stop / dock"]
            RobotAPI["RobotClientAPI<br/>(Python REST API)"]
        end

        subgraph Sim["Gazebo 仿真层"]
            Gazebo["Gazebo Harmonic<br/>物理仿真环境"]
            TinyRobot["TinyRobot<br/>机器人模型"]
        end
    end

    Dashboard <-->|"WebSocket"| API
    API <-->|"WebSocket<br/>server_uri: ws://localhost:8000/_internal"| Dispatcher
    Dispatcher -->|"BidNotice 广播"| FleetAdapter
    FleetAdapter --> TaskManager
    TaskManager --> Negotiator
    TaskManager --> ScheduleMgr
    ScheduleMgr <-->|"路径提交/查询"| TrafficNode
    Blockade --> TrafficNode
    Negotiator <-->|"协商协议"| TrafficNode
    TaskManager --> RobotCmdHandle
    RobotCmdHandle --> RobotAPI
    RobotAPI <-->|"REST API"| Gazebo
    Gazebo --> TinyRobot
    BuildingMap --> FleetAdapter
    DoorSupervisor --> FleetAdapter
    LiftSupervisor --> FleetAdapter
```

---

## 2. 任务提交流程（Web → 机器人）

```mermaid
sequenceDiagram
    actor User as 👤 用户
    participant Dashboard as 🌐 Dashboard<br/>(:3000)
    participant API as 🖥️ API Server<br/>(:8000)
    participant Dispatcher as 📋 Task Dispatcher
    participant Auctioneer as 🔨 Auctioneer<br/>拍卖引擎
    participant FleetA as 🚛 Fleet Adapter A
    participant FleetB as 🚛 Fleet Adapter B
    participant TaskMgr as 📦 Task Manager
    participant Robot as 🤖 Robot

    User->>Dashboard: 1. 在网页端创建任务<br/>(选择取货点/送货点等)
    Dashboard->>API: 2. POST /dispatch_task<br/>JSON 任务描述
    API->>Dispatcher: 3. 发布到 ROS 2 Topic<br/>`task_api_requests`
    
    Note over Dispatcher: 4. 验证 JSON Schema<br/>生成 task_id
    
    Dispatcher->>Auctioneer: 5. 启动拍卖流程<br/>push_bid_notice()
    
    Auctioneer->>FleetA: 6. 广播 BidNotice<br/>(任务描述 + 时间窗口)
    Auctioneer->>FleetB: 6. 广播 BidNotice
    
    Note over FleetA,FleetB: 7. TaskPlanner 评估任务成本<br/>(路径规划 + 时间估算)
    
    FleetA-->>Auctioneer: 8a. 提交 Bid<br/>(预估完成时间、成本)
    FleetB-->>Auctioneer: 8b. 提交 Bid
    
    Note over Auctioneer: 9. QuickestFinishEvaluator<br/>选择最快完成的 Bid
    
    Auctioneer->>FleetA: 10. 发送 DispatchCommand<br/>(Fleet A 中标!)
    
    FleetA->>TaskMgr: 11. 任务入队<br/>添加到机器人任务队列
    
    Note over TaskMgr: 12. 生成行程计划<br/>(Itinerary = 路径 + 时间戳)
    
    TaskMgr->>Robot: 13. follow_new_path()<br/>发送路点序列给机器人
    
    Robot-->>TaskMgr: 14. 路径完成回调<br/>request_completed()
    
    TaskMgr-->>Dispatcher: 15. 任务状态更新<br/>(Queued → Executing → Completed)
    Dispatcher-->>API: 16. WebSocket 推送状态
    API-->>Dashboard: 17. UI 实时更新任务状态
```

---

## 3. 拍卖竞价机制（Task Dispatching Bidding）

```mermaid
flowchart TD
    A["📥 收到任务请求<br/>dispatch_task_request"] --> B{"JSON Schema<br/>验证通过?"}
    B -->|❌ 失败| B1["返回错误响应<br/>success: false"]
    B -->|✅ 通过| C["生成 task_id<br/>category + 计数器/时间戳"]
    C --> D["创建 BidNotice 消息<br/>包含: 任务描述 + 竞标时间窗口"]
    D --> E["Auctioneer 广播 BidNotice<br/>到所有 Fleet Adapter"]
    
    E --> F1["Fleet Adapter A<br/>接收 BidNotice"]
    E --> F2["Fleet Adapter B<br/>接收 BidNotice"]
    E --> F3["Fleet Adapter N<br/>接收 BidNotice"]
    
    F1 --> G1["TaskPlanner 计算<br/>- 路径规划 (A*)<br/>- 时间估算<br/>- 成本计算"]
    F2 --> G2["TaskPlanner 计算<br/>- 路径规划 (A*)<br/>- 时间估算<br/>- 成本计算"]
    F3 --> G3["TaskPlanner 计算<br/>- 路径规划 (A*)<br/>- 时间估算<br/>- 成本计算"]
    
    G1 --> H1{"能完成<br/>任务?"}
    G2 --> H2{"能完成<br/>任务?"}
    G3 --> H3{"能完成<br/>任务?"}
    
    H1 -->|✅| I1["提交 Bid Proposal<br/>- 预计完成时间<br/>- 成本估算<br/>- 机器人 ID"]
    H1 -->|❌| I1x["不提交 Bid"]
    H2 -->|✅| I2["提交 Bid Proposal"]
    H2 -->|❌| I2x["不提交 Bid"]
    H3 -->|✅| I3["提交 Bid Proposal"]
    H3 -->|❌| I3x["不提交 Bid"]
    
    I1 --> J["Auctioneer 收集所有 Bid<br/>在时间窗口内等待"]
    I2 --> J
    I3 --> J
    I1x --> J
    I2x --> J
    I3x --> J
    
    J --> K{"有有效<br/>Bid?"}
    K -->|✅| L["QuickestFinishEvaluator<br/>选择最快完成的 Bid"]
    K -->|❌| L2["任务分配失败<br/>返回错误"]
    
    L --> M["确定获胜者<br/>conclude_bid()"]
    M --> N["发送 DispatchCommand<br/>到获胜的 Fleet Adapter"]
    N --> O["任务状态: Pending → Queued"]
```

---

## 4. 机器人任务执行流程

```mermaid
stateDiagram-v2
    [*] --> Pending: 任务提交到 Dispatcher
    Pending --> Queued: 拍卖完成，分配给 Fleet
    
    state Queued {
        [*] --> WaitingInQueue: 等待机器人空闲
        WaitingInQueue --> TaskAssigned: 机器人可用
    }
    
    Queued --> Executing: TaskManager 开始执行
    
    state Executing {
        [*] --> GenerateItinerary: 生成行程计划
        
        GenerateItinerary --> GoToPickup: Phase 1: 前往取货点
        GoToPickup --> WaitForTraffic: 等待交通许可
        
        WaitForTraffic --> ApproachDispenser: 接近 dispenser
        ApproachDispenser --> PickupItem: Phase 2: 取货
        PickupItem --> GoToDropoff: Phase 3: 前往送货点
        
        GoToDropoff --> ApproachIngestor: 接近 ingestor
        ApproachIngestor --> DropoffItem: Phase 4: 送货
        
        DropoffItem --> AllPhasesComplete: 所有 Phase 完成
    }
    
    Executing --> Completed: 任务成功完成
    Executing --> Failed: 执行失败/取消
    Executing --> Cancelled: 用户取消任务
    
    Completed --> [*]
    Failed --> [*]
    Cancelled --> [*]

    note right of Executing
        每个 Phase 都是一组 Event:
        - GoToPlace: 导航到目标点
        - PickUp: 取货动作
        - DropOff: 送货动作
        - PerformAction: 执行自定义动作
        - WaitFor: 等待条件满足
    end note
```

---

## 5. 多机器人调度与避让机制（Traffic Negotiation）

```mermaid
flowchart TB
    subgraph Scheduler["🚦 Traffic Schedule Node (rmf_traffic_ros2)"]
        ScheduleDB["Schedule Database<br/>所有机器人路径时空数据库"]
        ConflictDetector["冲突检测器<br/>检测时空轨迹重叠"]
        NegotiationMgr["协商管理器<br/>管理多机器人协商会话"]
    end

    subgraph RobotA["🤖 Robot A (Fleet Adapter)"]
        PlanA["路径规划<br/>A* 在导航图上"]
        ParticipantA["Schedule Participant<br/>调度参与者"]
        NegotiatorA["Negotiator<br/>协商代理"]
    end

    subgraph RobotB["🤖 Robot B (Fleet Adapter)"]
        PlanB["路径规划<br/>A* 在导航图上"]
        ParticipantB["Schedule Participant<br/>调度参与者"]
        NegotiatorB["Negotiator<br/>协商代理"]
    end

    PlanA -->|"1. submit_plan()<br/>提交路径+时间戳"| ParticipantA
    ParticipantA -->|"2. 写入路径到"| ScheduleDB
    PlanB -->|"1. submit_plan()"| ParticipantB
    ParticipantB -->|"2. 写入路径到"| ScheduleDB

    ScheduleDB -->|"3. 持续检查"| ConflictDetector
    ConflictDetector -->|"4. 发现冲突!<br/>时空轨迹重叠"| NegotiationMgr
    
    NegotiationMgr -->|"5a. 通知参与协商"| NegotiatorA
    NegotiationMgr -->|"5b. 通知参与协商"| NegotiatorB

    NegotiatorA -->|"6a. 计算替代路径<br/>(延迟/绕行/等待)"| NegotiationMgr
    NegotiatorB -->|"6b. 计算替代路径<br/>(延迟/绕行/等待)"| NegotiationMgr

    NegotiationMgr -->|"7. 评估所有提案<br/>选择全局最优解"| NegotiationMgr
    
    NegotiationMgr -->|"8a. 批准新路径"| ParticipantA
    NegotiationMgr -->|"8b. 批准新路径"| ParticipantB

    ParticipantA -->|"9. 更新机器人路径"| PlanA
    ParticipantB -->|"9. 更新机器人路径"| PlanB
```

### 5.1 交通协商详细流程

```mermaid
sequenceDiagram
    participant RA as 🤖 Robot A
    participant SA as Schedule<br/>Participant A
    participant Schedule as 🚦 Traffic Schedule
    participant SB as Schedule<br/>Participant B
    participant RB as 🤖 Robot B

    Note over RA,RB: 正常状态：各自规划并提交路径

    RA->>SA: 任务需要新路径
    SA->>SA: A* 规划路径<br/>附带时间戳
    SA->>Schedule: submit(Itinerary_A)

    RB->>SB: 任务需要新路径
    SB->>SB: A* 规划路径
    SB->>Schedule: submit(Itinerary_B)

    Note over Schedule: 将路径写入 Schedule Database<br/>检测时空冲突

    Schedule->>Schedule: 🔴 发现冲突!<br/>Robot A 和 B 在 t=30s<br/>同一走廊相遇

    Schedule->>SA: 发起协商 Negotiation<br/>TableView: 当前所有路径快照
    Schedule->>SB: 发起协商 Negotiation

    Note over SA,SB: 协商阶段：各方提出替代方案

    SA->>SA: 评估选项:<br/>1. 减速延迟 5s<br/>2. 绕行另一走廊<br/>3. 原地等待
    SA->>Schedule: Proposal: 延迟 5s

    SB->>SB: 评估选项:<br/>1. 加速通过<br/>2. 绕行<br/>3. 原地等待
    SB->>Schedule: Proposal: 绕行另一走廊

    Note over Schedule: 评估所有提案<br/>选择全局代价最小的方案

    Schedule->>Schedule: ✅ 选择方案:<br/>Robot A 延迟 5s<br/>Robot B 保持原路线

    Schedule->>SA: 批准: 延迟方案
    Schedule->>SB: 批准: 保持原路线

    SA->>RA: 更新路径<br/>所有路点时间戳 +5s
    SB->>RB: 路径不变

    Note over RA,RB: 🟢 冲突解决!<br/>两机器人无碰撞执行任务
```

### 5.2 避让策略类型

```mermaid
graph LR
    subgraph Strategies["避让策略"]
        A["⏱️ 时间延迟<br/>推迟出发/减速<br/>使通过时间错开"]
        B["🔄 路径绕行<br/>选择替代路线<br/>绕过冲突区域"]
        C["⏸️ 原地等待<br/>在安全点等待<br/>直到冲突解除"]
        D["🚫 车道封闭<br/>临时封闭某条车道<br/>强制绕行"]
    end

    subgraph Decision["调度决策依据"]
        E["最小化总延迟"]
        F["最小化额外路程"]
        G["优先级 (Priority)"]
        H["任务紧急度"]
    end

    A --> Decision
    B --> Decision
    C --> Decision
    D --> Decision
```

---

## 6. 数据流全景图

```mermaid
graph LR
    subgraph Input["📥 输入"]
        W1["Web Dashboard<br/>dispatch_task_request JSON"]
        W2["命令行脚本<br/>dispatch_delivery.py"]
        W3["自定义程序<br/>ROS 2 Topic 发布"]
    end

    subgraph Processing["⚙️ 处理"]
        P1["JSON Schema<br/>验证"]
        P2["Auctioneer<br/>竞价拍卖"]
        P3["TaskPlanner<br/>路径+成本计算"]
        P4["Schedule<br/>交通调度"]
        P5["Negotiator<br/>冲突协商"]
    end

    subgraph Output["📤 输出"]
        O1["RobotCommandHandle<br/>follow_new_path()"]
        O2["Gazebo 仿真<br/>机器人移动"]
        O3["WebSocket<br/>任务状态推送"]
        O4["RViz<br/>可视化显示"]
    end

    W1 --> P1
    W2 --> P1
    W3 --> P1
    P1 --> P2
    P2 --> P3
    P3 --> P4
    P4 --> P5
    P5 --> P4
    P4 --> O1
    O1 --> O2
    P2 --> O3
    P4 --> O4
```

---

## 7. 您的启动命令对应的节点拓扑

根据您的启动命令：

```bash
# 命令 1: API Server (Docker)
sudo docker run --rm -it --network host \
  ghcr.io/open-rmf/rmf-web/api-server:jazzy-nightly

# 命令 2: Dashboard (Docker)  
sudo docker run --rm -it --network host \
  ghcr.io/open-rmf/rmf-web/demo-dashboard:jazzy-nightly

# 命令 3: ROS 2 仿真系统
ros2 launch rmf_demos_gz office.launch.xml \
  server_uri:="ws://localhost:8000/_internal"
```

```mermaid
graph TB
    subgraph Docker1["Docker: rmf-web/api-server"]
        APIServer["API Server<br/>Port 8000<br/>WebSocket + REST"]
    end

    subgraph Docker2["Docker: rmf-web/demo-dashboard"]
        WebUI["Demo Dashboard<br/>Port 3000<br/>React SPA"]
    end

    subgraph Host["宿主机: ROS 2 + Gazebo"]
        Dispatcher["rmf_task_ros2<br/>Task Dispatcher<br/>← 通过 WebSocket 连接 API Server"]
        TrafficNode["rmf_traffic_ros2<br/>Traffic Schedule Node"]
        FleetAdapter["rmf_demos_fleet_adapter<br/>Fleet Adapter (Python)"]
        Gazebo["Gazebo Harmonic<br/>Office World 仿真"]
    end

    WebUI <-->|"HTTP/WebSocket<br/>:3000 → :8000"| APIServer
    APIServer <-->|"WebSocket<br/>ws://localhost:8000/_internal"| Dispatcher
    Dispatcher -->|"ROS 2 Topic<br/>dispatch_command"| FleetAdapter
    FleetAdapter <-->|"ROS 2<br/>schedule participant"| TrafficNode
    FleetAdapter -->|"REST API<br/>navigate / stop"| Gazebo
```

---

## 8. 关键 ROS 2 通信接口汇总

| 通信方式 | 接口名称 | 方向 | 说明 |
|---------|---------|------|------|
| **Topic** | `task_api_requests` | Web → Dispatcher | 接收任务请求 (JSON) |
| **Topic** | `task_api_responses` | Dispatcher → Web | 返回任务响应 |
| **Topic** | `dispatch_command` | Dispatcher → FleetAdapter | 分发任务命令 |
| **Topic** | `dispatch_ack` | FleetAdapter → Dispatcher | 任务确认 |
| **Topic** | `dispatch_states` | Dispatcher → 外部 | 任务状态广播 |
| **Topic** | `bid_notice` | Auctioneer → FleetAdapter | 竞标通知 |
| **Topic** | `bid_proposal` | FleetAdapter → Auctioneer | 竞标提案 |
| **Service** | `submit_task` | 外部 → Dispatcher | 旧版任务提交接口 |
| **Service** | `cancel_task` | 外部 → Dispatcher | 取消任务 |
| **WebSocket** | `ws://localhost:8000/_internal` | API Server ↔ Dispatcher | 双向实时通信 |

---

## 9. 任务状态机

```mermaid
stateDiagram-v2
    [*] --> Pending: submit_task()
    
    Pending --> Queued: 拍卖成功<br/>Bid 被接受
    
    Pending --> Failed: 拍卖失败<br/>无有效 Bid
    
    Queued --> Executing: TaskManager<br/>开始执行
    
    Executing --> Completed: 所有 Phase 成功
    
    Executing --> Failed: 执行出错<br/>(导航失败等)
    
    Executing --> Cancelled: cancel_task()
    
    Queued --> Cancelled: cancel_task()
    
    Completed --> [*]
    Failed --> [*]
    Cancelled --> [*]

    note right of Executing
        执行中会经过多个 Phase:
        - GoToPlace
        - PickUp / DropOff
        - PerformAction
        - WaitFor
        每个 Phase 有独立的状态:
        Standby→Underway→Completed
    end note
```

---

## 总结

RMF 的任务流转核心可以概括为 **"提交 → 拍卖 → 分配 → 规划 → 协商 → 执行"** 六个阶段：

1. **提交**：用户在 Web Dashboard 创建任务，通过 API Server 转换为 ROS 2 消息
2. **拍卖**：Task Dispatcher 的 Auctioneer 向所有 Fleet Adapter 发起竞标，选择最快完成的机器人
3. **分配**：获胜的 Fleet Adapter 将任务加入对应机器人的任务队列
4. **规划**：TaskManager 将任务分解为 Phase/Event 序列，生成带时间戳的路径
5. **协商**：Traffic Schedule Node 检测多机器人路径冲突，通过 Negotiator 协商解决
6. **执行**：RobotCommandHandle 将路径发送给机器人（仿真/真实），机器人执行任务并回报状态
