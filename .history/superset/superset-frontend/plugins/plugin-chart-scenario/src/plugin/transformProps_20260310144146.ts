/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
import { ChartProps } from '@superset-ui/core';
import { ScenarioChartFormData, ScenarioChartProps, ExistingAssetRow, GrowthProjectRow } from '../types';
import { YEARS } from '../mockData';

export default function transformProps(chartProps: ChartProps): ScenarioChartProps {
  const { width, height, formData, queriesData } = chartProps;
  const fd = formData as ScenarioChartFormData;
  const rawData = queriesData?.[0]?.data || [];

  const existingMap: Record<string, ExistingAssetRow> = {};
  const growthMap: Record<string, GrowthProjectRow> = {};

  rawData.forEach((row: any) => {
    const bu = row.bu || 'Unknown';
    const opu = row.opu || row.asset || 'Unknown';
    const isGrowth = row.is_growth === 1 || row.is_growth === true || ['LNGC2', 'Suriname F2', 'Lake Charles', 'Calathea', 'Asters'].includes(opu);

    if (isGrowth) {
      if (!growthMap[opu]) {
        growthMap[opu] = { bu, project: opu, vals: new Array(YEARS.length).fill(0) };
      }
      const yrIndex = YEARS.indexOf(row.year);
      if (yrIndex !== -1) {
        growthMap[opu].vals[yrIndex] = row.value || 0;
      }
    } else {
      if (!existingMap[opu]) {
        existingMap[opu] = { bu, gpu: opu, vals: new Array(YEARS.length).fill(0) };
      }
      const yrIndex = YEARS.indexOf(row.year);
      if (yrIndex !== -1) {
        existingMap[opu].vals[yrIndex] = row.value || 0;
      }
    }
  });

  return {
    width,
    height,
    existingData: Object.values(existingMap),
    growthData: Object.values(growthMap),
    scenarioName: fd.scenarioName ?? 'existing_assets',
    bu: fd.bu ?? 'LNGA',
  };
}
