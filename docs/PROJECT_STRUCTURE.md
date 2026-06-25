# HarmonyOS 课表日程助手工程文件说明

## 1. 基础工程来源

本项目基于华为 HarmonyOS Codelabs 开源样例工程 `HealthyLife` 二次开发，原工程主要用于展示健康生活类应用的 ArkTS 页面、关系型数据库、服务卡片、路由和模块化工程组织方式。

原始仓库：

- GitCode 项目：`https://gitcode.com/HarmonyOS_Codelabs/HealthyLife.git`
- 本地工程目录：`C:\Users\Lenovo\HealthyLife`
- 开发工具：DevEco Studio
- 主要语言：ArkTS / TypeScript

## 2. 工程整体结构

```text
HealthyLife
├─ AppScope/                         # 应用级资源和配置
├─ commons/common/                   # 公共模块：数据模型、数据库、工具类、常量
├─ features/healthylife/             # 主业务功能模块：页面、组件、路由、状态管理
├─ products/default/                 # 默认产品入口：Ability、权限、模块配置
├─ docs/                             # 作业文档和录屏材料
├─ oh-package.json5                  # 工程依赖配置
├─ build-profile.json5               # 构建配置
└─ README.md                         # 项目说明
```

## 3. 入口模块说明

### 3.1 products/default

`products/default` 是应用默认入口模块，主要负责启动应用和声明权限。

关键文件：

- `products/default/src/main/ets/entryability/EntryAbility.ets`
  - 应用启动入口。
  - 初始化关系型数据库。
  - 初始化页面所需的基础数据。
  - 对新增表字段进行兼容处理。

- `products/default/src/main/module.json5`
  - 声明应用模块信息。
  - 配置网络访问权限、提醒权限等。
  - AI 后端和系统通知能力需要依赖这里的权限声明。

## 4. 公共模块 commons/common

`commons/common` 保存项目可复用的基础能力，包括数据模型、数据库表访问、工具函数和常量。

### 4.1 数据模型

路径：`commons/common/src/main/ets/model/database`

主要模型：

- `CourseInfo.ets`
  - 表示课程信息。
  - 字段包括课程名、星期、开始时间、结束时间、地点、重复周期。

- `StudyTaskInfo.ets`
  - 表示 DDL 类任务。
  - 字段包括标题、所属课程、截止日期、截止时间、预计用时、优先级、备注、完成状态。

- `PlanTaskInfo.ets`
  - 表示普通任务。
  - 字段包括任务标题、所属课程、预计用时、优先级、备注、计划日期、完成状态。

- `HabitInfo.ets`
  - 表示常规习惯。
  - 字段包括事项名称、用时、是否固定时间、固定时间、提醒 ID、今日打卡状态、连续打卡天数、累计打卡次数。

- `DayInfo.ets`
  - 表示日历中某一天的完成进度。
  - `targetTaskNum` 表示当天总任务数。
  - `finTaskNum` 表示当天完成任务数。
  - `getProgressImg()` 根据完成率显示日历徽章。

### 4.2 数据库表访问层

路径：`commons/common/src/main/ets/database/tables`

主要文件：

- `CourseInfoApi.ets`
  - 课程增删改查。
  - 支持按星期查询课程。

- `StudyTaskInfoApi.ets`
  - DDL 任务增删改查。
  - 支持按完成状态查询。

- `PlanTaskInfoApi.ets`
  - 普通任务增删改查。
  - 支持按计划日期和完成状态查询。
  - 支持推迟任务到指定日期。

- `HabitInfoApi.ets`
  - 常规习惯增删改查。
  - 结合打卡表返回今日打卡、连续天数、累计次数。

- `HabitCheckInInfoApi.ets`
  - 新增的习惯打卡记录表访问层。
  - 支持打卡、取消打卡、统计连续天数和累计次数。

- `DayInfoApi.ets`
  - 日历完成状态保存。
  - 当前版本会根据普通任务完成情况写入每天的徽章进度。

### 4.3 数据库常量

路径：`commons/common/src/main/ets/constants/RdbConstants.ets`

该文件维护所有数据库表名和字段定义。新增功能涉及的表包括：

- `courseInfo`：课程表。
- `studyTaskInfo`：DDL 表。
- `planTaskInfo`：普通任务表。
- `habitInfo`：常规习惯表。
- `habitCheckInInfo`：习惯打卡记录表。

