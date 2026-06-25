/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { CommonConstants as Const } from 'common';
import { HomeTopComponent } from './home/HomeTopComponent';
import { CourseListComponent } from './home/CourseListComponent';
import { StudyTaskListComponent } from './home/StudyTaskListComponent';
import { PlanTaskListComponent } from './home/PlanTaskListComponent';
import { HabitListComponent } from './home/HabitListComponent';
import { SmartScheduleComponent } from './home/SmartScheduleComponent';
import { AchievementStore } from '../viewmodel/AchievementStore';
import { HomeStore, initCurrentDateInfo } from '../viewmodel/HomeStore';

@Builder
export function homeBuilder() {
  HomeComponent();
}

@Component
export struct HomeComponent {
  @Consume('pathStack') pageStack: NavPathStack
  @Consume homeStore: HomeStore;
  @Consume achievementStore: AchievementStore;
  @State naviAlpha: number = 0;
  @State flag: boolean = false;
  private scroller: Scroller = new Scroller();

  async aboutToAppear() {
    this.homeStore = await initCurrentDateInfo(new Date());
    this.flag = true;
  }

  build() {
    NavDestination() {
      if (this.flag) {
        Stack() {
          // top and list area of enable scroll
          Scroll(this.scroller) {
            Column() {
              Text($r('app.string.healthy_life'))
                .fontFamily($r(Const.HARMONY_HEI_TI_MEDIUM))
                .fontWeight(FontWeight.Bold)
                .fontColor($r(`sys.color.font_primary`))
                .fontSize($r('app.float.default_24'))
                .width(Const.THOUSANDTH_1000)
                .height($r('app.float.default_56'))
                .padding({
                  left: Const.THOUSANDTH_66
                })
                .position({
                  x: $r('app.float.default_0'),
                  y: $r('app.float.default_48')
                })
                .zIndex(Const.HOME_COMPONENT_Z_INDEX)

              HomeTopComponent()

              SmartScheduleComponent()

              Button('AI 对话')
                .buttonStyle(ButtonStyleMode.NORMAL)
                .width(Const.THOUSANDTH_940)
                .height($r('app.float.default_40'))
                .fontSize($r('app.float.default_14'))
                .fontColor(Color.White)
                .backgroundColor($r('app.color.text_font_color'))
                .margin({ top: $r('app.float.default_8'), bottom: $r('app.float.default_8') })
                .onClick(() => {
                  this.pageStack.pushPathByName('AiChatComponent', '');
                })

              Row() {
                Text('今日课程')
                  .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r(`sys.color.font_primary`))
                  .fontSize($r('app.float.default_20'))

                Blank()

                Button('添加课程')
                  .buttonStyle(ButtonStyleMode.NORMAL)
                  .height($r('app.float.default_32'))
                  .fontSize($r('app.float.default_14'))
                  .fontColor($r('app.color.text_font_color'))
                  .backgroundColor($r('sys.color.background_primary'))
                  .onClick(() => {
                    this.pageStack.pushPathByName('AddCourseComponent', '');
                  })
              }
              .width(Const.THOUSANDTH_1000)
              .padding({
                top: $r('app.float.default_24'),
                bottom: $r('app.float.default_8'),
                left: $r('app.float.default_16'),
                right: $r('app.float.default_16')
              })

              CourseListComponent()

              Row() {
                Text('DDL')
                  .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('app.float.default_20'))

                Blank()

                Button('添加DDL')
                  .buttonStyle(ButtonStyleMode.NORMAL)
                  .height($r('app.float.default_32'))
                  .fontSize($r('app.float.default_14'))
                  .fontColor($r('app.color.text_font_color'))
                  .backgroundColor($r('sys.color.background_primary'))
                  .onClick(() => {
                    this.pageStack.pushPathByName('AddStudyTaskComponent', '');
                  })
              }
              .width(Const.THOUSANDTH_1000)
              .padding({
                top: $r('app.float.default_24'),
                bottom: $r('app.float.default_8'),
                left: $r('app.float.default_16'),
                right: $r('app.float.default_16')
              })

              StudyTaskListComponent()

              Row() {
                Text('任务')
                  .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('app.float.default_20'))

                Blank()

                Button('添加任务')
                  .buttonStyle(ButtonStyleMode.NORMAL)
                  .height($r('app.float.default_32'))
                  .fontSize($r('app.float.default_14'))
                  .fontColor($r('app.color.text_font_color'))
                  .backgroundColor($r('sys.color.background_primary'))
                  .onClick(() => {
                    this.pageStack.pushPathByName('AddPlanTaskComponent', '');
                  })
              }
              .width(Const.THOUSANDTH_1000)
              .padding({
                top: $r('app.float.default_24'),
                bottom: $r('app.float.default_8'),
                left: $r('app.float.default_16'),
                right: $r('app.float.default_16')
              })

              PlanTaskListComponent()

              Row() {
                Text('常规习惯')
                  .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('app.float.default_20'))

                Blank()

                Button('添加习惯')
                  .buttonStyle(ButtonStyleMode.NORMAL)
                  .height($r('app.float.default_32'))
                  .fontSize($r('app.float.default_14'))
                  .fontColor($r('app.color.text_font_color'))
                  .backgroundColor($r('sys.color.background_primary'))
                  .onClick(() => {
                    this.pageStack.pushPathByName('AddHabitComponent', '');
                  })
              }
              .width(Const.THOUSANDTH_1000)
              .padding({
                top: $r('app.float.default_24'),
                bottom: $r('app.float.default_8'),
                left: $r('app.float.default_16'),
                right: $r('app.float.default_16')
              })

              HabitListComponent()


            }
          }
          .width(Const.THOUSANDTH_1000)
          .height(Const.THOUSANDTH_1000)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, {
            alwaysEnabled: false,
            effectEdge: EffectEdge.END
          })

        }
        .width(Const.THOUSANDTH_1000)
        .height(Const.THOUSANDTH_1000)
        .backgroundColor($r('sys.color.background_secondary'));
      }
    }
  }
}
