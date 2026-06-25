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

import { JSON } from '@kit.ArkTS';
import { CommonConstants as Const, DayInfo, convertDate2Str, convertStr2Date } from 'common';
import DayInfoApi from 'common/src/main/ets/database/tables/DayInfoApi';
import { getAchievementDoneIndex } from '../model/AchievementModel';
import { TaskInfoDialogParams } from './dialog/TaskInfoDialogParams';
import { PreferencesUtils } from 'common/src/main/ets/utils/PreferencesUtils';
import { openAchievementCustomDialog } from '../views/dialog/AchievementDialog';

/*
 * Global achievement information storage.
 */
@Observed
export class AchievementStore {
  public maxConsecutiveDays: number;
  public currentConsecutiveDays: number;
  public currentDayStatus: boolean;

  constructor(maxConsecutiveDays: number, currentConsecutiveDays: number, currentDayStatus: boolean) {
    this.maxConsecutiveDays = maxConsecutiveDays;
    this.currentConsecutiveDays = currentConsecutiveDays;
    this.currentDayStatus = currentDayStatus;
  }
}

/*
 * Initialize global achievement information.
 */
export async function initAchievementStore() {
  const maxConsecutiveDays = Number(await PreferencesUtils.getPreference(Const.MAX_CONSECUTIVE_DAYS)) || 0;
  const currentConsecutiveDays = Number(await PreferencesUtils.getPreference(Const.CURRENT_CONSECUTIVE_DAYS)) || 0;
  const currentDayStatusStr: string = await PreferencesUtils.getPreference(Const.CURRENT_DAY_STATUS);
  let currentDayStatus = false;
  if (currentDayStatusStr) {
    currentDayStatus = JSON.parse(currentDayStatusStr) as boolean;
  }
  let store = new AchievementStore(maxConsecutiveDays, currentConsecutiveDays, currentDayStatus);
  await refreshAchievementFromDayInfo(store);
  return store;
}

export async function refreshAchievementFromDayInfo(achievementStore: AchievementStore): Promise<void> {
  let dayList: DayInfo[] = await DayInfoApi.query('SELECT * FROM dayInfo ORDER BY date');
  let maxStreak = 0;
  let currentStreak = 0;
  let previousDate = '';
  for (let dayInfo of dayList) {
    let completed = dayInfo.targetTaskNum > 0 && dayInfo.finTaskNum >= dayInfo.targetTaskNum;
    if (!completed) {
      currentStreak = 0;
      previousDate = '';
      continue;
    }
    if (previousDate !== '' && isNextDate(previousDate, dayInfo.date)) {
      currentStreak += 1;
    } else {
      currentStreak = 1;
    }
    previousDate = dayInfo.date;
    if (currentStreak > maxStreak) {
      maxStreak = currentStreak;
    }
  }

  achievementStore.maxConsecutiveDays = maxStreak;
  achievementStore.currentConsecutiveDays = calculateTodayStreak(dayList);
  achievementStore.currentDayStatus = achievementStore.currentConsecutiveDays > 0;
  await PreferencesUtils.putPreference(Const.MAX_CONSECUTIVE_DAYS, String(achievementStore.maxConsecutiveDays));
  await PreferencesUtils.putPreference(Const.CURRENT_CONSECUTIVE_DAYS, String(achievementStore.currentConsecutiveDays));
  await PreferencesUtils.putPreference(Const.CURRENT_DAY_STATUS, String(achievementStore.currentDayStatus));
}

/*
 * Update the information when the achievement information changes.
 * @param { TaskInfoDialogParams } params Task info for clock custom dialog parameters.
 */
export async function updateAchievementStore(params: TaskInfoDialogParams) {
  await refreshAchievementFromDayInfo(params.achievementStore);
  const achievementDoneIndex = getAchievementDoneIndex(params.achievementStore.maxConsecutiveDays);
  if (achievementDoneIndex !== -1) {
    openAchievementCustomDialog(params.uIContext, achievementDoneIndex);
  }
}

function isNextDate(previous: string, current: string): boolean {
  let date = convertStr2Date(previous);
  date.setDate(date.getDate() + 1);
  return convertDate2Str(date) === current;
}

function calculateTodayStreak(dayList: DayInfo[]): number {
  let expectedDate = convertDate2Str(new Date());
  let streak = 0;
  for (let index = dayList.length - 1; index >= 0; index--) {
    let dayInfo = dayList[index];
    if (dayInfo.date > expectedDate) {
      continue;
    }
    if (dayInfo.date < expectedDate) {
      break;
    }
    if (dayInfo.targetTaskNum > 0 && dayInfo.finTaskNum >= dayInfo.targetTaskNum) {
      streak += 1;
      let date = convertStr2Date(expectedDate);
      date.setDate(date.getDate() - 1);
      expectedDate = convertDate2Str(date);
    } else {
      break;
    }
  }
  return streak;
}
