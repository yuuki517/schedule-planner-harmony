/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { HabitInfo } from '../../model/database/HabitInfo';

const TAG: string = '[HabitReminderUtils]';

export class HabitReminderUtils {
  static async createReminder(habitInfo: HabitInfo): Promise<number> {
    let request = HabitReminderUtils.buildRequest(habitInfo);
    if (!request) {
      return -1;
    }
    try {
      return await reminderAgentManager.publishReminder(request);
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed to publish habit reminder. Code: ${err.code}, message: ${err.message}`);
      return -1;
    }
  }

  static async updateReminder(habitInfo: HabitInfo): Promise<number> {
    if (habitInfo.reminderId === -1) {
      return await HabitReminderUtils.createReminder(habitInfo);
    }
    let request = HabitReminderUtils.buildRequest(habitInfo);
    if (!request) {
      return -1;
    }
    try {
      await reminderAgentManager.updateReminder(habitInfo.reminderId, request);
      return habitInfo.reminderId;
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed to update habit reminder. Code: ${err.code}, message: ${err.message}`);
      return -1;
    }
  }

  static deleteReminder(reminderId: number): void {
    if (reminderId === -1) {
      return;
    }
    reminderAgentManager.cancelReminder(reminderId).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Failed to cancel habit reminder. Code: ${err.code}, message: ${err.message}`);
    });
  }

  static buildRequest(habitInfo: HabitInfo): reminderAgentManager.ReminderRequestAlarm | undefined {
    let timeArr = habitInfo.fixedTime.split(':');
    if (timeArr.length !== 2) {
      return undefined;
    }
    let title = `常规习惯：${habitInfo.name}`;
    return {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
      hour: Number(timeArr[0]),
      minute: Number(timeArr[1]),
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
      actionButton: [
        {
          title: '关闭',
          type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
        },
        {
          title: '稍后提醒',
          type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_SNOOZE
        }
      ],
      wantAgent: {
        pkgName: 'com.huawei.healthylife',
        abilityName: 'EntryAbility'
      },
      ringDuration: 10,
      snoozeTimes: 2,
      timeInterval: 5 * 60,
      title: title,
      content: `${habitInfo.fixedTime} 该完成：${habitInfo.name}`,
      expiredContent: '习惯提醒已过期',
      snoozeContent: '稍后提醒',
      slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION
    };
  }
}