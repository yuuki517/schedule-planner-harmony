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
import { StudyTaskInfo } from '../../model/database/StudyTaskInfo';
import { RdbConstants } from '../../constants/RdbConstants';

const TAG: string = 'StudyTaskInfoApi';
const TABLE_NAME: string = RdbConstants.TABLE_OF_STUDY_TASK;
const COLUMNS_INFO: ColumnInfo[] = RdbConstants.TABLE_COLUMNS_MAPPING[TABLE_NAME];
const PRIMARY_KEY: string = COLUMNS_INFO[0].name;

class StudyTaskInfoApi implements TableApi<StudyTaskInfo> {
  async insert(data: StudyTaskInfo): Promise<number> {
    let result: number = -1;
    const valueBucket = this.convertEntity2ValuesBucket(data, true);
    await RdbUtils.rdbStore?.insert(TABLE_NAME, valueBucket,
      relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).then((rowId: number) => {
      result = rowId;
      hilog.info(0x0000, TAG, `Insert study task is successful, data is ${data.toString()}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Insert study task is failed, data is ${data.toString()}, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async batchInsert(dataList: StudyTaskInfo[]): Promise<number> {
    let result: number = -1;
    const valueBucketList: relationalStore.ValuesBucket[] = [];
    for (let data of dataList) {
      valueBucketList.push(this.convertEntity2ValuesBucket(data, true));
    }
    await RdbUtils.rdbStore?.batchInsert(TABLE_NAME, valueBucketList).then((count: number) => {
      result = count;
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Batch insert study task is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async delete(primaryKey: number | string): Promise<boolean> {
    let result = true;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.delete(predicates).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Delete study task is failed, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  async update(primaryKey: number | string, data: StudyTaskInfo): Promise<boolean> {
    let result = true;
    const valueBucket = this.convertEntity2ValuesBucket(data, true);
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.update(valueBucket, predicates,
      relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Update study task is failed, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  async query(querySql: string): Promise<StudyTaskInfo[]> {
    let resultList: StudyTaskInfo[] = [];
    await RdbUtils.rdbStore?.querySql(querySql).then((resultSet: relationalStore.ResultSet) => {
      while (resultSet.goToNextRow()) {
        resultList.push(this.convertResultSet2Entity(resultSet));
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query study task is failed, code is ${err.code}, message is ${err.message}`);
    });
    return resultList;
  }

  async queryByKey(primaryKey: number | string): Promise<StudyTaskInfo | null> {
    let result: StudyTaskInfo | null = null;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      if (resultSet.rowCount === 1) {
        resultSet.goToFirstRow();
        result = this.convertResultSet2Entity(resultSet);
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query study task by key is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async queryOpenStudyTaskInfo(): Promise<StudyTaskInfo[]> {
    let result: StudyTaskInfo[] = [];
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('isDone', false);
    predicates.orderByAsc('dueDate');
    predicates.orderByAsc('dueTime');
    predicates.orderByAsc('priority');
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      while (resultSet.goToNextRow()) {
        result.push(this.convertResultSet2Entity(resultSet));
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query open study task is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  convertEntity2ValuesBucket(data: StudyTaskInfo, excludePrimary: boolean): relationalStore.ValuesBucket {
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
        case 'dueDate':
          valueBucket[name] = data.dueDate;
          break;
        case 'dueTime':
          valueBucket[name] = data.dueTime;
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
        case 'isDone':
          valueBucket[name] = data.isDone;
          break;
        default:
          break;
      }
    }
    return valueBucket;
  }

  convertResultSet2Entity(resultSet: relationalStore.ResultSet): StudyTaskInfo {
    try {
      const id = resultSet.getValue(resultSet.getColumnIndex('id')) as number;
      const title = resultSet.getValue(resultSet.getColumnIndex('title')) as string;
      const courseName = resultSet.getValue(resultSet.getColumnIndex('courseName')) as string;
      const dueDate = resultSet.getValue(resultSet.getColumnIndex('dueDate')) as string;
      const dueTime = resultSet.getValue(resultSet.getColumnIndex('dueTime')) as string;
      const estimateMinutes = resultSet.getValue(resultSet.getColumnIndex('estimateMinutes')) as number;
      const priority = resultSet.getValue(resultSet.getColumnIndex('priority')) as number;
      const note = resultSet.getValue(resultSet.getColumnIndex('note')) as string;
      const isDone = resultSet.getValue(resultSet.getColumnIndex('isDone')) ? true : false;
      return new StudyTaskInfo(id, title, courseName, dueDate, dueTime, estimateMinutes, priority, note, isDone);
    } catch (error) {
      hilog.error(0x0000, TAG, `an error occurred: ${error}`);
      return new StudyTaskInfo(-1, '', '', '', '', 0, 2, '', false);
    }
  }
}

export default new StudyTaskInfoApi();