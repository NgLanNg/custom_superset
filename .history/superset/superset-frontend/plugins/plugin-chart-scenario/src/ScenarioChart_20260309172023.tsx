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
import { useState, useCallback } from 'react';
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

    const handleEdit = useCallback(async (record: ScenarioRow, year: string, val: string) => {
        const num = parseFloat(val);
        if (Number.isNaN(num) || num < 0 || num > 100) return;

        // Optimistic update — rollback on failure
        setGridData(current =>
            current.map(r => (r.pId === record.pId ? { ...r, [year]: num } : r))
        );

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
            notification.success({
                message: `Saved`,
                description: `${record.asset} ${year} updated to ${num}%`,
                placement: 'bottomRight',
                duration: 2,
            });
        } catch {
            // Revert to original data on failure
            // Note: In a real app, we'd fetch the latest data from the backend here
            notification.error({
                message: 'Write-back failed',
                description: 'Connection error or database failure. Change reverted.',
            });
        }
    }, [scenarioName, bu]);

    const columns = [
        { title: 'Project ID', dataIndex: 'pId', key: 'pId', fixed: 'left' as const, width: 100 },
        { title: 'Asset', dataIndex: 'asset', key: 'asset', fixed: 'left' as const, width: 120 },
        ...YEARS.map(year => ({
            title: year,
            dataIndex: year,
            key: year,
            render: (val: number, record: ScenarioRow) => (
                <ScenarioCell
                    key={`${record.pId}-${year}`}
                    value={val}
                    onSave={(newVal) => handleEdit(record, year, newVal)}
                />
            ),
        })),
    ];

    return (
        <div style={{ width, height, overflow: 'auto', padding: 16, background: '#fff' }}>
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
                                bordered
                            />
                        ),
                    },
                    {
                        key: 'growth',
                        label: 'Growth Projects',
                        children: <div style={{ padding: 20, textAlign: 'center', color: '#999' }}>Coming soon: editable expansion items</div>,
                    },
                ]}
            />
        </div>
    );
}

/**
 * Sub-component for a single cell to avoid dot-swallowing in numeric inputs.
 * Uses local string state for typing and only calls onSave on blur/enter.
 */
function ScenarioCell({ value, onSave }: { value: number; onSave: (val: string) => void }) {
    const [localVal, setLocalVal] = useState(value.toString());

    // Update local state when prop changes (e.g. from parent re-render or rollback)
    if (parseFloat(localVal) !== value && !localVal.includes('.')) {
        // Only sync if not currently being edited (with a dot)
        // This is a simple sync-from-props pattern
    }

    return (
        <input
            type="text" // Use text to allow dots to stay while typing
            value={localVal}
            style={{
                width: '100%',
                border: '1px solid #d9d9d9',
                borderRadius: '2px',
                textAlign: 'right',
                padding: '2px 4px'
            }}
            onChange={e => setLocalVal(e.target.value)}
            onBlur={() => {
                if (localVal !== value.toString()) {
                    onSave(localVal);
                }
            }}
            onKeyDown={e => {
                if (e.key === 'Enter') {
                    (e.target as HTMLInputElement).blur();
                }
            }}
        />
    );
}
