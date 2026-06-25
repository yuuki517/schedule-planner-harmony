/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { RdbUtils } from '../RdbUtils';
import { HabitInfo } from '../../model/database/HabitInfo';
import { convertDate2Str, convertStr2Date } from '../../utils/Utils';

const TAG: string = 'HabitCheckInInfoApi';
const TABLE_NAME: string = 'habitCheckInInfo';

class HabitCheckInInfoApi {
  async ensureTable(): Promise<void> {
    await RdbUtils.executeSql(`create table if not exists ${TABLE_NAME}(id integer primary key autoincrement, habitId integer not null, date text(8) not null, isDone boolean not null)`);
  }

  async checkIn(habitId: number, date: string): Promise<boolean> {
    await this.ensureTable();
    await RdbUtils.executeSql(`DELETE FROM ${TABLE_NAME} WHERE habitId = ${habitId} AND date = '${date}'`);
    return await RdbUtils.executeSql(`INSERT INTO ${TABLE_NAME}(habitId, date, isDone) VALUES(${habitId}, '${date}', true)`);
  }

  async cancelCheckIn(habitId: number, date: string): Promise<boolean> {
    await this.ensureTable();
    return await RdbUtils.executeSql(`DELETE FROM ${TABLE_NAME} WHERE habitId = ${habitId} AND date = '${date}'`);
  }

  async toggleCheckIn(habitId: number, date: string): Promise<boolean> {
    let checked = await this.isChecked(habitId, date);
    if (checked) {
      return await this.cancelCheckIn(habitId, date);
    }
    return await this.checkIn(habitId, date);
  }

  async deleteByHabit(habitId: number): Promise<boolean> {
    await this.ensureTable();
    return await RdbUtils.executeSql(`DELETE FROM ${TABLE_NAME} WHERE habitId = ${habitId}`);
  }

  async isChecked(habitId: number, date: string): Promise<boolean> {
    let count = await this.queryCount(`SELECT COUNT(1) AS cnt FROM ${TABLE_NAME} WHERE habitId = ${habitId} AND date = '${date}' AND isDone = true`);
    return count > 0;
  }

  async countByHabit(habitId: number): Promise<number> {
    return await this.queryCount(`SELECT COUNT(1) AS cnt FROM ${TABLE_NAME} WHERE habitId = ${habitId} AND isDone = true`);
  }

  async streakByHabit(habitId: number, date: string): Promise<number> {
    await this.ensureTable();
    let currentDate = convertStr2Date(date);
    let streak = 0;
    for (let index = 0; index < 366; index++) {
      let dateStr = convertDate2Str(currentDate);
      if (await this.isChecked(habitId, dateStr)) {
        streak += 1;
        currentDate.setDate(currentDate.getDate() - 1);
      } else {
        break;
      }
    }
    return streak;
  }

  async fillHabitStats(habitList: HabitInfo[], date: string): Promise<HabitInfo[]> {
    await this.ensureTable();
    for (let habit of habitList) {
      habit.todayDone = await this.isChecked(habit.id, date);
      habit.currentStreak = await this.streakByHabit(habit.id, date);
      habit.totalCheckIn = await this.countByHabit(habit.id);
    }
    return habitList;
  }

  async queryCount(querySql: string): Promise<number> {
    await this.ensureTable();
    let count = 0;
    await RdbUtils.rdbStore?.querySql(querySql).then((resultSet: relationalStore.ResultSet) => {
      if (resultSet.goToFirstRow()) {
        count = resultSet.getValue(resultSet.getColumnIndex('cnt')) as number;
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query habit check-in count is failed, code is ${err.code}, message is ${err.message}`);
    });
    return count;
  }
}

export default new HabitCheckInInfoApi();
