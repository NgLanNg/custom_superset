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
import { ScenarioChartFormData, ScenarioChartProps, ScenarioRow } from '../types';

export default function transformProps(chartProps: ChartProps): ScenarioChartProps {
    const { width, height, formData, queriesData } = chartProps;
    const fd = formData as ScenarioChartFormData;
    const rawData = queriesData[0]?.data || [];

    // Pivot rawData (tidy/long format) to ScenarioRow[] (pivoted/wide format)
    // Assumes database results contain 'opu' (asset), 'year', and 'value' columns.
    const pivoted: Record<string, ScenarioRow> = {};

    rawData.forEach((row: any) => {
        // Standard Superset row keys depend on the query/dataset.
        // We look for 'opu' or 'asset' columns as the main pivot key.
        const asset = row.opu || row.asset || 'Unknown';

        if (!pivoted[asset]) {
            pivoted[asset] = {
                pId: row.project_id || asset,
                asset,
            };
        }

        const year = row.year;
        const value = row.value;
        if (year !== undefined && value !== undefined) {
            pivoted[asset][year] = value;
        }
    });

    return {
        width,
        height,
        data: Object.values(pivoted),
        scenarioName: fd.scenarioName ?? 'existing_assets',
        bu: fd.bu ?? 'LNGA',
    };
}
