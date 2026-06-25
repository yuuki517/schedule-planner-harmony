# 作业提交说明

## 1. 仓库信息

GitHub 仓库地址：

```text
https://github.com/yuuki517/schedule-planner-harmony
```

本项目基于华为 HarmonyOS Codelabs 开源工程 `HealthyLife` 二次开发，已经完成基础工程运行录屏、工程结构分析、新增功能开发、新增功能说明文档和新增功能运行录屏。

## 2. 作业要求对应情况

### 要求 1：扒一个开源鸿蒙工程作为基础，录屏虚拟机运行效果，git 提交工程和录屏视频 1，推送到 GitHub

已完成。

- 基础工程：HarmonyOS Codelabs `HealthyLife`
- 基础工程运行录屏：`docs/videos/base.mp4`
- 对应提交：`docs: 添加基础工程运行录屏`

### 要求 2：解析代码工程文件，形成工程文件描述 md 文件 1，git 提交推送到 GitHub

已完成。

- 工程结构文档：`docs/PROJECT_STRUCTURE.md`
- 对应提交：`docs: 添加工程结构分析文档`

### 要求 3：在基础工程上新增功能，形成新增功能文件描述 md 文件 2，录屏虚拟机运行效果，git 提交工程和录屏视频 2，推送到 GitHub

已完成。

- 新增功能文档：`docs/NEW_FEATURES.md`
- 新增功能运行录屏：`docs/videos/after.mp4`
- 对应提交：
  - `feat: 新增课表任务习惯与AI日程功能`
  - `docs: 添加新增功能运行录屏`

## 3. 录屏文件

录屏文件统一放在：

```text
docs/videos/
```

文件说明：

| 文件 | 内容 |
| --- | --- |
| `docs/videos/base.mp4` | 原始 HealthyLife 基础工程运行效果 |
| `docs/videos/after.mp4` | 新增功能后的课表日程助手运行效果 |

`after.mp4` 文件较大，已使用 Git LFS 管理。如果下载仓库后看不到完整视频，请先安装 Git LFS，然后执行：

```bash
git lfs pull
```

## 4. 文档文件

| 文件 | 内容 |
| --- | --- |
| `README.md` | 项目总体说明 |
| `docs/PROJECT_STRUCTURE.md` | 工程文件结构分析 |
| `docs/NEW_FEATURES.md` | 新增功能说明 |
| `docs/HOMEWORK_SUBMISSION.md` | 作业提交对照说明 |

## 5. 关键提交记录

本项目提交次数不少于 3 次，关键提交包括：

```text
docs: 添加工程结构分析文档
feat: 新增课表任务习惯与AI日程功能
docs: 添加基础工程运行录屏
docs: 添加新增功能运行录屏
```

## 6. 新增功能概览

本项目新增了以下功能：

1. 手动课程管理。
2. 多天课程选择。
3. 每周、单周、双周重复周期。
4. DDL 与普通任务分离。
5. 普通任务按日期安排。
6. 任务完成后进入“已完成的任务”栏目。
7. 任务一键推到明天。
8. 当前周任务完成徽章。
9. 连续完成任务成就系统。
10. 常规习惯模块。
11. 习惯固定时段提醒。
12. 习惯每日打卡、连续打卡、累计打卡统计。
13. AI 智能排序每日安排。
14. AI 对话页面入口。

## 7. 运行方式

1. 使用 DevEco Studio 打开项目根目录。
2. 执行 `Build > Clean Project`。
3. 选择模拟器或真机运行。
4. 如需测试 AI 排序，先启动本地后端：

```text
C:\Users\Lenovo\Documents\Codex\2026-06-02\dev-eco\schedule-ai-server\start-server.bat
```
