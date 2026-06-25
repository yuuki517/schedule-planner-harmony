/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { CommonConstants as Const, HabitInfo } from 'common';
import HabitCheckInInfoApi from 'common/src/main/ets/database/tables/HabitCheckInInfoApi';
import { HomeStore, updateHabitList } from '../../viewmodel/HomeStore';

@Component
export struct HabitListComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @Consume homeStore: HomeStore;

  build() {
    Column() {
      if (this.homeStore.habitList.length > 0) {
        this.summaryBuilder()
        ForEach(this.homeStore.habitList, (item: HabitInfo, index: number) => {
          this.habitCardBuilder(item)
        }, (item: HabitInfo, index: number) => `${index}-${item.id}-${item.name}-${item.todayDone}`)
      } else {
        Text('暂无常规习惯')
          .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('app.float.default_14'))
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
  summaryBuilder() {
    Column() {
      Row() {
        Text('习惯打卡')
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('app.float.default_16'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(Const.FLEX_GROW_1)

        Text(`${this.doneCount()}/${this.homeStore.habitList.length}`)
          .fontColor($r('app.color.text_font_color'))
          .fontSize($r('app.float.default_14'))
          .fontWeight(FontWeight.Medium)
      }
      .width(Const.THOUSANDTH_1000)

      Text(`今日已完成 ${this.doneCount()} 项 · 最高连续 ${this.maxStreak()} 天 · 累计 ${this.totalCount()} 次`)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('app.float.default_12'))
        .width(Const.THOUSANDTH_1000)
        .margin({ top: $r('app.float.default_6') })

      Text(this.achievementText())
        .fontColor($r('app.color.text_font_color'))
        .fontSize($r('app.float.default_12'))
        .width(Const.THOUSANDTH_1000)
        .margin({ top: $r('app.float.default_6') })
    }
    .width(Const.THOUSANDTH_1000)
    .borderRadius($r('app.float.default_16'))
    .padding($r('app.float.default_12'))
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ bottom: $r('app.float.default_12') })
  }

  @Builder
  habitCardBuilder(item: HabitInfo) {
    Column() {
      Row() {
        Text(item.name)
          .fontColor(item.todayDone ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
          .fontSize($r('app.float.default_16'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(Const.FLEX_GROW_1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)

        Button(item.todayDone ? '已打卡' : '打卡')
          .buttonStyle(ButtonStyleMode.NORMAL)
          .fontSize($r('app.float.default_12'))
          .fontColor(item.todayDone ? $r('app.color.text_font_color') : Color.White)
          .backgroundColor(item.todayDone ? $r('sys.color.background_secondary') : $r('app.color.text_font_color'))
          .height($r('app.float.default_32'))
          .onClick(async () => {
            await HabitCheckInInfoApi.toggleCheckIn(item.id, this.homeStore.currentDate);
            await updateHabitList(this.homeStore);
          })
      }
      .width(Const.THOUSANDTH_1000)

      Text(`${item.estimateMinutes}分钟${item.isFixedTime ? ' · ' + item.fixedTime + ' 提醒' : ' · 灵活安排'}`)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('app.float.default_12'))
        .width(Const.THOUSANDTH_1000)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .margin({ top: $r('app.float.default_6') })

      Text(`连续 ${item.currentStreak} 天 · 累计 ${item.totalCheckIn} 次`)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('app.float.default_12'))
        .width(Const.THOUSANDTH_1000)
        .margin({ top: $r('app.float.default_4') })
    }
    .width(Const.THOUSANDTH_1000)
    .borderRadius($r('app.float.default_16'))
    .padding($r('app.float.default_12'))
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ bottom: $r('app.float.default_12') })
    .onClick(() => {
      this.pageStack.pushPath({ name: 'EditHabitComponent', param: item });
    })
  }

  doneCount(): number {
    let count = 0;
    for (let habit of this.homeStore.habitList) {
      if (habit.todayDone) {
        count += 1;
      }
    }
    return count;
  }

  maxStreak(): number {
    let max = 0;
    for (let habit of this.homeStore.habitList) {
      if (habit.currentStreak > max) {
        max = habit.currentStreak;
      }
    }
    return max;
  }

  totalCount(): number {
    let total = 0;
    for (let habit of this.homeStore.habitList) {
      total += habit.totalCheckIn;
    }
    return total;
  }

  achievementText(): string {
    let streak = this.maxStreak();
    if (streak >= 30) {
      return '已达成：习惯大师 30 天';
    }
    if (streak >= 14) {
      return '已达成：稳定节奏 14 天，下一目标 30 天';
    }
    if (streak >= 7) {
      return '已达成：一周坚持 7 天，下一目标 14 天';
    }
    if (streak >= 3) {
      return '已达成：初步养成 3 天，下一目标 7 天';
    }
    return '下一成就：连续打卡 3 天';
  }
}
