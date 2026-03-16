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
import { useState } from 'react';
import { Tabs } from 'antd';
import { EditableCell } from '@superset-ui/writeback';
import Echart from '../../plugin-chart-echarts/src/components/Echart';

import {
  ChartBadge,
  ChartHeader,
  ChartPanel,
  DataTable,
  EmptyState,
  FilterBtn,
  InfoBannerWrap,
  ScenarioContainer,
  SectionCard,
  SectionHead,
  SectionTitleWrap,
  StatCard,
  StatsRowWrap,
  TabContent,
} from './ScenarioChart.styles';
import { YEARS } from './mockData';
import type { ScenarioChartProps } from './types';
import { useScenarioData } from './useScenarioData';
import { useGrowthConfig } from './useGrowthConfig';

const MIN_VALUE = 0;
const MAX_VALUE = 100;

export default function ScenarioChart(props: ScenarioChartProps) {
  const {
    height,
    width,
    scenarioName = 'existing_assets',
    bu = 'LNGA',
    existingData: realExisting,
    growthData: realGrowth,
  } = props;

  const [activeTab, setActiveTab] = useState('equity');

  const {
    existingData,
    growthData,
    stats,
    chartOptions,
    handleSave,
  } = useScenarioData({
    existingData: realExisting,
    growthData: realGrowth,
    scenarioName,
  });

  const { rows: growthConfigRows, saveCell: saveGrowthCell } = useGrowthConfig(scenarioName, bu);

  return (
    <ScenarioContainer style={{ height, width }}>
      <InfoBannerWrap>
        <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z"
          />
        </svg>
        <div className="info-text">
          <strong>Source File Reference:</strong> <a href="/">Output SBD Growth.xlsx</a>
          <p>Edits propagate in real time and update the chart below. Each chart point shows the equity % for that asset.</p>
        </div>
      </InfoBannerWrap>

      <Tabs
        activeKey={activeTab}
        onChange={setActiveTab}
        items={[
          {
            key: 'equity', label: 'Equity Share Configuration', children: (
              <TabContent>
                <ChartPanel>
                  <ChartHeader>
                    <div>
                      <div className="chart-title">Equity Share Overview — Live Preview</div>
                      <div className="chart-meta">Shows equity % per asset across all years. Updates instantly on edit.</div>
                    </div>
                    <ChartBadge variant="up">
                      <svg width="10" height="10" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2.5">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 10.5L12 3m0 0l7.5 7.5M12 3v18" />
                      </svg>
                      Avg <span>{stats.avgEquity.toFixed(1)}%</span>
                    </ChartBadge>
                  </ChartHeader>
                  <Echart
                    width={width - 64}
                    height={260}
                    echartOptions={chartOptions}
                    refs={{}}
                  />
                </ChartPanel>

                <StatsRowWrap>
                  <StatCard>
                    <div className="stat-label">Total Assets</div>
                    <div className="stat-value">{stats.totalAssets}</div>
                    <div className="stat-delta delta-up">rows configured</div>
                  </StatCard>
                  <StatCard>
                    <div className="stat-label">Avg Equity Share</div>
                    <div className="stat-value">{stats.avgEquity.toFixed(1)}<small>%</small></div>
                    <div className="stat-delta delta-up">Above threshold</div>
                  </StatCard>
                  <StatCard>
                    <div className="stat-label">Max Equity</div>
                    <div className="stat-value">{stats.maxEquity.toFixed(0)}<small>%</small></div>
                    <div className="stat-delta">Reference baseline</div>
                  </StatCard>
                  <StatCard>
                    <div className="stat-label">Min Equity</div>
                    <div className="stat-value">{stats.minEquity.toFixed(0)}<small>%</small></div>
                    <div className="stat-delta delta-dn">Below threshold</div>
                  </StatCard>
                </StatsRowWrap>

                <SectionCard>
                  <SectionHead>
                    <SectionTitleWrap>
                      <div className="section-accent" />
                      <div className="section-title">Equity Share — Existing Assets</div>
                    </SectionTitleWrap>
                    <FilterBtn>
                      <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M12 3c2.755 0 5.455.232 8.083.678.533.09.917.556.917 1.096v1.044a2.25 2.25 0 01-.659 1.591l-5.432 5.432a2.25 2.25 0 00-.659 1.591v2.927a2.25 2.25 0 01-1.244 2.013L9.75 21v-6.568a2.25 2.25 0 00-.659-1.591L3.659 7.409A2.25 2.25 0 013 5.818V4.774c0-.54.384-1.006.917-1.096A48.32 48.32 0 0112 3z" />
                      </svg>
                      Filter
                    </FilterBtn>
                  </SectionHead>
                  <DataTable>
                    <thead>
                      <tr>
                        <th>BU</th>
                        <th>GPU</th>
                        {YEARS.map(year => (
                          <th key={`existing-head-${year}`}>{year}</th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {existingData.map((row, rowIndex) => (
                        <tr key={`existing-row-${row.gpu}`}>
                          <td>{row.bu}</td>
                          <td>{row.gpu}</td>
                          {row.vals.map((val, yearIndex) => (
                            <td key={`existing-${row.gpu}-${YEARS[yearIndex]}`}>
                              <EditableCell
                                value={val}
                                min={MIN_VALUE}
                                max={MAX_VALUE}
                                onSave={next => handleSave('existing', rowIndex, yearIndex, next)}
                              />
                            </td>
                          ))}
                        </tr>
                      ))}
                    </tbody>
                  </DataTable>
                </SectionCard>

                <SectionCard>
                  <SectionHead>
                    <SectionTitleWrap>
                      <div className="section-accent" />
                      <div className="section-title">Equity Share — Growth Projects</div>
                    </SectionTitleWrap>
                    <FilterBtn>
                      <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M12 3c2.755 0 5.455.232 8.083.678.533.09.917.556.917 1.096v1.044a2.25 2.25 0 01-.659 1.591l-5.432 5.432a2.25 2.25 0 00-.659 1.591v2.927a2.25 2.25 0 01-1.244 2.013L9.75 21v-6.568a2.25 2.25 0 00-.659-1.591L3.659 7.409A2.25 2.25 0 013 5.818V4.774c0-.54.384-1.006.917-1.096A48.32 48.32 0 0112 3z" />
                      </svg>
                      Filter
                    </FilterBtn>
                  </SectionHead>
                  <DataTable>
                    <thead>
                      <tr>
                        <th>BU</th>
                        <th>Projects</th>
                        {YEARS.map(year => (
                          <th key={`growth-head-${year}`}>{year}</th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {growthData.map((row, rowIndex) => (
                        <tr key={`growth-row-${row.project}`}>
                          <td>{row.bu}</td>
                          <td>{row.project}</td>
                          {row.vals.map((val, yearIndex) => (
                            <td key={`growth-${row.project}-${YEARS[yearIndex]}`}>
                              <EditableCell
                                value={val}
                                min={MIN_VALUE}
                                max={MAX_VALUE}
                                onSave={next => handleSave('growth', rowIndex, yearIndex, next)}
                              />
                            </td>
                          ))}
                        </tr>
                      ))}
                    </tbody>
                  </DataTable>
                </SectionCard>
              </TabContent>
            )
          },
          {
            key: 'growth', label: 'Growth Configuration', children: (
              <TabContent>
                <SectionCard>
                  <SectionHead>
                    <SectionTitleWrap>
                      <div className="section-accent" />
                      <div className="section-title">Growth Projects — Pipeline Manager</div>
                    </SectionTitleWrap>
                  </SectionHead>
                  <DataTable>
                    <thead>
                      <tr>
                        <th>Project</th>
                        <th>FID Year</th>
                        <th>Capacity (MTPA)</th>
                        <th>Capex (est.)</th>
                        <th>Status</th>
                      </tr>
                    </thead>
                    <tbody>
                      {growthConfigRows.map((row) => (
                        <tr key={`growth-cfg-${row.project}`}>
                          <td>{row.project}</td>
                          <td>
                            <EditableCell
                              value={row.fid_year}
                              min={2020}
                              max={2040}
                              onSave={next => saveGrowthCell(row.project, 'fid_year', next)}
                            />
                          </td>
                          <td>
                            <EditableCell
                              value={row.capacity_mtpa}
                              min={0}
                              max={100}
                              step={0.1}
                              onSave={next => saveGrowthCell(row.project, 'capacity_mtpa', next)}
                            />
                          </td>
                          <td>
                            <EditableCell
                              value={row.capex_billion}
                              min={0}
                              max={50}
                              step={0.1}
                              onSave={next => saveGrowthCell(row.project, 'capex_billion', next)}
                            />
                          </td>
                          <td>
                            <select
                              value={row.status || 'On Track'}
                              onChange={e => saveGrowthCell(row.project, 'status', e.target.value)}
                              style={{ padding: '2px 4px', borderRadius: 4, border: '1px solid #ccc' }}
                            >
                              <option value="On Track">On Track</option>
                              <option value="Delayed">Delayed</option>
                              <option value="Cancelled">Cancelled</option>
                            </select>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </DataTable>
                </SectionCard>
              </TabContent>
            )
          },
          {
            key: 'opu', label: 'OPU Configuration', children: (
              <SectionCard>
                <EmptyState>
                  <svg width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="1">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 6A2.25 2.25 0 016 3.75h2.25A2.25 2.25 0 0110.5 6v2.25a2.25 2.25 0 01-2.25 2.25H6a2.25 2.25 0 01-2.25-2.25V6zM3.75 15.75A2.25 2.25 0 016 13.5h2.25a2.25 2.25 0 012.25 2.25V18a2.25 2.25 0 01-2.25 2.25H6A2.25 2.25 0 013.75 18v-2.25zM13.5 6a2.25 2.25 0 012.25-2.25H18A2.25 2.25 0 0120.25 6v2.25A2.25 2.25 0 0118 10.5h-2.25a2.25 2.25 0 01-2.25-2.25V6zM13.5 15.75a2.25 2.25 0 012.25-2.25H18a2.25 2.25 0 012.25 2.25V18A2.25 2.25 0 0118 20.25h-2.25A2.25 2.25 0 0113.5 18v-2.25z" />
                  </svg>
                  <div className="es-title">OPU Configuration</div>
                  <div className="es-desc">Configure operating performance unit inputs here.</div>
                </EmptyState>
              </SectionCard>
            )
          },
        ]}
      />
    </ScenarioContainer>
  );
}
