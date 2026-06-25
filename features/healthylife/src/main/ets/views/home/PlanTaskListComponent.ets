/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { CommonConstants as Const, PlanTaskInfo } from 'common';
import { HomeStore } from '../../viewmodel/HomeStore';

@Component
export struct PlanTaskListComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @Consume homeStore: HomeStore;

  build() {
    Column() {
      if (this.homeStore.planTaskList.length > 0) {
        ForEach(this.homeStore.planTaskList, (item: PlanTaskInfo, index: number) => {
          this.taskCardBuilder(item, false)
        }, (item: PlanTaskInfo, index: number) => `open-${index}-${item.id}-${item.title}`)
      } else {
        Text('当前日期暂无普通任务')
          .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('app.float.default_14'))
          .width(Const.THOUSANDTH_1000)
          .margin({ bottom: $r('app.float.default_8') })
      }

      if (this.homeStore.donePlanTaskList.length > 0) {
        Text('已完成的任务')
          .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('app.float.default_16'))
          .width(Const.THOUSANDTH_1000)
          .margin({ top: $r('app.float.default_8'), bottom: $r('app.float.default_8') })

        ForEach(this.homeStore.donePlanTaskList, (item: PlanTaskInfo, index: number) => {
          this.taskCardBuilder(item, true)
        }, (item: PlanTaskInfo, index: number) => `done-${index}-${item.id}-${item.title}`)
      }
    }
    .width(Const.THOUSANDTH_1000)
    .padding({
      left: $r('app.float.default_16'),
      right: $r('app.float.default_16'),
      bottom: $r('app.float.default_8')
    })
  }

  @Builder
  taskCardBuilder(item: PlanTaskInfo, done: boolean) {
    Column() {
      Row() {
        Text(item.title)
          .fontColor(done ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
          .fontSize($r('app.float.default_16'))
          .fontWeight(FontWeight.Medium)
          .decoration({ type: done ? TextDecorationType.LineThrough : TextDecorationType.None })
          .layoutWeight(Const.FLEX_GROW_1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)

        Text(done ? '已完成' : this.priorityText(item.priority))
          .fontColor($r('app.color.text_font_color'))
          .fontSize($r('app.float.default_12'))
      }
      .width(Const.THOUSANDTH_1000)

      Text(`${item.courseName || '未关联课程'} · ${this.formatDate(item.scheduledDate)} · ${item.estimateMinutes}分钟`)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('app.float.default_12'))
        .width(Const.THOUSANDTH_1000)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .margin({ top: $r('app.float.default_6') })
    }
    .width(Const.THOUSANDTH_1000)
    .borderRadius($r('app.float.default_16'))
    .padding($r('app.float.default_12'))
    .backgroundColor($r('sys.color.background_primary'))
    .opacity(done ? 0.72 : 1)
    .margin({ bottom: $r('app.float.default_12') })
    .onClick(() => {
      this.pageStack.pushPath({ name: 'EditPlanTaskComponent', param: item });
    })
  }

  formatDate(date: string): string {
    if (!date || date.length !== 8) {
      return '今天';
    }
    return `${date.substring(4, 6)}/${date.substring(6, 8)}`;
  }

  priorityText(priority: number): string {
    if (priority === 1) {
      return '高优先级';
    }
    if (priority === 3) {
      return '低优先级';
    }
    return '普通';
  }
}
