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

import {
  convertDate2Str, CourseInfo, DayInfo, DayTaskInfo, HabitInfo, PlanTaskInfo, StudyTaskInfo
} from 'common';
import DayInfoApi from 'common/src/main/ets/database/tables/DayInfoApi';
import TaskInfoApi from 'common/src/main/ets/database/tables/TaskInfoApi';
import DayTaskInfoApi from 'common/src/main/ets/database/tables/DayTaskInfoApi';
import CourseInfoApi from 'common/src/main/ets/database/tables/CourseInfoApi';
import StudyTaskInfoApi from 'common/src/main/ets/database/tables/StudyTaskInfoApi';
import PlanTaskInfoApi from 'common/src/main/ets/database/tables/PlanTaskInfoApi';
import HabitInfoApi from 'common/src/main/ets/database/tables/HabitInfoApi';

@Observed
export class HomeStore {
  public weekList: DayInfo[];
  public selectedDay: number;
  public currentDate: string;
  public taskList: DayTaskInfo[];
  public courseList: CourseInfo[];
  public studyTaskList: StudyTaskInfo[];
  public planTaskList: PlanTaskInfo[];
  public donePlanTaskList: PlanTaskInfo[];
  public habitList: HabitInfo[];

  constructor(weekList: DayInfo[], selectedDay: number, currentDate: string, taskList: DayTaskInfo[],
    courseList: CourseInfo[], studyTaskList: StudyTaskInfo[], planTaskList: PlanTaskInfo[],
    donePlanTaskList: PlanTaskInfo[], habitList: HabitInfo[]) {
    this.weekList = weekList;
    this.selectedDay = selectedDay;
    this.currentDate = currentDate;
    this.taskList = taskList;
    this.courseList = courseList;
    this.studyTaskList = studyTaskList;
    this.planTaskList = planTaskList;
    this.donePlanTaskList = donePlanTaskList;
    this.habitList = habitList;
  }

  public checkCurrentDay(): boolean {
    return convertDate2Str(new Date()) === this.currentDate;
  }
}

export async function initCurrentDateInfo(date: Date): Promise<HomeStore> {
  let selectedDay = getMondayBasedIndex(date);
  let weekList: DayInfo[] = await getCurrentWeekInfo(date);
  let dateStr = convertDate2Str(date);
  let taskList: DayTaskInfo[] = await DayTaskInfoApi.queryDayTaskInfo(dateStr);
  if (taskList.length === 0 && date > new Date()) {
    let openedTaskList = await TaskInfoApi.queryOpenedTaskInfo();
    for (let openedTask of openedTaskList) {
      taskList.push(openedTask.convert2DefaultDayTask(dateStr))
    }
  }
  let weekday = date.getDay() === 0 ? 7 : date.getDay();
  let courseList: CourseInfo[] = await CourseInfoApi.queryByWeekday(weekday);
  let studyTaskList: StudyTaskInfo[] = await StudyTaskInfoApi.queryOpenStudyTaskInfo();
  let planTaskList: PlanTaskInfo[] = await PlanTaskInfoApi.queryOpenPlanTaskInfo(dateStr);
  let donePlanTaskList: PlanTaskInfo[] = await PlanTaskInfoApi.queryDonePlanTaskInfo(dateStr);
  let habitList: HabitInfo[] = await HabitInfoApi.queryHabitInfoForDate(dateStr);
  return new HomeStore(weekList, selectedDay, dateStr, taskList, courseList, studyTaskList, planTaskList,
    donePlanTaskList, habitList);
}

export async function updateTaskList(homeStore: HomeStore): Promise<void> {
  let dateStr = homeStore.currentDate;
  let taskList: DayTaskInfo[] = await DayTaskInfoApi.queryDayTaskInfo(dateStr);
  if (taskList.length === 0) {
    let openedTaskList = await TaskInfoApi.queryOpenedTaskInfo();
    for (let openedTask of openedTaskList) {
      taskList.push(openedTask.convert2DefaultDayTask(dateStr))
    }
  }
  homeStore.taskList = taskList;
  await updateCourseList(homeStore);
  await updateStudyTaskList(homeStore);
  await updatePlanTaskList(homeStore);
  await updateHabitList(homeStore);
}

export async function updateHabitList(homeStore: HomeStore): Promise<void> {
  homeStore.habitList = await HabitInfoApi.queryHabitInfoForDate(homeStore.currentDate);
}

export async function updatePlanTaskList(homeStore: HomeStore): Promise<void> {
  homeStore.planTaskList = await PlanTaskInfoApi.queryOpenPlanTaskInfo(homeStore.currentDate);
  homeStore.donePlanTaskList = await PlanTaskInfoApi.queryDonePlanTaskInfo(homeStore.currentDate);
  await refreshPlanProgress(homeStore);
}

export async function refreshPlanProgress(homeStore: HomeStore): Promise<void> {
  homeStore.weekList = await getCurrentWeekInfo(convertStr2SafeDate(homeStore.currentDate));
}

export async function updateStudyTaskList(homeStore: HomeStore): Promise<void> {
  homeStore.studyTaskList = await StudyTaskInfoApi.queryOpenStudyTaskInfo();
}

export async function updateCourseList(homeStore: HomeStore): Promise<void> {
  let selectedDate = convertStr2SafeDate(homeStore.currentDate);
  let weekday = selectedDate.getDay() === 0 ? 7 : selectedDate.getDay();
  homeStore.courseList = await CourseInfoApi.queryByWeekday(weekday);
}

async function getCurrentWeekInfo(date: Date): Promise<DayInfo[]> {
  let selectedDay = getMondayBasedIndex(date);
  let monday = new Date(date);
  monday.setDate(date.getDate() - selectedDay);
  let weekList: DayInfo[] = [];
  for (let index = 0; index < 7; index++) {
    let current = new Date(monday);
    current.setDate(monday.getDate() + index);
    weekList.push(await calculatePlanDayInfo(convertDate2Str(current)));
  }
  return weekList;
}

async function calculatePlanDayInfo(date: string): Promise<DayInfo> {
  let openList: PlanTaskInfo[] = await PlanTaskInfoApi.queryOpenPlanTaskInfo(date);
  let doneList: PlanTaskInfo[] = await PlanTaskInfoApi.queryDonePlanTaskInfo(date);
  let target = openList.length + doneList.length;
  let finished = doneList.length;
  await DayInfoApi.updateByKey(date, target, finished);
  return new DayInfo(date, target, finished);
}

function getMondayBasedIndex(date: Date): number {
  let dayOfWeek = date.getDay();
  return dayOfWeek === 0 ? 6 : dayOfWeek - 1;
}

function convertStr2SafeDate(date: string): Date {
  const year = Number(date.substring(0, 4));
  const month = Number(date.substring(4, 6)) - 1;
  const day = Number(date.substring(6, 8));
  return new Date(year, month, day);
}
