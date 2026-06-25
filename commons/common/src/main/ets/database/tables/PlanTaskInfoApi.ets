/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0
 */

import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { RdbUtils } from '../RdbUtils';
import { TableApi } from './TableApi';
import ColumnInfo from '../../model/ColumnModel';
import { PlanTaskInfo } from '../../model/database/PlanTaskInfo';
import { RdbConstants } from '../../constants/RdbConstants';

const TAG: string = 'PlanTaskInfoApi';
const TABLE_NAME: string = RdbConstants.TABLE_OF_PLAN_TASK;
const COLUMNS_INFO: ColumnInfo[] = RdbConstants.TABLE_COLUMNS_MAPPING[TABLE_NAME];
const PRIMARY_KEY: string = COLUMNS_INFO[0].name;

class PlanTaskInfoApi implements TableApi<PlanTaskInfo> {
  async ensureScheduleColumn(defaultDate: string): Promise<void> {
    await RdbUtils.executeSql(`ALTER TABLE ${TABLE_NAME} ADD COLUMN scheduledDate text`);
    await RdbUtils.executeSql(`UPDATE ${TABLE_NAME} SET scheduledDate = '${defaultDate}' WHERE scheduledDate IS NULL OR scheduledDate = ''`);
  }

  async insert(data: PlanTaskInfo): Promise<number> {
    await this.ensureScheduleColumn(data.scheduledDate);
    let result: number = -1;
    const valueBucket = this.convertEntity2ValuesBucket(data, true);
    await RdbUtils.rdbStore?.insert(TABLE_NAME, valueBucket,
      relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).then((rowId: number) => {
      result = rowId;
      hilog.info(0x0000, TAG, `Insert plan task is successful, data is ${data.toString()}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Insert plan task is failed, data is ${data.toString()}, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async batchInsert(dataList: PlanTaskInfo[]): Promise<number> {
    let result: number = -1;
    const valueBucketList: relationalStore.ValuesBucket[] = [];
    for (let data of dataList) {
      await this.ensureScheduleColumn(data.scheduledDate);
      valueBucketList.push(this.convertEntity2ValuesBucket(data, true));
    }
    await RdbUtils.rdbStore?.batchInsert(TABLE_NAME, valueBucketList).then((count: number) => {
      result = count;
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Batch insert plan task is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async delete(primaryKey: number | string): Promise<boolean> {
    let result = true;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.delete(predicates).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Delete plan task is failed, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  async update(primaryKey: number | string, data: PlanTaskInfo): Promise<boolean> {
    await this.ensureScheduleColumn(data.scheduledDate);
    let result = true;
    const valueBucket = this.convertEntity2ValuesBucket(data, true);
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.update(valueBucket, predicates,
      relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Update plan task is failed, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  async query(querySql: string): Promise<PlanTaskInfo[]> {
    let resultList: PlanTaskInfo[] = [];
    await RdbUtils.rdbStore?.querySql(querySql).then((resultSet: relationalStore.ResultSet) => {
      while (resultSet.goToNextRow()) {
        resultList.push(this.convertResultSet2Entity(resultSet));
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query plan task is failed, code is ${err.code}, message is ${err.message}`);
    });
    return resultList;
  }

  async queryByKey(primaryKey: number | string): Promise<PlanTaskInfo | null> {
    let result: PlanTaskInfo | null = null;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      if (resultSet.rowCount === 1) {
        resultSet.goToFirstRow();
        result = this.convertResultSet2Entity(resultSet);
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query plan task by key is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async queryPlanTaskInfoByDate(date: string, isDone: boolean): Promise<PlanTaskInfo[]> {
    await this.ensureScheduleColumn(date);
    let querySql = `SELECT * FROM ${TABLE_NAME} WHERE isDone = ${isDone ? 'true' : 'false'} AND scheduledDate = '${date}' ORDER BY id`;
    return await this.query(querySql);
  }

  async updateScheduledDate(primaryKey: number | string, scheduledDate: string): Promise<boolean> {
    await this.ensureScheduleColumn(scheduledDate);
    let result = true;
    await RdbUtils.executeSql(`UPDATE ${TABLE_NAME} SET scheduledDate = '${scheduledDate}', isDone = false WHERE ${PRIMARY_KEY} = ${primaryKey}`).then((success: boolean) => {
      result = success;
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Postpone plan task is failed, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  async queryOpenPlanTaskInfo(date: string): Promise<PlanTaskInfo[]> {
    return await this.queryPlanTaskInfoByDate(date, false);
  }

  async queryDonePlanTaskInfo(date: string): Promise<PlanTaskInfo[]> {
    return await this.queryPlanTaskInfoByDate(date, true);
  }

  async queryAllPlanTaskInfo(): Promise<PlanTaskInfo[]> {
    await this.ensureScheduleColumn('');
    return await this.query(`SELECT * FROM ${TABLE_NAME} ORDER BY id`);
  }

  convertEntity2ValuesBucket(data: PlanTaskInfo, excludePrimary: boolean): relationalStore.ValuesBucket {
    let valueBucket = {} as relationalStore.ValuesBucket;
    for (let item of COLUMNS_INFO) {
      if (excludePrimary && item.primary) {
        continue;
      }
      let name = item.name;
      switch (name) {
        case 'id':
          valueBucket[name] = data.id;
          break;
        case 'title':
          valueBucket[name] = data.title;
          break;
        case 'courseName':
          valueBucket[name] = data.courseName;
          break;
        case 'estimateMinutes':
          valueBucket[name] = data.estimateMinutes;
          break;
        case 'priority':
          valueBucket[name] = data.priority;
          break;
        case 'note':
          valueBucket[name] = data.note;
          break;
        case 'scheduledDate':
          valueBucket[name] = data.scheduledDate;
          break;
        case 'isDone':
          valueBucket[name] = data.isDone;
          break;
        default:
          break;
      }
    }
    return valueBucket;
  }

  convertResultSet2Entity(resultSet: relationalStore.ResultSet): PlanTaskInfo {
    try {
      const id = resultSet.getValue(resultSet.getColumnIndex('id')) as number;
      const title = resultSet.getValue(resultSet.getColumnIndex('title')) as string;
      const courseName = resultSet.getValue(resultSet.getColumnIndex('courseName')) as string;
      const estimateMinutes = resultSet.getValue(resultSet.getColumnIndex('estimateMinutes')) as number;
      const priority = resultSet.getValue(resultSet.getColumnIndex('priority')) as number;
      const note = resultSet.getValue(resultSet.getColumnIndex('note')) as string;
      let scheduledDate = '';
      try {
        scheduledDate = resultSet.getValue(resultSet.getColumnIndex('scheduledDate')) as string;
      } catch (error) {
        scheduledDate = '';
      }
      const isDone = resultSet.getValue(resultSet.getColumnIndex('isDone')) ? true : false;
      return new PlanTaskInfo(id, title, courseName, estimateMinutes, priority, note, scheduledDate, isDone);
    } catch (error) {
      hilog.error(0x0000, TAG, `an error occurred: ${error}`);
      return new PlanTaskInfo(-1, '', '', 0, 2, '', '', false);
    }
  }
}

export default new PlanTaskInfoApi();
