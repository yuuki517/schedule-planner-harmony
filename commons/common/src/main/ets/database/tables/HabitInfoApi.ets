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
import { HabitInfo } from '../../model/database/HabitInfo';
import { RdbConstants } from '../../constants/RdbConstants';
import { convertDate2Str } from '../../utils/Utils';
import HabitCheckInInfoApi from './HabitCheckInInfoApi';

const TAG: string = 'HabitInfoApi';
const TABLE_NAME: string = RdbConstants.TABLE_OF_HABIT;
const COLUMNS_INFO: ColumnInfo[] = RdbConstants.TABLE_COLUMNS_MAPPING[TABLE_NAME];
const PRIMARY_KEY: string = COLUMNS_INFO[0].name;

class HabitInfoApi implements TableApi<HabitInfo> {
  async insert(data: HabitInfo): Promise<number> {
    let result: number = -1;
    const valueBucket = this.convertEntity2ValuesBucket(data, true);
    await RdbUtils.rdbStore?.insert(TABLE_NAME, valueBucket,
      relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).then((rowId: number) => {
      result = rowId;
      hilog.info(0x0000, TAG, `Insert habit is successful, data is ${data.toString()}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Insert habit is failed, data is ${data.toString()}, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async batchInsert(dataList: HabitInfo[]): Promise<number> {
    let result: number = -1;
    const valueBucketList: relationalStore.ValuesBucket[] = [];
    for (let data of dataList) {
      valueBucketList.push(this.convertEntity2ValuesBucket(data, true));
    }
    await RdbUtils.rdbStore?.batchInsert(TABLE_NAME, valueBucketList).then((count: number) => {
      result = count;
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Batch insert habit is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async delete(primaryKey: number | string): Promise<boolean> {
    await HabitCheckInInfoApi.deleteByHabit(Number(primaryKey));
    let result = true;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.delete(predicates).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Delete habit is failed, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  async update(primaryKey: number | string, data: HabitInfo): Promise<boolean> {
    let result = true;
    const valueBucket = this.convertEntity2ValuesBucket(data, true);
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.update(valueBucket, predicates,
      relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Update habit is failed, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  async query(querySql: string): Promise<HabitInfo[]> {
    let resultList: HabitInfo[] = [];
    await RdbUtils.rdbStore?.querySql(querySql).then((resultSet: relationalStore.ResultSet) => {
      while (resultSet.goToNextRow()) {
        resultList.push(this.convertResultSet2Entity(resultSet));
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query habit is failed, code is ${err.code}, message is ${err.message}`);
    });
    return resultList;
  }

  async queryByKey(primaryKey: number | string): Promise<HabitInfo | null> {
    let result: HabitInfo | null = null;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      if (resultSet.rowCount === 1) {
        resultSet.goToFirstRow();
        result = this.convertResultSet2Entity(resultSet);
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query habit by key is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async queryAllHabitInfo(): Promise<HabitInfo[]> {
    return await this.queryHabitInfoForDate(convertDate2Str(new Date()));
  }

  async queryHabitInfoForDate(date: string): Promise<HabitInfo[]> {
    let result: HabitInfo[] = [];
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.orderByAsc('id');
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      while (resultSet.goToNextRow()) {
        result.push(this.convertResultSet2Entity(resultSet));
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query habit for date is failed, code is ${err.code}, message is ${err.message}`);
    });
    return await HabitCheckInInfoApi.fillHabitStats(result, date);
  }

  convertEntity2ValuesBucket(data: HabitInfo, excludePrimary: boolean): relationalStore.ValuesBucket {
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
        case 'name':
          valueBucket[name] = data.name;
          break;
        case 'estimateMinutes':
          valueBucket[name] = data.estimateMinutes;
          break;
        case 'isFixedTime':
          valueBucket[name] = data.isFixedTime;
          break;
        case 'fixedTime':
          valueBucket[name] = data.fixedTime;
          break;
        case 'isDone':
          valueBucket[name] = data.isDone;
          break;
        case 'reminderId':
          valueBucket[name] = data.reminderId;
          break;
        default:
          break;
      }
    }
    return valueBucket;
  }

  convertResultSet2Entity(resultSet: relationalStore.ResultSet): HabitInfo {
    try {
      const id = resultSet.getValue(resultSet.getColumnIndex('id')) as number;
      const name = resultSet.getValue(resultSet.getColumnIndex('name')) as string;
      const estimateMinutes = resultSet.getValue(resultSet.getColumnIndex('estimateMinutes')) as number;
      const isFixedTime = resultSet.getValue(resultSet.getColumnIndex('isFixedTime')) ? true : false;
      const fixedTime = resultSet.getValue(resultSet.getColumnIndex('fixedTime')) as string;
      const isDone = resultSet.getValue(resultSet.getColumnIndex('isDone')) ? true : false;
      const reminderId = resultSet.getValue(resultSet.getColumnIndex('reminderId')) as number;
      return new HabitInfo(id, name, estimateMinutes, isFixedTime, fixedTime, isDone, reminderId);
    } catch (error) {
      hilog.error(0x0000, TAG, `an error occurred: ${error}`);
      return new HabitInfo(-1, '', 0, false, '', false, -1);
    }
  }
}

export default new HabitInfoApi();