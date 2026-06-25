# 课表日程助手 Schedule Planner Harmony

## 1. 项目简介

本项目基于华为 HarmonyOS Codelabs 开源工程 `HealthyLife` 二次开发，使用 ArkTS、ArkUI、HarmonyOS 关系型数据库、系统提醒和本地 AI 后端代理，实现一个面向学生的课表日程助手。

应用主要用于管理课程、DDL、普通任务和常规习惯，并根据任务完成情况点亮日历徽章和成就。项目还接入了本地 Node.js AI 后端，用于生成每天的智能排序建议。

## 2. 作业材料

本仓库已包含课程作业所需材料：

| 材料 | 路径 |
| --- | --- |
| 工程结构分析 md 文件 1 | `docs/PROJECT_STRUCTURE.md` |
| 新增功能说明 md 文件 2 | `docs/NEW_FEATURES.md` |
| 基础工程运行录屏 | `docs/videos/base.mp4` |
| 新增功能运行录屏 | `docs/videos/after.mp4` |
| 作业提交说明 | `docs/HOMEWORK_SUBMISSION.md` |

注意：`docs/videos/after.mp4` 使用 Git LFS 管理。克隆仓库后如需下载完整视频，请执行：

```bash
git lfs pull
```

## 3. 基础工程来源

- 原始项目：HarmonyOS Codelabs HealthyLife
- 原始仓库：`https://gitcode.com/HarmonyOS_Codelabs/HealthyLife.git`
- 二次开发仓库：`https://github.com/yuuki517/schedule-planner-harmony`

## 4. 当前主要功能

### 4.1 课程管理

- 手动添加课程。
- 支持课程名、星期、开始时间、结束时间、地点。
- 支持一门课选择多个上课日。
- 支持每周、单周、双周重复。
- 支持编辑已有课程。

### 4.2 DDL 管理

- DDL 与普通任务分开管理。
- 支持标题、所属课程、截止日期、截止时间、预计用时、优先级、备注。
- 适用于作业、实验报告、课堂派任务等有明确截止时间的事项。

### 4.3 普通任务管理

- 支持任务标题、所属课程、预计用时、优先级、备注。
- 支持按日期安排任务。
- 可以提前为未来日期添加任务。
- 标记完成后进入“已完成的任务”栏目，不会直接消失。
- 支持“一键推到明天”。

### 4.4 当前周日历和徽章

- 首页显示当前周周一到周日。
- 每天根据普通任务完成率显示不同徽章。
- 新增任务、完成任务、推迟任务后会重新计算对应日期完成率。

### 4.5 成就系统

- 根据 `dayInfo` 历史完成记录计算最高连续完成天数。
- 支持连续 3 天、7 天、30 天、50 天、73 天、99 天成就。

### 4.6 常规习惯

- 支持添加每天要做的习惯。
- 支持设置用时。
- 支持固定时段和系统提醒。
- 支持每日打卡。
- 显示今日打卡状态、连续打卡天数、累计打卡次数。

### 4.7 AI 智能排序

- 根据当天课程、DDL、普通任务和习惯生成建议执行顺序。
- AI 请求通过本地 Node.js 后端代理转发。
- 当 AI 后端不可用时，应用会使用本地排序兜底。
- 提供 AI 对话页面入口，方便进一步沟通调整计划。

## 5. 工程目录

```text
HealthyLife
├─ AppScope/                         # 应用级资源与配置
├─ commons/common/                   # 公共模块：模型、数据库、工具类
├─ features/healthylife/             # 主业务模块：页面、组件、状态管理
├─ products/default/                 # 默认入口模块：Ability、权限、module 配置
├─ docs/                             # 作业文档与录屏
│  ├─ PROJECT_STRUCTURE.md
│  ├─ NEW_FEATURES.md
│  ├─ HOMEWORK_SUBMISSION.md
│  └─ videos/
│     ├─ base.mp4
│     └─ after.mp4
└─ README.md
```

## 6. 关键文件

| 文件 | 作用 |
| --- | --- |
| `features/healthylife/src/main/ets/viewmodel/HomeStore.ets` | 首页数据状态、日期切换、任务列表刷新 |
| `features/healthylife/src/main/ets/views/home/WeekCalendarComponent.ets` | 当前周日历和徽章展示 |
| `features/healthylife/src/main/ets/views/home/PlanTaskListComponent.ets` | 普通任务和已完成任务列表 |
| `features/healthylife/src/main/ets/views/home/HabitListComponent.ets` | 习惯列表和打卡 |
| `features/healthylife/src/main/ets/views/home/SmartScheduleComponent.ets` | AI 智能排序 |
| `features/healthylife/src/main/ets/viewmodel/AchievementStore.ets` | 连续完成成就计算 |
| `commons/common/src/main/ets/database/tables/PlanTaskInfoApi.ets` | 普通任务数据库访问 |
| `commons/common/src/main/ets/database/tables/HabitCheckInInfoApi.ets` | 习惯打卡数据库访问 |

## 7. 运行方式

1. 使用 DevEco Studio 打开本工程。
2. 点击 `Build > Clean Project`。
3. 选择模拟器或真机运行。
4. 如需使用 AI 排序，先启动本地 AI 后端：

```text
C:\Users\Lenovo\Documents\Codex\2026-06-02\dev-eco\schedule-ai-server\start-server.bat
```

后端启动成功后会显示：

```text
Schedule AI server is running at http://localhost:3000
Health check: http://localhost:3000/health
```

## 8. 后续扩展方向

1. 支持 WakeUp 课程表导入。
2. 支持课堂派、雨课堂 DDL 自动读取。
3. 增加更细粒度的空闲时间计算。
4. 增加可视化时间轴。
5. 将 AI 后端部署到云端，避免本地服务依赖。
