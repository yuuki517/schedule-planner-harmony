/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { CommonConstants as Const, CourseInfo } from 'common';
import CourseInfoApi from 'common/src/main/ets/database/tables/CourseInfoApi';
import { HomeStore, updateCourseList } from '../../viewmodel/HomeStore';

@Builder
export function addCourseBuilder() {
  AddCourseComponent();
}

@Component
export struct AddCourseComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @Consume homeStore: HomeStore;
  @State courseName: string = '';
  @State location: string = '';
  @State startTime: string = '08:00';
  @State endTime: string = '09:40';
  @State repeatRule: string = '每周';
  @State selectedWeekdays: number[] = [1];
  private weekNames: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: $r('app.float.default_12') }) {
          this.labelBuilder('课程名')
          TextInput({ placeholder: '例如：高等数学', text: this.courseName })
            .inputStyle()
            .onChange((value: string) => {
              this.courseName = value;
            })

          this.labelBuilder('上课星期')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.weekNames, (item: string, index: number) => {
              Button(item)
                .buttonStyle(ButtonStyleMode.NORMAL)
                .fontSize($r('app.float.default_14'))
                .fontColor(this.selectedWeekdays.includes(index + 1) ? Color.White : $r('sys.color.font_primary'))
                .backgroundColor(this.selectedWeekdays.includes(index + 1) ? $r('app.color.text_font_color') :
                  $r('sys.color.background_primary'))
                .height($r('app.float.default_36'))
                .margin({ right: $r('app.float.default_8'), bottom: $r('app.float.default_8') })
                .onClick(() => {
                  this.toggleWeekday(index + 1);
                })
            }, (item: string, index: number) => `${index}-${item}`)
          }
          .width(Const.THOUSANDTH_940)

          this.labelBuilder('开始时间')
          TextInput({ placeholder: '例如：08:00', text: this.startTime })
            .inputStyle()
            .onChange((value: string) => {
              this.startTime = value;
            })

          this.labelBuilder('结束时间')
          TextInput({ placeholder: '例如：09:40', text: this.endTime })
            .inputStyle()
            .onChange((value: string) => {
              this.endTime = value;
            })

          this.labelBuilder('地点')
          TextInput({ placeholder: '例如：教学楼 A101', text: this.location })
            .inputStyle()
            .onChange((value: string) => {
              this.location = value;
            })

          this.labelBuilder('重复周期')
          TextInput({ placeholder: '例如：每周 / 1-16周', text: this.repeatRule })
            .inputStyle()
            .onChange((value: string) => {
              this.repeatRule = value;
            })

          Button('保存课程')
            .buttonStyle(ButtonStyleMode.NORMAL)
            .width(Const.THOUSANDTH_940)
            .height($r('app.float.default_44'))
            .backgroundColor($r('app.color.text_font_color'))
            .fontColor(Color.White)
            .margin({ top: $r('app.float.default_16') })
            .onClick(async () => {
              await this.saveCourse();
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
    .size({
      width: Const.THOUSANDTH_1000,
      height: Const.THOUSANDTH_1000
    })
    .title('添加课程')
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

  toggleWeekday(weekday: number): void {
    if (this.selectedWeekdays.includes(weekday)) {
      if (this.selectedWeekdays.length === 1) {
        return;
      }
      this.selectedWeekdays = this.selectedWeekdays.filter((item: number) => item !== weekday);
    } else {
      this.selectedWeekdays = [...this.selectedWeekdays, weekday].sort();
    }
  }

  @Builder
  repeatRuleBuilder() {
    Row() {
      ForEach(['每周', '单周', '双周'], (item: string) => {
        Button(item)
          .buttonStyle(ButtonStyleMode.NORMAL)
          .fontSize($r('app.float.default_14'))
          .fontColor(this.repeatRule === item ? Color.White : $r('sys.color.font_primary'))
          .backgroundColor(this.repeatRule === item ? $r('app.color.text_font_color') : $r('sys.color.background_primary'))
          .height($r('app.float.default_36'))
          .margin({ right: $r('app.float.default_8') })
          .onClick(() => {
            this.repeatRule = item;
          })
      }, (item: string) => item)
    }
    .width(Const.THOUSANDTH_940)
  }

  async saveCourse(): Promise<void> {
    if (!this.courseName.trim()) {
      return;
    }
    if (this.selectedWeekdays.length === 0) {
      return;
    }
    for (let weekday of this.selectedWeekdays) {
      let course = new CourseInfo(0, this.courseName.trim(), weekday, this.startTime.trim(), this.endTime.trim(),
        this.location.trim(), this.repeatRule.trim());
      await CourseInfoApi.insert(course);
    }
    await updateCourseList(this.homeStore);
    this.pageStack.pop();
  }
}

@Extend(TextInput)
function inputStyle() {
  .width(Const.THOUSANDTH_940)
  .height($r('app.float.default_44'))
  .fontSize($r('app.float.default_16'))
  .backgroundColor($r('sys.color.background_primary'))
  .borderRadius($r('app.float.default_12'))
}

