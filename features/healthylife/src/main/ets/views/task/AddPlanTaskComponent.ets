/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { CommonConstants as Const, PlanTaskInfo } from 'common';
import PlanTaskInfoApi from 'common/src/main/ets/database/tables/PlanTaskInfoApi';
import { HomeStore, updatePlanTaskList } from '../../viewmodel/HomeStore';

@Builder
export function addPlanTaskBuilder() {
  AddPlanTaskComponent();
}

@Component
export struct AddPlanTaskComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @Consume homeStore: HomeStore;
  @State title: string = '';
  @State courseName: string = '';
  @State estimateMinutes: string = '60';
  @State priority: number = 2;
  @State note: string = '';

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: $r('app.float.default_12') }) {
          this.labelBuilder('任务标题')
          TextInput({ placeholder: '例如：整理英语笔记', text: this.title })
            .planTaskInputStyle()
            .onChange((value: string) => { this.title = value; })

          this.labelBuilder('所属课程')
          TextInput({ placeholder: '例如：大学英语', text: this.courseName })
            .planTaskInputStyle()
            .onChange((value: string) => { this.courseName = value; })

          this.labelBuilder('预计所需时间长度（分钟）')
          TextInput({ placeholder: '例如：45', text: this.estimateMinutes })
            .planTaskInputStyle()
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
            .planTaskInputStyle()
            .onChange((value: string) => { this.note = value; })

          Button('保存任务')
            .buttonStyle(ButtonStyleMode.NORMAL)
            .width(Const.THOUSANDTH_940)
            .height($r('app.float.default_44'))
            .backgroundColor($r('app.color.text_font_color'))
            .fontColor(Color.White)
            .margin({ top: $r('app.float.default_16') })
            .onClick(async () => {
              await this.saveTask();
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
    .title('添加任务')
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

  async saveTask(): Promise<void> {
    if (!this.title.trim()) {
      return;
    }
    let minutes = Number(this.estimateMinutes) || 0;
    let task = new PlanTaskInfo(0, this.title.trim(), this.courseName.trim(), minutes, this.priority, this.note.trim(),
      this.homeStore.currentDate, false);
    await PlanTaskInfoApi.ensureScheduleColumn(this.homeStore.currentDate);
    await PlanTaskInfoApi.insert(task);
    await updatePlanTaskList(this.homeStore);
    this.pageStack.pop();
  }
}

@Extend(TextInput)
function planTaskInputStyle() {
  .width(Const.THOUSANDTH_940)
  .height($r('app.float.default_44'))
  .fontSize($r('app.float.default_16'))
  .backgroundColor($r('sys.color.background_primary'))
  .borderRadius($r('app.float.default_12'))
}