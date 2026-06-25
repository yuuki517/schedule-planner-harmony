/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

export class StudyTaskInfo {
  id: number;
  title: string;
  courseName: string;
  dueDate: string;
  dueTime: string;
  estimateMinutes: number;
  priority: number;
  note: string;
  isDone: boolean;

  constructor(id: number, title: string, courseName: string, dueDate: string, dueTime: string, estimateMinutes: number,
    priority: number, note: string, isDone: boolean) {
    this.id = id;
    this.title = title;
    this.courseName = courseName;
    this.dueDate = dueDate;
    this.dueTime = dueTime;
    this.estimateMinutes = estimateMinutes;
    this.priority = priority;
    this.note = note;
    this.isDone = isDone;
  }

  toString(): string {
    return `StudyTaskInfo[` +
      `id: ${this.id}, ` +
      `title: ${this.title}, ` +
      `courseName: ${this.courseName}, ` +
      `dueDate: ${this.dueDate}, ` +
      `dueTime: ${this.dueTime}, ` +
      `estimateMinutes: ${this.estimateMinutes}, ` +
      `priority: ${this.priority}, ` +
      `note: ${this.note}, ` +
      `isDone: ${this.isDone}` +
      `]`;
  }
}