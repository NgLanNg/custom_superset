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

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import * as echarts from 'echarts/core';
import { LineChart } from 'echarts/charts';
import {
  GridComponent,
  LegendComponent,
  TitleComponent,
  TooltipComponent,
} from 'echarts/components';
import { CanvasRenderer } from 'echarts/renderers';
import styled from '@emotion/styled';
import { SupersetClient } from '@superset-ui/core';
import type { FilterState, EmissionRow, ChartDataPoint } from './types';

echarts.use([
  LineChart,
  GridComponent,
  LegendComponent,
  TitleComponent,
  TooltipComponent,
  CanvasRenderer,
]);

const ChartWrapper = styled.div`
  position: relative;
  background: #fff;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
  padding: 16px;
`;

const ChartTitle = styled.h3`
  margin: 0 0 8px;
  font-size: 14px;
  font-weight: 600;
  color: #262626;
`;

const ChartContainer = styled.div`
  width: 100%;
  height: 260px;
`;

const LoadingText = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  height: 260px;
  color: #8c8c8c;
  font-size: 13px;
`;

interface ComparativeChartProps {
  filters: FilterState;
  scenarioId: string;
}

export function buildChartTitle(filters: FilterState): string {
  const base = 'Comparative Total GHG Emissions';
  if (filters.opu) return `${base} \u2013 ${filters.opu}`;
  if (filters.bu) return `${base} \u2013 ${filters.bu}`;
  return base;
}

export function ComparativeChart({ filters, scenarioId }: ComparativeChartProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const chartRef = useRef<echarts.ECharts | null>(null);
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<ChartDataPoint[]>([]);

  const title = useMemo(() => buildChartTitle(filters), [filters]);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({ scenario_id: scenarioId });
      if (filters.bu) params.set('bu', filters.bu);
      if (filters.opu) params.set('opu', filters.opu);
      if (filters.scope) params.set('scope', filters.scope);
      if (filters.source) params.set('source', filters.source);

      const response = await SupersetClient.get({
        endpoint: `/api/v1/scenario/emission-sources?${params.toString()}`,
      });

      const rows: EmissionRow[] = (response.json as { data: EmissionRow[] }).data || [];

      // Aggregate by year
      const byYear: Record<number, number> = {};
      rows.forEach(r => {
        byYear[r.year] = (byYear[r.year] ?? 0) + r.value;
      });

      const points = Object.entries(byYear)
        .map(([yr, val]) => ({ year: Number(yr), value: val }))
        .sort((a, b) => a.year - b.year);

      setData(points);
    } catch {
      setData([]);
    } finally {
      setLoading(false);
    }
  }, [filters, scenarioId]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  useEffect(() => {
    if (!containerRef.current) return;
    if (!chartRef.current) {
      chartRef.current = echarts.init(containerRef.current);
    }
    const chart = chartRef.current;
    const years = data.map(d => d.year);
    const values = data.map(d => Math.round(d.value * 10) / 10);

    chart.setOption({
      grid: { top: 20, right: 20, bottom: 40, left: 60 },
      xAxis: { type: 'category', data: years, axisLabel: { fontSize: 11 } },
      yAxis: {
        type: 'value',
        name: 'tCO\u2082e',
        nameTextStyle: { fontSize: 11 },
        axisLabel: { fontSize: 11 },
      },
      tooltip: {
        trigger: 'axis',
        formatter: (params: { name: string; value: number }[]) => {
          const p = params[0];
          return `${p.name}: ${p.value.toLocaleString()} tCO\u2082e`;
        },
      },
      series: [
        {
          type: 'line',
          data: values,
          smooth: true,
          lineStyle: { width: 2, color: '#1890ff' },
          itemStyle: { color: '#1890ff' },
          areaStyle: { color: 'rgba(24,144,255,0.06)' },
          symbol: 'circle',
          symbolSize: 5,
        },
      ],
    });
  }, [data]);

  useEffect(() => {
    const resize = () => chartRef.current?.resize();
    window.addEventListener('resize', resize);
    return () => window.removeEventListener('resize', resize);
  }, []);

  useEffect(
    () => () => {
      chartRef.current?.dispose();
      chartRef.current = null;
    },
    [],
  );

  return (
    <ChartWrapper>
      <ChartTitle data-test="chart-title">{title}</ChartTitle>
      {loading ? (
        <LoadingText>Loading...</LoadingText>
      ) : (
        <ChartContainer ref={containerRef} />
      )}
    </ChartWrapper>
  );
}
