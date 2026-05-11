本文件是针对 `rmf_demo_maps` 包的软件质量声明，基于 [REP-2004](https://www.ros.org/reps/rep-2004.html) 中的指南。

# `rmf_demo_maps` 质量声明

`rmf_demo_maps` 包声明其处于 **质量等级 3** 类别。
这个声明的主要理由是它作为演示地图资源文件集合的性质。

下面按照 [REP-2004](https://www.ros.org/reps/rep-2004.html) 中列出的各项质量等级 3 包要求，组织了对此声明的详细理由、注释和免责声明。

## 版本策略 [1]

### 版本方案 [1.i]

`rmf_demo_maps` 使用 `semver`，符合 [ROS 2 开发者指南](https://index.ros.org/doc/ros2/Contributing/Developer-Guide/#versioning) 对 ROS Core 包的推荐。

### 版本稳定性 [1.ii]

`rmf_demo_maps` 处于稳定版本，即 `>= 1.0.0`。
当前版本可在其 [package.xml](package.xml) 中找到，其变更历史可在其 [CHANGELOG](CHANGELOG.rst) 中找到。

### 公开 API 声明 [1.iii]

`rmf_demo_maps` 没有公开 API。

### API 稳定性策略 [1.iv]

`rmf_demo_maps` 没有公开 API。

### ABI 稳定性策略 [1.v]

`rmf_demo_maps` 没有公开 API。

### 在已发布 ROS 发行版中的 API 和 ABI 稳定性 [1.vi]

`rmf_demo_maps` 没有公开 API。

## 变更控制流程 [2]

`rmf_demo_maps` 遵循 [ROS 2 开发者指南](https://index.ros.org/doc/ros2/Contributing/Developer-Guide/#package-requirements) 中 ROS Core 包的推荐指南。

### 变更请求 [2.i]

`rmf_demo_maps` 要求所有更改都通过 Pull Request 进行。

### 贡献者来源 [2.ii]

`rmf_demo_maps` 使用 DCO 作为确认贡献者来源的策略。更多信息请参阅 [CONTRIBUTING](../CONTRIBUTING.md)。

### 同行评审政策 [2.iii]

所有 Pull Request 必须至少有 1 次同行评审。

### 持续集成 [2.iv]

所有 Pull Request 必须通过 RMF 支持的所有平台上的 CI。
CI 检查仅验证该包是否能构建。
最近的 CI 结果可在 [工作流页面](https://github.com/open-rmf/rmf_demos/actions) 查看。

### 文档政策 [2.v]

所有 Pull Request 必须在合并前解决相关文档更改。

## 文档 [3]

### 功能文档 [3.i]

`rmf_demo_maps` 在 [父仓库的 README.md 文件](../README.md) 中有文档说明。

### 公开 API 文档 [3.ii]

`rmf_demo_maps` 没有公开 API。

### 许可证 [3.iii]

`rmf_demo_maps` 的许可证为 Apache 2.0，该类型在 [package.xml](package.xml) 清单文件中声明，完整许可证文本在仓库级别 [LICENSE](../LICENSE) 文件中。

该包当前没有需要检查缩略许可证声明的源文件。

### 版权声明 [3.iv]

该包没有受版权保护的源文件。

### 质量声明文档 [3.v]

该质量声明尚未经过外部同行评审，也未注册在任何级别 3 列表中。

## 测试 [4]

### 功能测试 [4.i]

`rmf_demo_maps` 提供的仅是资源文件，因此不需要相关测试。

### 公开 API 测试 [4.ii]

`rmf_demo_maps` 提供的仅是资源文件，因此不需要相关测试。

### 覆盖率 [4.iii]

`rmf_demo_maps` 提供的仅是资源文件，因此不需要相关测试。

### 性能 [4.iv]

`rmf_demo_maps` 提供的仅是资源文件，因此不需要相关测试。

### 代码分析和静态分析 [4.v]

`rmf_demo_maps` 没有需要 lint 或静态分析的文件。

## 依赖关系 [5]

### 直接运行时 ROS 依赖 [5.i]

`rmf_demo_maps` 没有任何必需的直接运行时 ROS 依赖。

### 可选直接运行时 ROS 依赖 [5.ii]

`rmf_demo_maps` 没有任何可选直接运行时 ROS 依赖。

### 直接运行时非 ROS 依赖 [5.iii]

`rmf_demo_maps` 没有任何运行时非 ROS 依赖。

## 平台支持 [6]

作为纯资源包，`rmf_demo_maps` 支持 [REP-2000](https://www.ros.org/reps/rep-2000.html#support-tiers) 中描述的所有一类平台，但目前尚未对每次更改进行全面测试。

## 安全 [7]

### 漏洞披露政策 [7.i]

该包符合 [REP-2006](https://www.ros.org/reps/rep-2006.html) 中的漏洞披露政策。