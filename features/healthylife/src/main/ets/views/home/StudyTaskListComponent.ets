/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { CommonConstants as Const, StudyTaskInfo } from 'common';
import { HomeStore } from '../../viewmodel/HomeStore';

@Component
export struct StudyTaskListComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @Consume homeStore: HomeStore;

  build() {
    if (this.homeStore.studyTaskList.length > 0) {
      Column() {
        ForEach(this.homeStore.studyTaskList, (item: StudyTaskInfo, index: number) => {
          this.taskCardBuilder(item)
        }, (item: StudyTaskInfo, index: number) => `${index}-${item.id}-${item.title}`)
      }
      .width(Const.THOUSANDTH_1000)
      .padding({
        left: $r('app.float.default_16'),
        right: $r('app.float.default_16')
      })
    } else {
      Column() {
        Text('暂无 DDL 或任务')
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
  taskCardBuilder(item: StudyTaskInfo) {
    Column() {
      Row() {
        Text(item.title)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('app.float.default_16'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(Const.FLEX_GROW_1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)

        Text(this.priorityText(item.priority))
          .fontColor($r('app.color.text_font_color'))
          .fontSize($r('app.float.default_12'))
      }
      .width(Const.THOUSANDTH_1000)

      Text(`${item.courseName || '未关联课程'} · ${this.formatDueDate(item.dueDate)} ${item.dueTime} · ${item.estimateMinutes}分钟`)
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
    .margin({ bottom: $r('app.float.default_12') })
    .onClick(() => {
      this.pageStack.pushPath({ name: 'EditStudyTaskComponent', param: item });
    })
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

  formatDueDate(dueDate: string): string {
    if (dueDate.length !== 8) {
      return dueDate;
    }
    return `${dueDate.substring(4, 6)}/${dueDate.substring(6, 8)}`;
  }
}