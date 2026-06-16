/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { CommonConstants as Const, CourseInfo } from 'common';
import { HomeStore } from '../../viewmodel/HomeStore';

@Component
export struct CourseListComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @Consume homeStore: HomeStore;

  build() {
    if (this.homeStore.courseList.length > 0) {
      Column() {
        ForEach(this.homeStore.courseList, (item: CourseInfo, index: number) => {
          this.courseCardBuilder(item)
        }, (item: CourseInfo, index: number) => `${index}-${item.id}-${item.name}`)
      }
      .width(Const.THOUSANDTH_1000)
      .padding({
        left: $r('app.float.default_16'),
        right: $r('app.float.default_16')
      })
    } else {
      Column() {
        Text('今天暂无课程')
          .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('app.float.default_14'))
      }
      .width(Const.THOUSANDTH_1000)
      .padding({
        left: $r('app.float.default_16'),
        right: $r('app.float.default_16'),
        bottom: $r('app.float.default_8')
      })
    }
  }

  @Builder
  courseCardBuilder(item: CourseInfo) {
    Row() {
      Column() {
        Text(item.startTime)
          .fontColor($r('app.color.text_font_color'))
          .fontSize($r('app.float.default_16'))
          .fontWeight(FontWeight.Bold)
        Text(item.endTime)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('app.float.default_12'))
      }
      .width(Const.THOUSANDTH_150)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text(item.name)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('app.float.default_16'))
          .fontWeight(FontWeight.Medium)
          .width(Const.THOUSANDTH_1000)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)

        Text(`${item.location || '未填写地点'} · ${item.repeatRule || '每周'}`)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('app.float.default_12'))
          .width(Const.THOUSANDTH_1000)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .margin({ top: $r('app.float.default_4') })
      }
      .layoutWeight(Const.FLEX_GROW_1)
      .alignItems(HorizontalAlign.Start)
    }
    .width(Const.THOUSANDTH_1000)
    .height($r('app.float.default_72'))
    .borderRadius($r('app.float.default_16'))
    .padding({
      left: $r('app.float.default_12'),
      right: $r('app.float.default_12')
    })
    .backgroundColor($r('sys.color.background_primary'))
    .margin({
      bottom: $r('app.float.default_12')
    })
    .onClick(() => {
      this.pageStack.pushPath({ name: 'EditCourseComponent', param: item });
    })
  }
}