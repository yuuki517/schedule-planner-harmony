/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { CommonConstants as Const, PlanTaskInfo, convertDate2Str, convertStr2Date } from 'common';
import PlanTaskInfoApi from 'common/src/main/ets/database/tables/PlanTaskInfoApi';
import DayInfoApi from 'common/src/main/ets/database/tables/DayInfoApi';
import { PreferencesUtils } from 'common/src/main/ets/utils/PreferencesUtils';
import { AchievementStore } from '../../viewmodel/AchievementStore';
import { HomeStore, updatePlanTaskList } from '../../viewmodel/HomeStore';

@Builder
export function editPlanTaskBuilder(_name: string, param: PlanTaskInfo) {
  EditPlanTaskComponent({
    taskInfo: param,
    title: param.title,
    courseName: param.courseName,
    estimateMinutes: param.estimateMinutes.toString(),
    priority: param.priority,
    note: param.note,
    scheduledDate: param.scheduledDate
  });
}

@Component
export struct EditPlanTaskComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @Consume homeStore: HomeStore;
  @Consume achievementStore: AchievementStore;
  taskInfo: PlanTaskInfo = new PlanTaskInfo(0, '', '', 0, 2, '', '', false);
  @State title: string = '';
  @State courseName: string = '';
  @State estimateMinutes: string = '60';
  @State priority: number = 2;
  @State note: string = '';
  @State scheduledDate: string = '';

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: $r('app.float.default_12') }) {
          this.labelBuilder('任务标题')
          TextInput({ placeholder: '例如：整理英语笔记', text: this.title })
            .planTaskEditInputStyle()
            .onChange((value: string) => { this.title = value; })

          this.labelBuilder('所属课程')
          TextInput({ placeholder: '例如：大学英语', text: this.courseName })
            .planTaskEditInputStyle()
            .onChange((value: string) => { this.courseName = value; })

          this.labelBuilder('预计所需时间长度（分钟）')
          TextInput({ placeholder: '例如：45', text: this.estimateMinutes })
            .planTaskEditInputStyle()
            .onChange((value: string) => { this.estimateMinutes = value; })

          this.labelBuilder('优先级')
          Row() {
            this.priorityButtonBuilder('高', 1)
            this.priorityButtonBuilder('普通', 2)
            this.priorityButtonBuilder('低', 3)
          }
          .width(Const.THOUSANDTH_940)

          this.labelBuilder('备注')
          TextInput({ placeholder: '可选', text: this.note })
            .planTaskEditInputStyle()
            .onChange((value: string) => { this.note = value; })

          Button('保存修改')
            .buttonStyle(ButtonStyleMode.NORMAL)
            .width(Const.THOUSANDTH_940)
            .height($r('app.float.default_44'))
            .backgroundColor($r('app.color.text_font_color'))
            .fontColor(Color.White)
            .margin({ top: $r('app.float.default_16') })
            .onClick(async () => {
              await this.saveTask(false);
            })

          Button('标记完成')
            .buttonStyle(ButtonStyleMode.NORMAL)
            .width(Const.THOUSANDTH_940)
            .height($r('app.float.default_44'))
            .fontColor($r('app.color.text_font_color'))
            .backgroundColor($r('sys.color.background_primary'))
            .onClick(async () => {
              await this.saveTask(true);
            })

          Button('推到明天')
            .buttonStyle(ButtonStyleMode.NORMAL)
            .width(Const.THOUSANDTH_940)
            .height($r('app.float.default_44'))
            .fontColor($r('app.color.text_font_color'))
            .backgroundColor($r('sys.color.background_primary'))
            .onClick(async () => {
              await this.postponeToTomorrow();
            })

          Button('删除任务')
            .buttonStyle(ButtonStyleMode.NORMAL)
            .width(Const.THOUSANDTH_940)
            .height($r('app.float.default_44'))
            .fontColor($r('app.color.button_red'))
            .backgroundColor($r('sys.color.background_primary'))
            .onClick(async () => {
              await this.deleteTask();
            })
        }
        .width(Const.THOUSANDTH_1000)
        .padding({
          top: $r('app.float.default_56'),
          left: $r('app.float.default_16'),
          right: $r('app.float.default_16'),
          bottom: $r('app.float.default_40')
        })
      }
      .width(Const.THOUSANDTH_1000)
      .height(Const.THOUSANDTH_1000)
    }
    .size({ width: Const.THOUSANDTH_1000, height: Const.THOUSANDTH_1000 })
    .title('编辑任务')
    .padding({
      top: $r('app.float.default_40'),
      left: $r('app.float.default_6'),
      right: $r('app.float.default_6')
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  labelBuilder(label: string) {
    Text(label)
      .fontSize($r('app.float.default_16'))
      .fontColor($r('sys.color.font_secondary'))
      .width(Const.THOUSANDTH_940)
  }

  @Builder
  priorityButtonBuilder(label: string, value: number) {
    Button(label)
      .buttonStyle(ButtonStyleMode.NORMAL)
      .fontSize($r('app.float.default_14'))
      .fontColor(this.priority === value ? Color.White : $r('sys.color.font_primary'))
      .backgroundColor(this.priority === value ? $r('app.color.text_font_color') : $r('sys.color.background_primary'))
      .height($r('app.float.default_36'))
      .margin({ right: $r('app.float.default_8') })
      .onClick(() => {
        this.priority = value;
      })
  }

  async saveTask(done: boolean): Promise<void> {
    if (!this.title.trim()) {
      return;
    }
    let minutes = Number(this.estimateMinutes) || 0;
    let task = new PlanTaskInfo(this.taskInfo.id, this.title.trim(), this.courseName.trim(), minutes, this.priority,
      this.note.trim(), this.scheduledDate || this.homeStore.currentDate, done);
    await PlanTaskInfoApi.update(this.taskInfo.id, task);
    await this.updateTodayPlanProgress(done);
    await updatePlanTaskList(this.homeStore);
    this.pageStack.pop();
  }

  async updateTodayPlanProgress(done: boolean): Promise<void> {
    if (!done) {
      return;
    }
    let remainingPlan = Math.max(0, this.homeStore.planTaskList.length - 1);
    let remainingDdl = this.homeStore.studyTaskList.length;
    let target = remainingPlan + remainingDdl + 1;
    let finished = 1;
    if (remainingPlan + remainingDdl === 0) {
      target = 1;
      finished = 1;
      if (!this.achievementStore.currentDayStatus) {
        this.achievementStore.currentConsecutiveDays += 1;
        this.achievementStore.currentDayStatus = true;
        if (this.achievementStore.currentConsecutiveDays > this.achievementStore.maxConsecutiveDays) {
          this.achievementStore.maxConsecutiveDays = this.achievementStore.currentConsecutiveDays;
        }
        await PreferencesUtils.putPreference(Const.CURRENT_CONSECUTIVE_DAYS, String(this.achievementStore.currentConsecutiveDays));
        await PreferencesUtils.putPreference(Const.CURRENT_DAY_STATUS, String(this.achievementStore.currentDayStatus));
        await PreferencesUtils.putPreference(Const.MAX_CONSECUTIVE_DAYS, String(this.achievementStore.maxConsecutiveDays));
      }
    }
    await DayInfoApi.updateByKey(this.homeStore.currentDate, target, finished);
    if (this.homeStore.selectedDay >= 0 && this.homeStore.selectedDay < this.homeStore.weekList.length) {
      this.homeStore.weekList[this.homeStore.selectedDay].targetTaskNum = target;
      this.homeStore.weekList[this.homeStore.selectedDay].finTaskNum = finished;
    }
  }

  async postponeToTomorrow(): Promise<void> {
    let sourceDate = this.scheduledDate || this.taskInfo.scheduledDate || this.homeStore.currentDate;
    let baseDate = this.convertPlanDate(sourceDate);
    baseDate.setDate(baseDate.getDate() + 1);
    let tomorrow = convertDate2Str(baseDate);
    let success = await PlanTaskInfoApi.updateScheduledDate(this.taskInfo.id, tomorrow);
    if (success) {
      this.scheduledDate = tomorrow;
      await updatePlanTaskList(this.homeStore);
      this.pageStack.pop();
    }
  }

  convertPlanDate(date: string): Date {
    if (!date || date.length !== 8) {
      return convertStr2Date(this.homeStore.currentDate);
    }
    const year = Number(date.substring(0, 4));
    const month = Number(date.substring(4, 6)) - 1;
    const day = Number(date.substring(6, 8));
    return new Date(year, month, day);
  }

  async deleteTask(): Promise<void> {
    await PlanTaskInfoApi.delete(this.taskInfo.id);
    await updatePlanTaskList(this.homeStore);
    this.pageStack.pop();
  }
}

@Extend(TextInput)
function planTaskEditInputStyle() {
  .width(Const.THOUSANDTH_940)
  .height($r('app.float.default_44'))
  .fontSize($r('app.float.default_16'))
  .backgroundColor($r('sys.color.background_primary'))
  .borderRadius($r('app.float.default_12'))
}