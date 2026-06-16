/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

export class CourseInfo {
  id: number;
  name: string;
  weekday: number;
  startTime: string;
  endTime: string;
  location: string;
  repeatRule: string;

  constructor(id: number, name: string, weekday: number, startTime: string, endTime: string, location: string,
    repeatRule: string) {
    this.id = id;
    this.name = name;
    this.weekday = weekday;
    this.startTime = startTime;
    this.endTime = endTime;
    this.location = location;
    this.repeatRule = repeatRule;
  }

  toString(): string {
    return `CourseInfo[` +
      `id: ${this.id}, ` +
      `name: ${this.name}, ` +
      `weekday: ${this.weekday}, ` +
      `startTime: ${this.startTime}, ` +
      `endTime: ${this.endTime}, ` +
      `location: ${this.location}, ` +
      `repeatRule: ${this.repeatRule}` +
      `]`;
  }
}