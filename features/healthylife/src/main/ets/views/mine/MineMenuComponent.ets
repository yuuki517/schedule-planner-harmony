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

@Reusable
@Component
export struct MineMenuComponent {
  build() {
    List() {
      ForEach(Const.DEFAULT_MENU_INFO, (item: Resource, index: number) => {
        ListItem() {
          Flex({
            justifyContent: FlexAlign.Start,
            alignItems: ItemAlign.Center,
          }) {
            Image(index === 0 ? $r('app.media.personal_profile') : $r('app.media.arrow_up_circle'))
              .width($r('app.float.default_28'))
              .height($r('app.float.default_28'))
            Blank().width($r('app.float.default_12'))
            Text(item)
              .fontSize($r('app.float.default_18'))
              .fontWeight(FontWeight.Bold)
            Blank();
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.icon_secondary')])
              .fontWeight(FontWeight.Normal)
              .fontSize($r('app.float.default_24'))
          }
        }
        .align(Alignment.Center)
        .backgroundColor($r('sys.color.background_primary'))
        .height($r('app.float.default_48'))
        .border({
          width: {
            bottom: index === Const.DEFAULT_MENU_INFO.length - 1 ? 0 : $r('app.float.default_1')
          },
          color: $r('sys.color.background_tertiary')
        })
      }, (item: Resource, index: number) => index + JSON.stringify(item));
    }
    .width(Const.THOUSANDTH_1000)
    .height(Const.THOUSANDTH_780)
    .backgroundColor($r('sys.color.background_primary'))
    .flexGrow(Const.FLEX_GROW_1)
    .clip(true)
  }
}