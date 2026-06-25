/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

export class HabitInfo {
  id: number;
  name: string;
  estimateMinutes: number;
  isFixedTime: boolean;
  fixedTime: string;
  isDone: boolean;
  reminderId: number;
  todayDone: boolean;
  currentStreak: number;
  totalCheckIn: number;

  constructor(id: number, name: string, estimateMinutes: number, isFixedTime: boolean, fixedTime: string,
    isDone: boolean, reminderId: number, todayDone: boolean = false, currentStreak: number = 0,
    totalCheckIn: number = 0) {
    this.id = id;
    this.name = name;
    this.estimateMinutes = estimateMinutes;
    this.isFixedTime = isFixedTime;
    this.fixedTime = fixedTime;
    this.isDone = isDone;
    this.reminderId = reminderId;
    this.todayDone = todayDone;
    this.currentStreak = currentStreak;
    this.totalCheckIn = totalCheckIn;
  }

  toString(): string {
    return `HabitInfo[` +
      `id: ${this.id}, ` +
      `name: ${this.name}, ` +
      `estimateMinutes: ${this.estimateMinutes}, ` +
      `isFixedTime: ${this.isFixedTime}, ` +
      `fixedTime: ${this.fixedTime}, ` +
      `isDone: ${this.isDone}, ` +
      `reminderId: ${this.reminderId}, ` +
      `todayDone: ${this.todayDone}, ` +
      `currentStreak: ${this.currentStreak}, ` +
      `totalCheckIn: ${this.totalCheckIn}` +
      `]`;
  }
}