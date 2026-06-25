/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { CommonConstants as Const, HabitInfo, HabitReminderUtils } from 'common';
import HabitInfoApi from 'common/src/main/ets/database/tables/HabitInfoApi';
import { HomeStore, updateHabitList } from '../../viewmodel/HomeStore';

@Builder
export function editHabitBuilder(_name: string, param: HabitInfo) {
  EditHabitComponent({
    habitInfo: param,
    name: param.name,
    estimateMinutes: param.estimateMinutes.toString(),
    isFixedTime: param.isFixedTime,
    fixedTime: param.fixedTime || '20:00'
  });
}

@Component
export struct EditHabitComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @Consume homeStore: HomeStore;
  habitInfo: HabitInfo = new HabitInfo(0, '', 0, false, '', false, -1);
  @State name: string = '';
  @State estimateMinutes: string = '30';
  @State isFixedTime: boolean = false;
  @State fixedTime: string = '20:00';

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: $r('app.float.default_12') }) {
          this.labelBuilder('事项名称')
          TextInput({ placeholder: '例如：背单词', text: this.name })
            .habitEditInputStyle()
            .onChange((value: string) => { this.name = value; })

          this.labelBuilder('用时（分钟）')
          TextInput({ placeholder: '例如：30', text: this.estimateMinutes })
            .habitEditInputStyle()
            .onChange((value: string) => { this.estimateMinutes = value; })

          Row() {
            Text('是否固定时段')
              .fontSize($r('app.float.default_16'))
              .fontColor($r('sys.color.font_secondary'))
              .layoutWeight(Const.FLEX_GROW_1)

            Toggle({ type: ToggleType.Switch, isOn: this.isFixedTime })
              .onChange((isOn: boolean) => {
                this.isFixedTime = isOn;
              })
          }
          .width(Const.THOUSANDTH_940)
          .height($r('app.float.default_44'))

          if (this.isFixedTime) {
            this.labelBuilder('固定时间')
            TextInput({ placeholder: '例如：20:00', text: this.fixedTime })
              .habitEditInputStyle()
              .onChange((value: string) => { this.fixedTime = value; })
          }

          Button('保存修改')
            .buttonStyle(ButtonStyleMode.NORMAL)
            .width(Const.THOUSANDTH_940)
            .height($r('app.float.default_44'))
            .backgroundColor($r('app.color.text_font_color'))
            .fontColor(Color.White)
            .margin({ top: $r('app.float.default_16') })
            .onClick(async () => {
              await this.saveHabit();
            })

          Button('删除习惯')
            .buttonStyle(ButtonStyleMode.NORMAL)
            .width(Const.THOUSANDTH_940)
            .height($r('app.float.default_44'))
            .fontColor($r('app.color.button_red'))
            .backgroundColor($r('sys.color.background_primary'))
            .onClick(async () => {
              await this.deleteHabit();
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
    .title('编辑习惯')
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

  async saveHabit(): Promise<void> {
    if (!this.name.trim()) {
      return;
    }
    let minutes = Number(this.estimateMinutes) || 0;
    let fixedTime = this.isFixedTime ? this.fixedTime.trim() : '';
    let reminderId = this.habitInfo.reminderId;
    if (!this.isFixedTime) {
      HabitReminderUtils.deleteReminder(reminderId);
      reminderId = -1;
    }
    let habit = new HabitInfo(this.habitInfo.id, this.name.trim(), minutes, this.isFixedTime, fixedTime, false,
      reminderId);
    if (this.isFixedTime) {
      habit.reminderId = await HabitReminderUtils.updateReminder(habit);
    }
    await HabitInfoApi.update(this.habitInfo.id, habit);
    await updateHabitList(this.homeStore);
    this.pageStack.pop();
  }

  async deleteHabit(): Promise<void> {
    HabitReminderUtils.deleteReminder(this.habitInfo.reminderId);
    await HabitInfoApi.delete(this.habitInfo.id);
    await updateHabitList(this.homeStore);
    this.pageStack.pop();
  }
}

@Extend(TextInput)
function habitEditInputStyle() {
  .width(Const.THOUSANDTH_940)
  .height($r('app.float.default_44'))
  .fontSize($r('app.float.default_16'))
  .backgroundColor($r('sys.color.background_primary'))
  .borderRadius($r('app.float.default_12'))
}