### 4.4 工具类

路径：`commons/common/src/main/ets/utils`

主要工具：

- `SmartScheduleUtils.ets`
  - 本地智能排序工具。
  - 在 AI 后端不可用时，根据课程、DDL、任务、习惯生成本地日程建议。

- `agent/HabitReminderUtils.ets`
  - 常规习惯固定时间提醒工具。
  - 使用 HarmonyOS reminderAgentManager 发布提醒。

## 5. 主功能模块 features/healthylife

`features/healthylife` 是应用主要页面和组件所在模块。

### 5.1 页面入口

- `features/healthylife/src/main/ets/pages/HealthyLifePage.ets`
  - 主页面入口。
  - 提供全局 `HomeStore` 和 `AchievementStore`。
  - 注册路由页面。

### 5.2 首页状态管理

- `features/healthylife/src/main/ets/viewmodel/HomeStore.ets`
  - 管理当前日期、当前周日历、课程列表、任务列表、习惯列表。
  - 切换日期时加载对应日期的数据。
  - 根据普通任务完成情况实时计算日历徽章。

- `features/healthylife/src/main/ets/viewmodel/AchievementStore.ets`
  - 管理连续完成天数和成就点亮状态。
  - 现在会从 `dayInfo` 历史完成记录中重新计算最高连续天数。

### 5.3 首页组件

路径：`features/healthylife/src/main/ets/views/home`

主要组件：

- `WeekCalendarComponent.ets`
  - 当前周日历。
  - 展示周一到周日的完成徽章。
  - 点击日期后切换当天课程和任务。

- `CourseListComponent.ets`
  - 显示当天课程。
  - 支持点击课程进入编辑。

- `StudyTaskListComponent.ets`
  - 显示 DDL 任务。

- `PlanTaskListComponent.ets`
  - 显示普通任务。
  - 区分未完成任务和“已完成的任务”。

- `HabitListComponent.ets`
  - 显示常规习惯。
  - 支持每日打卡、取消打卡、连续打卡统计。

- `SmartScheduleComponent.ets`
  - AI 智能排序入口。
  - 调用本地后端接口生成每日任务顺序。

### 5.4 新增/编辑页面

路径：`features/healthylife/src/main/ets/views/task` 和 `features/healthylife/src/main/ets/views/course`

主要页面：

- `AddCourseComponent.ets` / `EditCourseComponent.ets`
  - 添加和编辑课程。
  - 支持多天上课。
  - 支持每周、单周、双周重复。

- `AddStudyTaskComponent.ets` / `EditStudyTaskComponent.ets`
  - 添加和编辑 DDL。
  - 支持优先级、截止时间、预计用时。

- `AddPlanTaskComponent.ets` / `EditPlanTaskComponent.ets`
  - 添加和编辑普通任务。
  - 支持优先级、预计用时、完成状态、推到明天。

- `AddHabitComponent.ets` / `EditHabitComponent.ets`
  - 添加和编辑常规习惯。
  - 支持固定时间和系统提醒。

### 5.5 AI 页面

路径：`features/healthylife/src/main/ets/views/ai`

- `AiChatComponent.ets`
  - 通过 Web 组件跳转本地 AI 对话页面。
  - 便于用户直接和外部大模型进行沟通和调整。

## 6. 路由配置

路径：`features/healthylife/src/main/resources/base/profile/router_map.json`

该文件声明 ArkUI 页面路由，包括新增课程、任务、习惯、AI 对话等页面。主页面通过 `NavPathStack` 跳转到对应组件。

## 7. 工程运行方式

1. 使用 DevEco Studio 打开 `C:\Users\Lenovo\HealthyLife`。
2. 点击 `Build > Clean Project` 清理工程。
3. 选择 HarmonyOS 模拟器或真机。
4. 点击运行按钮。
5. 如需使用 AI 排序，需要先启动本地 Node 后端服务。

## 8. 总结

该工程从 HealthyLife 健康生活样例改造为课表日程助手，主要复用了原工程的 ArkTS 页面结构、数据库工具、日历徽章和成就系统，并在此基础上扩展出课程管理、DDL 管理、普通任务、常规习惯、AI 智能排序、打卡成就等功能。
