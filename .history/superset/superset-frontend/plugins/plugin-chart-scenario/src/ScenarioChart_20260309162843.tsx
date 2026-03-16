import { useState } from 'react';
import { SupersetClient } from '@superset-ui/core';
import { ScenarioChartProps } from './types';
import { Table, notification, Tabs } from 'antd';

// Mock data to scaffold the UI (mirroring the pure HTML script)
const MOCK_EXISTING = [
    { pId: '1001', asset: 'MLNG', 2020: 70, 2021: 70, 2022: 70, 2023: 70, 2024: 70, 2025: 70, 2026: 70, 2027: 70 },
    { pId: '1002', asset: 'LNGC2', 2020: 30, 2021: 30, 2022: 30, 2023: 30, 2024: 30, 2025: 30, 2026: 30, 2027: 30 }
];

export default function ScenarioChart(props: ScenarioChartProps) {
    const { height, width } = props;
    const [gridData, setGridData] = useState(MOCK_EXISTING);
    const [activeTab, setActiveTab] = useState('existing');

    // AG Grid is complex to scaffold quickly. We use antd Table inside Superset as a starting point.
    const handleEdit = async (record: any, year: string, val: string) => {
        const num = parseFloat(val);
        if (isNaN(num) || num < 0 || num > 100) return;

        // Optimistic Update
        const prevData = [...gridData];
        const newData = gridData.map(r => r.pId === record.pId ? { ...r, [year]: num } : r);
        setGridData(newData);

        try {
            await SupersetClient.post({
                endpoint: '/api/v1/scenario/writeback',
                jsonPayload: {
                    scenario_name: 'existing_assets',
                    bu: 'LNGA', // Mock BU
                    opu: record.asset,
                    year: parseInt(year),
                    value: num
                }
            });
            notification.success({ message: `Updated ${record.asset} for ${year} to ${num}%` });
        } catch (err) {
            setGridData(prevData); // Rollback
            notification.error({ message: 'Failed to write back to database.' });
        }
    };

    const columns = [
        { title: 'Project ID', dataIndex: 'pId', key: 'pId', fixed: 'left' as const },
        { title: 'Asset', dataIndex: 'asset', key: 'asset', fixed: 'left' as const },
        ...['2020', '2021', '2022', '2023', '2024', '2025', '2026', '2027'].map(year => ({
            title: year,
            dataIndex: year,
            key: year,
            render: (val: any, record: any) => (
                <input
                    type="number"
                    defaultValue={val}
                    style={{ width: '60px', border: '1px solid #ccc', borderRadius: '4px' }}
                    onBlur={(e) => handleEdit(record, year, e.target.value)}
                />
            )
        }))
    ];

    return (
        <div style={{ width, height, overflow: 'auto', padding: 10 }}>
            <Tabs activeKey={activeTab} onChange={setActiveTab} items={[
                { key: 'existing', label: 'Existing Assets', children: <Table dataSource={gridData} columns={columns} pagination={false} rowKey="pId" scroll={{ x: 'max-content' }} size="small" /> },
                { key: 'growth', label: 'Growth Projects', children: <div>Coming soon</div> }
            ]} />
        </div>
    );
}
