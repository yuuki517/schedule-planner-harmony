# Schedule Planner

## Overview

This project is adapted from the Huawei HarmonyOS Codelab sample HealthyLife. It uses ArkTS declarative UI, HarmonyOS RDB store, weekly calendar views, task lists, time picking, service widgets, and agent-powered reminders to build a student-oriented schedule planner prototype.

The current version converts the original healthy-life check-in tasks into class and study schedule items. Future versions can add timetable import, automatic task scheduling, class locations, start/end time fields, and richer reminder strategies.

## How to Use

1. Users can create up to six types of study schedules: Class, Homework, Reading, Review, Preview, and Evening study.
2. Users can view today's schedule on the home page and mark study items as done.
3. The home page displays today's progress. Progress reaches 100% when all schedule items are completed.
4. Users can tap the plus sign to open Add schedule and add classes or study tasks.
5. Users can edit schedule status, goals, and reminder time on the Edit schedule page.
6. The weekly view helps users check schedule completion across dates.
7. Service widgets can display today's schedule and study progress.
8. Agent-powered reminders can be used before classes, evening study, or important tasks.

## Current Changes

- App name changed from Healthy Life to Schedule Planner.
- Home page title changed to Schedule Planner.
- Home sections changed to Today progress and Today schedule.
- Task types changed to Class, Homework, Reading, Review, Preview, and Evening study.
- Add/edit pages changed to Add schedule, Edit schedule, and Plan setting.
- Service widget labels changed to study schedule related labels.
- Reading goals changed to 10, 20, 30, 50, and 80 pages.
- Default time ranges changed to 08:00 - 12:00 for classes and 19:00 - 22:00 for evening study.

## Next Steps

1. Add a course timetable model with course name, classroom, weekday, start time, and end time.
2. Add timetable import, starting with manual input and later supporting Excel, text, or image recognition.
3. Add automatic scheduling based on free time, due time, and estimated task duration.
4. Add reminder strategies such as 10 minutes before class and before task deadlines.
5. Improve the home page with separate course/task sections and a daily timeline.

## Required Permissions

`ohos.permission.PUBLISH_AGENT_REMINDER`: allows the application to use agent-powered reminders.

## Constraints

1. This sample is only supported on Huawei phones running standard systems.
2. HarmonyOS version: HarmonyOS 6.0.0 Release or later.
3. DevEco Studio version: DevEco Studio 6.0.2 Release or later.
4. HarmonyOS SDK version: HarmonyOS 6.0.2 Release SDK or later.
