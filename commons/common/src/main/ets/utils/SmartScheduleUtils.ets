/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { CourseInfo } from '../model/database/CourseInfo';
import { HabitInfo } from '../model/database/HabitInfo';
import { PlanTaskInfo } from '../model/database/PlanTaskInfo';
import { StudyTaskInfo } from '../model/database/StudyTaskInfo';

export class DailyPlanItem {
  title: string;
  detail: string;
  itemType: string;
  sortKey: number;

  constructor(title: string, detail: string, itemType: string, sortKey: number) {
    this.title = title;
    this.detail = detail;
    this.itemType = itemType;
    this.sortKey = sortKey;
  }
}

export class SmartScheduleUtils {
  static buildTodayPlan(courseList: CourseInfo[], ddlList: StudyTaskInfo[], taskList: PlanTaskInfo[],
    habitList: HabitInfo[], currentDate: string): DailyPlanItem[] {
    let result: DailyPlanItem[] = [];

    for (let course of courseList) {
      result.push(new DailyPlanItem(course.name, `${course.startTime}-${course.endTime} ${course.location || ''}`,
        '课程', SmartScheduleUtils.timeToMinutes(course.startTime)));
    }

    for (let habit of habitList) {
      let timeSort = habit.isFixedTime ? SmartScheduleUtils.timeToMinutes(habit.fixedTime) : 900;
      let detail = habit.isFixedTime ? `${habit.fixedTime} · ${habit.estimateMinutes}分钟` : `${habit.estimateMinutes}分钟`;
      result.push(new DailyPlanItem(habit.name, detail, '习惯', timeSort + 5));
    }

    for (let ddl of ddlList) {
      let urgency = SmartScheduleUtils.urgencyScore(ddl.dueDate, currentDate);
      let priority = SmartScheduleUtils.priorityScore(ddl.priority);
      result.push(new DailyPlanItem(ddl.title, `${ddl.courseName || '未关联课程'} · ${ddl.dueDate} ${ddl.dueTime}`,
        'DDL', 1200 + urgency + priority + Math.min(ddl.estimateMinutes, 240)));
    }

    for (let task of taskList) {
      let priority = SmartScheduleUtils.priorityScore(task.priority);
      result.push(new DailyPlanItem(task.title, `${task.courseName || '未关联课程'} · ${task.estimateMinutes}分钟`,
        '任务', 1500 + priority + Math.min(task.estimateMinutes, 240)));
    }

    return result.sort((a: DailyPlanItem, b: DailyPlanItem) => a.sortKey - b.sortKey);
  }

  static timeToMinutes(time: string): number {
    let parts = time.split(':');
    if (parts.length !== 2) {
      return 900;
    }
    return Number(parts[0]) * 60 + Number(parts[1]);
  }

  static priorityScore(priority: number): number {
    if (priority === 1) {
      return 0;
    }
    if (priority === 3) {
      return 80;
    }
    return 40;
  }

  static urgencyScore(dueDate: string, currentDate: string): number {
    let diff = SmartScheduleUtils.daysBetween(currentDate, dueDate);
    if (diff <= 0) {
      return 0;
    }
    if (diff <= 1) {
      return 20;
    }
    if (diff <= 3) {
      return 60;
    }
    return 120;
  }

  static daysBetween(startDate: string, endDate: string): number {
    let start = SmartScheduleUtils.parseDate(startDate);
    let end = SmartScheduleUtils.parseDate(endDate);
    return Math.floor((end.getTime() - start.getTime()) / (24 * 60 * 60 * 1000));
  }

  static parseDate(date: string): Date {
    const year = Number(date.substring(0, 4));
    const month = Number(date.substring(4, 6)) - 1;
    const day = Number(date.substring(6, 8));
    return new Date(year, month, day);
  }
}