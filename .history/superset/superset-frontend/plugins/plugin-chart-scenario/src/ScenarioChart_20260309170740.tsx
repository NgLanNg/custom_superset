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
import { SupersetClient } from '@superset-ui/core';
import { Table, notification, Tabs } from 'antd';
import { ScenarioChartProps, ScenarioRow } from './types';

const YEARS = ['2020', '2021', '2022', '2023', '2024', '2025', '2026', '2027'] as const;

const MOCK_EXISTING: ScenarioRow[] = [
    { pId: '1001', asset: 'MLNG', 2020: 70, 2021: 70, 2022: 70, 2023: 70, 2024: 70, 2025: 70, 2026: 70, 2027: 70 },
    { pId: '1002', asset: 'LNGC2', 2020: 30, 2021: 30, 2022: 30, 2023: 30, 2024: 30, 2025: 30, 2026: 30, 2027: 30 },
];

export default function ScenarioChart(props: ScenarioChartProps) {
    const { height, width, scenarioName = 'existing_assets', bu = 'LNGA' } = props;
    const [gridData, setGridData] = useState<ScenarioRow[]>(MOCK_EXISTING);
    const [activeTab, setActiveTab] = useState('existing');

    const handleEdit = async (record: ScenarioRow, year: string, val: string) => {
        const num = parseFloat(val);
        if (Number.isNaN(num) || num < 0 || num > 100) return;

        // Optimistic update — rollback on failure
        const prevData = [...gridData];
        setGridData(gridData.map(r => (r.pId === record.pId ? { ...r, [year]: num } : r)));

        try {
            await SupersetClient.post({
                endpoint: '/api/v1/scenario/writeback',
                jsonPayload: {
                    scenario_name: scenarioName,
                    bu,
                    opu: record.asset,
                    year: parseInt(year, 10),
                    value: num,
                },
            });
            notification.success({ message: `Updated ${record.asset} ${year} → ${num}%` });
        } catch {
            setGridData(prevData);
            notification.error({ message: 'Write-back failed. Change reverted.' });
        }
    };

    const columns = [
        { title: 'Project ID', dataIndex: 'pId', key: 'pId', fixed: 'left' as const },
        { title: 'Asset', dataIndex: 'asset', key: 'asset', fixed: 'left' as const },
        ...YEARS.map(year => ({
            title: year,
            dataIndex: year,
            key: year,
            render: (val: number, record: ScenarioRow) => (
                <input
                    key={`${record.pId}-${year}`}
                    type="number"
                    value={val}
                    min={0}
                    max={100}
                    style={{ width: '60px', border: '1px solid #ccc', borderRadius: '4px' }}
                    onChange={e => {
                        // controlled input — reflect typed value immediately
                        const n = parseFloat(e.target.value);
                        if (!Number.isNaN(n) && n >= 0 && n <= 100) {
                            setGridData(gridData.map(r => (r.pId === record.pId ? { ...r, [year]: n } : r)));
                        }
                    }}
                    onBlur={e => handleEdit(record, year, e.target.value)}
                />
            ),
        })),
    ];

    return (
        <div style={{ width, height, overflow: 'auto', padding: 10 }}>
            <Tabs
                activeKey={activeTab}
                onChange={setActiveTab}
                items={[
                    {
                        key: 'existing',
                        label: 'Existing Assets',
                        children: (
                            <Table
                                dataSource={gridData}
                                columns={columns}
                                pagination={false}
                                rowKey="pId"
                                scroll={{ x: 'max-content' }}
                                size="small"
                            />
                        ),
                    },
                    {
                        key: 'growth',
                        label: 'Growth Projects',
                        children: <div>Coming soon</div>,
                    },
                ]}
            />
        </div>
    );
}
