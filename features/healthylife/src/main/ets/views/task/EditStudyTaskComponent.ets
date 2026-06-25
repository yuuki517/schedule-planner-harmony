/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { CommonConstants as Const, StudyTaskInfo } from 'common';
import StudyTaskInfoApi from 'common/src/main/ets/database/tables/StudyTaskInfoApi';
import DayInfoApi from 'common/src/main/ets/database/tables/DayInfoApi';
import { PreferencesUtils } from 'common/src/main/ets/utils/PreferencesUtils';
import { AchievementStore } from '../../viewmodel/AchievementStore';
import { HomeStore, updateStudyTaskList } from '../../viewmodel/HomeStore';

@Builder
export function editStudyTaskBuilder(_name: string, param: StudyTaskInfo) {
  EditStudyTaskComponent({
    taskInfo: param,
    title: param.title,
    courseName: param.courseName,
    dueDate: param.dueDate,
    dueTime: param.dueTime,
    estimateMinutes: param.estimateMinutes.toString(),
    priority: param.priority,
    note: param.note
  });
}

@Component
export struct EditStudyTaskComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @Consume homeStore: HomeStore;
  @Consume achievementStore: AchievementStore;
  taskInfo: StudyTaskInfo = new StudyTaskInfo(0, '', '', '', '23:59', 0, 2, '', false);
  @State title: string = '';
  @State courseName: string = '';
  @State dueDate: string = '';
  @State dueTime: string = '23:59';
  @State estimateMinutes: string = '60';
  @State priority: number = 2;
  @State note: string = '';

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: $r('app.float.default_12') }) {
          this.labelBuilder('任务标题')
          TextInput({ placeholder: '例如：高数作业第三章', text: this.title })
            .studyEditInputStyle()
            .onChange((value: string) => { this.title = value; })

          this.labelBuilder('所属课程')
          TextInput({ placeholder: '例如：高等数学', text: this.courseName })
            .studyEditInputStyle()
            .onChange((value: string) => { this.courseName = value; })

          this.labelBuilder('截止日期')
          TextInput({ placeholder: '例如：20260620', text: this.dueDate })
            .studyEditInputStyle()
            .onChange((value: string) => { this.dueDate = value; })

          this.labelBuilder('截止时间')
          TextInput({ placeholder: '例如：23:59', text: this.dueTime })
            .studyEditInputStyle()
            .onChange((value: string) => { this.dueTime = value; })

          this.labelBuilder('预计耗时（分钟）')
          TextInput({ placeholder: '例如：60', text: this.estimateMinutes })
            .studyEditInputStyle()
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
            .studyEditInputStyle()
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
    let task = new StudyTaskInfo(this.taskInfo.id, this.title.trim(), this.courseName.trim(), this.dueDate.trim(),
      this.dueTime.trim(), minutes, this.priority, this.note.trim(), done);
    await StudyTaskInfoApi.update(this.taskInfo.id, task);
    await this.updateTodayPlanProgress(done);
    await updateStudyTaskList(this.homeStore);
    this.pageStack.pop();
  }

  async updateTodayPlanProgress(done: boolean): Promise<void> {
    if (!done) {
      return;
    }
    let remainingPlan = this.homeStore.planTaskList.length;
    let remainingDdl = Math.max(0, this.homeStore.studyTaskList.length - 1);
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

  async deleteTask(): Promise<void> {
    await StudyTaskInfoApi.delete(this.taskInfo.id);
    await updateStudyTaskList(this.homeStore);
    this.pageStack.pop();
  }
}

@Extend(TextInput)
function studyEditInputStyle() {
  .width(Const.THOUSANDTH_940)
  .height($r('app.float.default_44'))
  .fontSize($r('app.float.default_16'))
  .backgroundColor($r('sys.color.background_primary'))
  .borderRadius($r('app.float.default_12'))
}