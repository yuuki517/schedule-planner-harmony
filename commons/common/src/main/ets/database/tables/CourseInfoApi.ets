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
import { CourseInfo } from '../../model/database/CourseInfo';
import { RdbConstants } from '../../constants/RdbConstants';

const TAG: string = 'CourseInfoApi';
const TABLE_NAME: string = RdbConstants.TABLE_OF_COURSE;
const COLUMNS_INFO: ColumnInfo[] = RdbConstants.TABLE_COLUMNS_MAPPING[TABLE_NAME];
const PRIMARY_KEY: string = COLUMNS_INFO[0].name;

class CourseInfoApi implements TableApi<CourseInfo> {
  async insert(data: CourseInfo): Promise<number> {
    let result: number = -1;
    const valueBucket = this.convertEntity2ValuesBucket(data, true);
    await RdbUtils.rdbStore?.insert(TABLE_NAME, valueBucket,
      relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).then((rowId: number) => {
      result = rowId;
      hilog.info(0x0000, TAG, `Insert course is successful, data is ${data.toString()}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Insert course is failed, data is ${data.toString()}, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async batchInsert(dataList: CourseInfo[]): Promise<number> {
    let result: number = -1;
    const valueBucketList: relationalStore.ValuesBucket[] = [];
    for (let data of dataList) {
      valueBucketList.push(this.convertEntity2ValuesBucket(data, true));
    }
    await RdbUtils.rdbStore?.batchInsert(TABLE_NAME, valueBucketList).then((count: number) => {
      result = count;
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Batch insert course is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async delete(primaryKey: number | string): Promise<boolean> {
    let result = true;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.delete(predicates).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Delete course is failed, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  async update(primaryKey: number | string, data: CourseInfo): Promise<boolean> {
    let result = true;
    const valueBucket = this.convertEntity2ValuesBucket(data, true);
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.update(valueBucket, predicates,
      relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Update course is failed, code is ${err.code}, message is ${err.message}`);
      result = false;
    });
    return result;
  }

  async query(querySql: string): Promise<CourseInfo[]> {
    let resultList: CourseInfo[] = [];
    await RdbUtils.rdbStore?.querySql(querySql).then((resultSet: relationalStore.ResultSet) => {
      while (resultSet.goToNextRow()) {
        resultList.push(this.convertResultSet2Entity(resultSet));
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query course is failed, code is ${err.code}, message is ${err.message}`);
    });
    return resultList;
  }

  async queryByKey(primaryKey: number | string): Promise<CourseInfo | null> {
    let result: CourseInfo | null = null;
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo(PRIMARY_KEY, primaryKey);
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      if (resultSet.rowCount === 1) {
        resultSet.goToFirstRow();
        result = this.convertResultSet2Entity(resultSet);
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query course by key is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async queryAllCourseInfo(): Promise<CourseInfo[]> {
    let result: CourseInfo[] = [];
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.orderByAsc('weekday');
    predicates.orderByAsc('startTime');
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      while (resultSet.goToNextRow()) {
        result.push(this.convertResultSet2Entity(resultSet));
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query all course is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  async queryByWeekday(weekday: number): Promise<CourseInfo[]> {
    let result: CourseInfo[] = [];
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('weekday', weekday);
    predicates.orderByAsc('startTime');
    await RdbUtils.rdbStore?.query(predicates).then((resultSet: relationalStore.ResultSet) => {
      while (resultSet.goToNextRow()) {
        result.push(this.convertResultSet2Entity(resultSet));
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Query course by weekday is failed, code is ${err.code}, message is ${err.message}`);
    });
    return result;
  }

  convertEntity2ValuesBucket(data: CourseInfo, excludePrimary: boolean): relationalStore.ValuesBucket {
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
        case 'weekday':
          valueBucket[name] = data.weekday;
          break;
        case 'startTime':
          valueBucket[name] = data.startTime;
          break;
        case 'endTime':
          valueBucket[name] = data.endTime;
          break;
        case 'location':
          valueBucket[name] = data.location;
          break;
        case 'repeatRule':
          valueBucket[name] = data.repeatRule;
          break;
        default:
          break;
      }
    }
    return valueBucket;
  }

  convertResultSet2Entity(resultSet: relationalStore.ResultSet): CourseInfo {
    try {
      const id = resultSet.getValue(resultSet.getColumnIndex('id')) as number;
      const name = resultSet.getValue(resultSet.getColumnIndex('name')) as string;
      const weekday = resultSet.getValue(resultSet.getColumnIndex('weekday')) as number;
      const startTime = resultSet.getValue(resultSet.getColumnIndex('startTime')) as string;
      const endTime = resultSet.getValue(resultSet.getColumnIndex('endTime')) as string;
      const location = resultSet.getValue(resultSet.getColumnIndex('location')) as string;
      const repeatRule = resultSet.getValue(resultSet.getColumnIndex('repeatRule')) as string;
      return new CourseInfo(id, name, weekday, startTime, endTime, location, repeatRule);
    } catch (error) {
      hilog.error(0x0000, TAG, `an error occurred: ${error}`);
      return new CourseInfo(-1, '', 1, '', '', '', '');
    }
  }
}

export default new CourseInfoApi();