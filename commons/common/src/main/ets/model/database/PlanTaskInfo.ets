/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

export class PlanTaskInfo {
  id: number;
  title: string;
  courseName: string;
  estimateMinutes: number;
  priority: number;
  note: string;
  scheduledDate: string;
  isDone: boolean;

  constructor(id: number, title: string, courseName: string, estimateMinutes: number, priority: number, note: string,
    scheduledDate: string, isDone: boolean) {
    this.id = id;
    this.title = title;
    this.courseName = courseName;
    this.estimateMinutes = estimateMinutes;
    this.priority = priority;
    this.note = note;
    this.scheduledDate = scheduledDate;
    this.isDone = isDone;
  }

  toString(): string {
    return `PlanTaskInfo[` +
      `id: ${this.id}, ` +
      `title: ${this.title}, ` +
      `courseName: ${this.courseName}, ` +
      `estimateMinutes: ${this.estimateMinutes}, ` +
      `priority: ${this.priority}, ` +
      `note: ${this.note}, ` +
      `scheduledDate: ${this.scheduledDate}, ` +
      `isDone: ${this.isDone}` +
      `]`;
  }
}
