/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { CommonConstants as Const, StudyTaskInfo } from 'common';
import StudyTaskInfoApi from 'common/src/main/ets/database/tables/StudyTaskInfoApi';
import { HomeStore, updateStudyTaskList } from '../../viewmodel/HomeStore';

@Builder
export function addStudyTaskBuilder() {
  AddStudyTaskComponent();
}

@Component
export struct AddStudyTaskComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @Consume homeStore: HomeStore;
  @State title: string = '';
  @State courseName: string = '';
  @State dueDate: string = '';
  @State dueTime: string = '23:59';
  @State estimateMinutes: string = '60';
  @State priority: number = 2;
  @State note: string = '';

  aboutToAppear(): void {
    if (!this.dueDate) {
      this.dueDate = this.todayText();
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: $r('app.float.default_12') }) {
          this.labelBuilder('任务标题')
          TextInput({ placeholder: '例如：高数作业第三章', text: this.title })
            .studyInputStyle()
            .onChange((value: string) => { this.title = value; })

          this.labelBuilder('所属课程')
          TextInput({ placeholder: '例如：高等数学', text: this.courseName })
            .studyInputStyle()
            .onChange((value: string) => { this.courseName = value; })

          this.labelBuilder('截止日期')
          TextInput({ placeholder: '例如：20260620', text: this.dueDate })
            .studyInputStyle()
            .onChange((value: string) => { this.dueDate = value; })

          this.labelBuilder('截止时间')
          TextInput({ placeholder: '例如：23:59', text: this.dueTime })
            .studyInputStyle()
            .onChange((value: string) => { this.dueTime = value; })

          this.labelBuilder('预计耗时（分钟）')
          TextInput({ placeholder: '例如：60', text: this.estimateMinutes })
            .studyInputStyle()
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
            .studyInputStyle()
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
    let task = new StudyTaskInfo(0, this.title.trim(), this.courseName.trim(), this.dueDate.trim(),
      this.dueTime.trim(), minutes, this.priority, this.note.trim(), false);
    await StudyTaskInfoApi.insert(task);
    await updateStudyTaskList(this.homeStore);
    this.pageStack.pop();
  }

  todayText(): string {
    let date = new Date();
    return `${date.getFullYear()}${('0' + (date.getMonth() + 1)).slice(-2)}${('0' + date.getDate()).slice(-2)}`;
  }
}

@Extend(TextInput)
function studyInputStyle() {
  .width(Const.THOUSANDTH_940)
  .height($r('app.float.default_44'))
  .fontSize($r('app.float.default_16'))
  .backgroundColor($r('sys.color.background_primary'))
  .borderRadius($r('app.float.default_12'))
}