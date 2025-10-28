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
import { MineMenuComponent } from './mine/MineMenuComponent';
import { UserInfoComponent } from './mine/UserInfoComponent';

@Component
export struct MineComponent {
  @Provide uiContext: UIContext = this.getUIContext();
  @Consume('pathStack') pageStack: NavPathStack;

  build() {
    Navigation() {
      Column() {
        UserInfoComponent()
        Row({ space: $r('app.float.default_12') }) {
          MineMenuComponent()
        }
        .width(Const.THOUSANDTH_940)
        .height(Const.THOUSANDTH_200)
        .borderRadius($r('app.float.default_16'))
        .padding({
          left: $r('app.float.default_12'),
          right: $r('app.float.default_12')
        })
        .backgroundColor($r('sys.color.background_primary'))
        .margin({
          top: $r('app.float.default_8'),
          bottom: $r('app.float.default_8')
        })

        Row({ space: $r('app.float.default_12') }) {
          Image($r('app.media.star_trophy'))
            .width($r('app.float.default_28'))
            .height($r('app.float.default_28'))
          Text($r('app.string.mine_achievement'))
            .fontSize($r('app.float.default_18'))
            .fontWeight(FontWeight.Bold)
          Blank();
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.icon_secondary')])
            .fontWeight(FontWeight.Normal)
            .fontSize($r('app.float.default_24'))
        }
        .width(Const.THOUSANDTH_940)
        .height(Const.THOUSANDTH_100)
        .borderRadius($r('app.float.default_16'))
        .padding({
          left: $r('app.float.default_12'),
          right: $r('app.float.default_12')
        })
        .backgroundColor($r('sys.color.background_primary'))
        .margin({
          top: $r('app.float.default_8')
        })
        .onClick(() => {
          this.pageStack.pushPathByName('AchievementComponent', '');
        })
      }
      .width(Const.THOUSANDTH_1000)
      .height(Const.THOUSANDTH_1000)
    }
    .title($r('app.string.tab_mine'))
    .backgroundColor($r('sys.color.background_secondary'))
  }
}