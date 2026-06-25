# 新增功能说明文档

## 1. 项目目标

本次二次开发目标是将原 HealthyLife 样例改造成一个面向学生的课表日程助手。应用核心目标是把课程、DDL、普通任务、常规习惯和 AI 智能排序整合到同一个日历视图中，帮助学生安排每天要做的事情。

## 2. 新增功能总览

本项目在基础工程上新增和改造了以下能力：

1. 手动课程管理。
2. 多天课程选择。
3. 单周 / 双周 / 每周重复规则。
4. DDL 与普通任务分离。
5. 普通任务优先级、预计用时、备注。
6. 任务按日期显示，可提前安排未来任务。
7. 任务完成后进入“已完成的任务”栏目。
8. 任务一键推到明天。
9. 当前周日历徽章实时显示任务完成率。
10. 连续完成任务成就系统。
11. 常规习惯模块。
12. 常规习惯固定时段系统提醒。
13. 习惯每日打卡记录。
14. 习惯连续打卡和累计打卡统计。
15. AI 智能排序每日安排。
16. AI 对话页面入口。

## 3. 课程管理功能

### 3.1 功能描述

用户可以手动录入课程信息，包括：

- 课程名。
- 上课星期。
- 开始时间。
- 结束时间。
- 地点。
- 重复周期。

### 3.2 多天课程

原始需求中，课程不能只选择周一到周日中的一天，因为很多课程一周会出现多次。现在添加课程时支持选择多个星期，例如同一门课可以同时选择周二和周四。

### 3.3 重复周期

课程重复周期支持：

- 每周。
- 单周。
- 双周。

这为后续导入 WakeUp 课程表或学校课表提供了基础。

### 3.4 相关文件

- `features/healthylife/src/main/ets/views/course/AddCourseComponent.ets`
- `features/healthylife/src/main/ets/views/course/EditCourseComponent.ets`
- `commons/common/src/main/ets/model/database/CourseInfo.ets`
- `commons/common/src/main/ets/database/tables/CourseInfoApi.ets`

## 4. DDL 与普通任务分离

### 4.1 DDL 模块

DDL 用于记录有明确截止日期和截止时间的事项，例如作业、实验报告、课堂派任务。

字段包括：

- 标题。
- 所属课程。
- 截止日期。
- 截止时间。
- 预计所需时间。
- 优先级。
- 备注。
- 完成状态。

### 4.2 普通任务模块

普通任务用于记录没有严格 DDL 的学习任务，例如复习、整理笔记、预习。

字段包括：

- 任务标题。
- 所属课程。
- 预计所需时间。
- 优先级。
- 备注。
- 计划日期。
- 完成状态。

### 4.3 相关文件

- `features/healthylife/src/main/ets/views/task/AddStudyTaskComponent.ets`
- `features/healthylife/src/main/ets/views/task/EditStudyTaskComponent.ets`
- `features/healthylife/src/main/ets/views/task/AddPlanTaskComponent.ets`
- `features/healthylife/src/main/ets/views/task/EditPlanTaskComponent.ets`
- `features/healthylife/src/main/ets/views/home/StudyTaskListComponent.ets`
- `features/healthylife/src/main/ets/views/home/PlanTaskListComponent.ets`
- `commons/common/src/main/ets/model/database/StudyTaskInfo.ets`
- `commons/common/src/main/ets/model/database/PlanTaskInfo.ets`

## 5. 按日期管理任务

### 5.1 功能描述

用户点击日历上的某一天后，页面显示该日期对应的普通任务。用户可以提前在今天设置未来日期的任务。

### 5.2 完成任务

普通任务标记完成后不会消失，而是移动到“已完成的任务”栏目，用户可以看到当天已经完成了什么。

### 5.3 推到明天

普通任务支持“一键推到明天”。点击后：

1. 任务的计划日期变为后一天。
2. 当前日期任务列表不再显示该任务。
3. 切换到明天后可以看到该任务。
4. 推迟后的任务不计入原日期的完成百分比。

### 5.4 相关文件

- `features/healthylife/src/main/ets/viewmodel/HomeStore.ets`
- `features/healthylife/src/main/ets/views/home/WeekCalendarComponent.ets`
- `features/healthylife/src/main/ets/views/home/PlanTaskListComponent.ets`
- `features/healthylife/src/main/ets/views/task/EditPlanTaskComponent.ets`
- `commons/common/src/main/ets/database/tables/PlanTaskInfoApi.ets`

## 6. 日历完成率和徽章

### 6.1 功能描述

首页日历展示当前周七天。每一天根据该日期普通任务完成情况显示不同徽章：

