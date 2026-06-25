/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { BusinessError } from '@kit.BasicServicesKit';
import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';
import { http } from '@kit.NetworkKit';
import { CommonConstants as Const } from 'common';
import { DailyPlanItem, SmartScheduleUtils } from 'common/src/main/ets/utils/SmartScheduleUtils';
import { HomeStore } from '../../viewmodel/HomeStore';

const AI_SCHEDULE_URL: string = 'http://172.24.36.58:3000/api/schedule';
const REMIND_BEFORE_MINUTES: number = 5;

interface AiPlanItem {
  title?: string;
  type?: string;
  time?: string;
  reason?: string;
}

interface AiScheduleResponse {
  plan?: AiPlanItem[];
}

interface AiSchedulePayload {
  currentDate: string;
  courses: Object[];
  ddls: Object[];
  tasks: Object[];
  habits: Object[];
}

interface TimeRange {
  start: number;
  end: number;
}

@Component
export struct SmartScheduleComponent {
  @Consume homeStore: HomeStore;
  @State planList: DailyPlanItem[] = [];
  @State statusText: string = '点击生成，让 AI 安排今天的顺序';
  @State isGenerating: boolean = false;

  build() {
    Column() {
      Row() {
        Text('今日智能顺序')
          .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('app.float.default_20'))

        Blank()

        Button(this.isGenerating ? '生成中' : '生成')
          .buttonStyle(ButtonStyleMode.NORMAL)
          .height($r('app.float.default_32'))
          .fontSize($r('app.float.default_14'))
          .fontColor($r('app.color.text_font_color'))
          .backgroundColor($r('sys.color.background_primary'))
          .enabled(!this.isGenerating)
          .onClick(() => {
            this.generatePlan();
          })
      }
      .width(Const.THOUSANDTH_1000)
      .padding({
        left: $r('app.float.default_16'),
        right: $r('app.float.default_16'),
        bottom: $r('app.float.default_8')
      })

      if (this.planList.length > 0) {
        Column() {
          ForEach(this.planList, (item: DailyPlanItem, index: number) => {
            this.planItemBuilder(item, index)
          }, (item: DailyPlanItem, index: number) => `${index}-${item.title}-${item.itemType}`)
        }
        .width(Const.THOUSANDTH_1000)
        .padding({
          left: $r('app.float.default_16'),
          right: $r('app.float.default_16')
        })
      }

      Text(this.statusText)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('app.float.default_14'))
        .width(Const.THOUSANDTH_940)
        .margin({ bottom: $r('app.float.default_8') })
    }
    .width(Const.THOUSANDTH_1000)
    .padding({ top: $r('app.float.default_24') })
  }

  @Builder
  planItemBuilder(item: DailyPlanItem, index: number) {
    Row() {
      Text(`${index + 1}`)
        .fontColor(Color.White)
        .fontSize($r('app.float.default_14'))
        .textAlign(TextAlign.Center)
        .width($r('app.float.default_28'))
        .height($r('app.float.default_28'))
        .borderRadius($r('app.float.default_14'))
        .backgroundColor($r('app.color.text_font_color'))
        .margin({ right: $r('app.float.default_12') })

      Column() {
        Row() {
          Text(item.title)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('app.float.default_16'))
            .fontWeight(FontWeight.Medium)
            .layoutWeight(Const.FLEX_GROW_1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)

          Text(item.itemType)
            .fontColor($r('app.color.text_font_color'))
            .fontSize($r('app.float.default_12'))
        }
        .width(Const.THOUSANDTH_1000)

        Text(item.detail)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('app.float.default_12'))
          .width(Const.THOUSANDTH_1000)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
          .margin({ top: $r('app.float.default_4') })
      }
      .layoutWeight(Const.FLEX_GROW_1)
    }
    .width(Const.THOUSANDTH_1000)
    .borderRadius($r('app.float.default_16'))
    .padding($r('app.float.default_12'))
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ bottom: $r('app.float.default_12') })
  }

  async generatePlan(): Promise<void> {
    if (this.isGenerating) {
      return;
    }

    this.isGenerating = true;
    this.statusText = '正在请求 AI 安排...';

    try {
      this.planList = await this.requestAiPlan();
      await this.createPlanReminders();
      this.statusText = `AI 已生成今日顺序，已设置开始前 ${REMIND_BEFORE_MINUTES} 分钟提醒`;
    } catch (error) {
      let err = error as BusinessError;
      console.error(`AI schedule failed. Code: ${err.code}, message: ${err.message}`);
      this.planList = this.buildLocalPlanWithTime();
      await this.createPlanReminders();
      this.statusText = `AI 暂时不可用，已使用本地排序，并设置开始前 ${REMIND_BEFORE_MINUTES} 分钟提醒`;
    } finally {
      this.isGenerating = false;
    }
  }

  requestAiPlan(): Promise<DailyPlanItem[]> {
    return new Promise((resolve, reject) => {
      let httpRequest = http.createHttp();
      httpRequest.request(AI_SCHEDULE_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(this.buildAiPayload()),
        connectTimeout: 10000,
        readTimeout: 30000
      }, (err: BusinessError, data: http.HttpResponse) => {
        httpRequest.destroy();
        if (err) {
          reject(err);
          return;
        }

        if (data.responseCode !== 200) {
          reject(new Error(`AI server status ${data.responseCode}`));
          return;
        }

        try {
          let responseText = data.result as string;
          let aiResponse = JSON.parse(responseText) as AiScheduleResponse;
          resolve(this.convertAiPlan(aiResponse));
        } catch (parseError) {
          reject(parseError);
        }
      });
    });
  }

  buildAiPayload(): AiSchedulePayload {
    return {
      currentDate: this.homeStore.currentDate,
      courses: this.homeStore.courseList,
      ddls: this.homeStore.studyTaskList,
      tasks: this.homeStore.planTaskList,
      habits: this.homeStore.habitList
    };
  }

  convertAiPlan(aiResponse: AiScheduleResponse): DailyPlanItem[] {
    if (!aiResponse.plan || aiResponse.plan.length === 0) {
      throw new Error('AI plan is empty.');
    }

    let result: DailyPlanItem[] = [];
    for (let i = 0; i < aiResponse.plan.length; i++) {
      let item = aiResponse.plan[i];
      let title = item.title || '未命名事项';
      let itemType = item.type || 'AI';
      let detail = `${item.time || '时间待定'} ${item.reason || ''}`;
      result.push(new DailyPlanItem(title, detail, itemType, i));
    }
    return result;
  }

  buildLocalPlanWithTime(): DailyPlanItem[] {
    let baseList = SmartScheduleUtils.buildTodayPlan(this.homeStore.courseList, this.homeStore.studyTaskList,
      this.homeStore.planTaskList, this.homeStore.habitList, this.homeStore.currentDate);
    let cursor = 480;
    let result: DailyPlanItem[] = [];

    for (let i = 0; i < baseList.length; i++) {
      let item = baseList[i];
      let start = cursor;
      let end = cursor + 60;
      if (item.detail.includes('-')) {
        let first = item.detail.split(' ')[0];
        let range = first.split('-');
        if (range.length === 2) {
          start = this.timeToMinutes(range[0]);
          end = this.timeToMinutes(range[1]);
          cursor = end + 10;
        }
      } else {
        cursor = end + 10;
      }
      let timeRange = `${this.minutesToTime(start)}-${this.minutesToTime(end)}`;
      result.push(new DailyPlanItem(item.title, `${timeRange} ${item.detail}`, item.itemType, i));
    }
    return result;
  }

  async createPlanReminders(): Promise<void> {
    for (let item of this.planList) {
      let range = this.parseTimeRange(item.detail);
      if (!range) {
        continue;
      }
      let remindAt = Math.max(0, range.start - REMIND_BEFORE_MINUTES);
      await this.publishReminder(item, remindAt, range.start);
    }
  }

  async publishReminder(item: DailyPlanItem, remindAt: number, startAt: number): Promise<void> {
    let request: reminderAgentManager.ReminderRequestAlarm = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
      hour: Math.floor(remindAt / 60),
      minute: remindAt % 60,
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
      snoozeTimes: 1,
      timeInterval: 5 * 60,
      title: `即将开始：${item.title}`,
      content: `${this.minutesToTime(startAt)} 开始，请准备处理 ${item.title}`,
      expiredContent: '日程提醒已过期',
      snoozeContent: '稍后提醒',
      slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION
    };

    try {
      await reminderAgentManager.publishReminder(request);
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Publish reminder failed. Code: ${err.code}, message: ${err.message}`);
    }
  }

  parseTimeRange(text: string): TimeRange | undefined {
    let match = text.match(/(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})/);
    if (!match) {
      return undefined;
    }
    let start = Number(match[1]) * 60 + Number(match[2]);
    let end = Number(match[3]) * 60 + Number(match[4]);
    if (end <= start) {
      return undefined;
    }
    return { start, end };
  }

  timeToMinutes(time: string): number {
    let parts = time.split(':');
    if (parts.length !== 2) {
      return 480;
    }
    return Number(parts[0]) * 60 + Number(parts[1]);
  }

  minutesToTime(value: number): string {
    let hour = Math.floor(value / 60);
    let minute = value % 60;
    let hourText = hour < 10 ? `0${hour}` : `${hour}`;
    let minuteText = minute < 10 ? `0${minute}` : `${minute}`;
    return `${hourText}:${minuteText}`;
  }
}
