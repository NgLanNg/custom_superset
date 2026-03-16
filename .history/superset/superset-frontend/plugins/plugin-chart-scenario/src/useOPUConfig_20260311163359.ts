import { useCallback, useEffect, useState } from 'react';
import { SupersetClient } from '@superset-ui/core';
import { notification } from 'antd';

export function useOPUConfig(scenarioName: string) {
    const [rows, setRows] = useState<any[]>([]);
    const [isFetching, setIsFetching] = useState(true);

    const fetchRows = useCallback(async () => {
        try {
            setIsFetching(true);
            const res = await SupersetClient.get({
                endpoint: `/api/v1/scenario/opu-config?scenario_name=${encodeURIComponent(
                    scenarioName
                )}`,
            });
            if (res.json && res.json.status === 'success') {
                setRows(res.json.data || []);
            }
        } catch (err: any) {
            console.error('Failed to fetch OPU config', err);
            notification.error({
                message: 'Failed to load OPU configuration',
                description: err?.json?.message || err.message,
            });
        } finally {
            setIsFetching(false);
        }
    }, [scenarioName]);

    useEffect(() => {
        fetchRows();
    }, [fetchRows]);

    const saveCell = useCallback(
        async (
            opu: string,
            field: string,
            nextValue: string | number | boolean
        ) => {
            // Find row
            const currentRow = rows.find(r => r.opu === opu);
            if (!currentRow) return;

            const previousValue = currentRow[field];

            // Optimistic Update
            setRows(prev =>
                prev.map(row =>
                    row.opu === opu ? { ...row, [field]: nextValue } : row
                )
            );

            try {
                const payload = {
                    scenario_name: scenarioName,
                    opu,
                    // Sending only what is needed, or the whole object minus unwanted parts
                    ...currentRow,
                    [field]: nextValue,
                };

                const response = await SupersetClient.post({
                    endpoint: '/api/v1/scenario/opu-config',
                    jsonPayload: payload,
                    headers: { 'Content-Type': 'application/json' },
                });

                if (response.json && response.json.status === 'success') {
                    notification.success({
                        message: 'Saved',
                        description: `${opu} ${field} updated to ${nextValue}`,
                        placement: 'bottomRight',
                        duration: 2,
                    });
                }
            } catch (err: any) {
                console.error('OPU config write-back failed:', err);
                const errMsg = err?.json?.message || err.message || 'Unknown error';

                // Revert Optimistic Update
                setRows(prev =>
                    prev.map(row =>
                        row.opu === opu ? { ...row, [field]: previousValue } : row
                    )
                );

                notification.error({
                    message: 'Failed to save changes',
                    description: errMsg,
                    placement: 'bottomRight',
                    duration: 3,
                });
            }
        },
        [rows, scenarioName]
    );

    return {
        rows,
        isFetching,
        saveCell,
    };
}