- 无任务或未完成：未完成图标。
- 部分完成：半完成图标。
- 全部完成：完成图标。

### 6.2 计算规则

每天完成率的计算方式为：

```text
当天总任务数 = 当天未完成普通任务数 + 当天已完成普通任务数
当天完成数 = 当天已完成普通任务数
完成率 = 当天完成数 / 当天总任务数
```

新增任务后，完成率会重新计算；推迟到明天的任务不会算入原日期。

### 6.3 相关文件

- `features/healthylife/src/main/ets/views/home/WeekCalendarComponent.ets`
- `features/healthylife/src/main/ets/viewmodel/HomeStore.ets`
- `commons/common/src/main/ets/model/database/DayInfo.ets`
- `commons/common/src/main/ets/database/tables/DayInfoApi.ets`

## 7. 成就系统

### 7.1 功能描述

成就系统根据历史日历完成记录计算连续完成天数。当用户连续多天完成当天所有普通任务后，对应成就点亮。

当前成就等级包括：

- 连续 3 天。
- 连续 7 天。
- 连续 30 天。
- 连续 50 天。
- 连续 73 天。
- 连续 99 天。

### 7.2 实现方式

成就页打开时，会从 `dayInfo` 表中读取历史日期完成记录，并计算最高连续完成天数。这样即使用户在不同日期之间切换，成就也不会依赖过期缓存。

### 7.3 相关文件

- `features/healthylife/src/main/ets/viewmodel/AchievementStore.ets`
- `features/healthylife/src/main/ets/views/AchievementComponent.ets`
- `features/healthylife/src/main/ets/model/AchievementModel.ets`

## 8. 常规习惯模块

### 8.1 功能描述

常规习惯用于记录每天都要完成的事项，例如背单词、运动、阅读。

字段包括：

- 事项名称。
- 用时。
- 是否固定时段。
- 固定时间。
- 提醒 ID。

### 8.2 系统提醒

如果习惯设置为固定时段，系统会在指定时间发送提醒。

### 8.3 每日打卡

习惯支持每日打卡。打卡记录单独保存在 `habitCheckInInfo` 表中，而不是直接覆盖习惯本身。

### 8.4 统计信息

每个习惯显示：

- 今日是否已打卡。
- 连续打卡天数。
- 累计打卡次数。

### 8.5 相关文件

- `features/healthylife/src/main/ets/views/task/AddHabitComponent.ets`
- `features/healthylife/src/main/ets/views/task/EditHabitComponent.ets`
- `features/healthylife/src/main/ets/views/home/HabitListComponent.ets`
- `commons/common/src/main/ets/model/database/HabitInfo.ets`
- `commons/common/src/main/ets/database/tables/HabitInfoApi.ets`
- `commons/common/src/main/ets/database/tables/HabitCheckInInfoApi.ets`
- `commons/common/src/main/ets/utils/agent/HabitReminderUtils.ets`

## 9. AI 智能排序

### 9.1 功能描述

应用新增 AI 智能排序功能，可以根据当天课程、DDL、普通任务、常规习惯，生成一天中建议的执行顺序。

### 9.2 后端方案

AI 接入采用本地 Node.js 后端代理：

- App 请求本地后端。
- 后端调用外部大模型 API。
- 后端返回排序后的日程。

这样可以避免把 API Key 直接写进鸿蒙 App 端代码，提高安全性。

### 9.3 无 AI 时的兜底

当本地 AI 后端不可用时，应用会使用 `SmartScheduleUtils` 进行本地排序，保证基础功能仍然可用。

### 9.4 相关文件

- `features/healthylife/src/main/ets/views/home/SmartScheduleComponent.ets`
- `features/healthylife/src/main/ets/views/ai/AiChatComponent.ets`
- `commons/common/src/main/ets/utils/SmartScheduleUtils.ets`
- `products/default/src/main/module.json5`

## 10. 新增功能运行演示建议

录屏视频 2 建议展示以下流程：

1. 打开 App 首页。
2. 添加一门课程。
3. 添加一个 DDL。
4. 添加一个普通任务。
5. 切换到未来日期并添加任务。
6. 标记任务完成，查看“已完成的任务”栏目。
7. 查看日历徽章点亮。
8. 添加一个常规习惯。
9. 点击习惯打卡。
10. 打开成就系统，展示连续完成成就。
11. 点击 AI 生成排序，展示智能安排结果。

## 11. 总结

本次新增功能将原本的健康生活样例改造为学生课表日程助手。功能覆盖课程、DDL、普通任务、习惯、提醒、打卡、成就和 AI 排序，形成了一个本地可用、可继续扩展导入 WakeUp 课表和课堂派 DDL 的学习规划应用。
