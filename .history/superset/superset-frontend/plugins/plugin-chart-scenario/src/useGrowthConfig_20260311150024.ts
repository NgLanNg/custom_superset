import { useCallback, useEffect, useRef, useState } from 'react';
import { SupersetClient, t } from '@superset-ui/core';
import { useWriteBack } from '@superset-ui/writeback';
import { GrowthProjectRow } from './types';
import { notification } from 'antd';

export function useGrowthConfig(scenarioName: string, bu: string) {
    const [rows, setRows] = useState<any[]>([]);
    const [isFetching, setIsFetching] = useState(true);

    const fetchRows = useCallback(async () => {
        try {
            setIsFetching(true);
            const res = await SupersetClient.get({
                endpoint: `/api/v1/scenario/growth-config?scenario_name=${encodeURIComponent(
                    scenarioName
                )}`,
            });
            if (res.json && res.json.status === 'success') {
                setRows(res.json.data || []);
            }
        } catch (err: any) {
            console.error('Failed to fetch growth config', err);
            // Wait, fail gracefully
            notification.error({
                message: t('Failed to load growth configuration'),
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
            project: string,
            field: string,
            nextValue: string | number
        ) => {
            // Find row
            const currentRow = rows.find(r => r.project === project);
            if (!currentRow) return;

            const previousValue = currentRow[field];

            // Optimistic Update
            setRows(prev =>
                prev.map(row =>
                    row.project === project ? { ...row, [field]: nextValue } : row
                )
            );

            try {
                const payload = {
                    scenario_name: scenarioName,
                    bu,
                    project,
                    [field]: nextValue,
                };

                const response = await SupersetClient.post({
                    endpoint: '/api/v1/scenario/growth-config',
                    jsonPayload: payload,
                    headers: { 'Content-Type': 'application/json' },
                });

                if (response.json && response.json.status === 'success') {
                    notification.success({
                        message: t('Saved'),
                        description: `${project} ${field} updated to ${nextValue}`,
                        placement: 'bottomRight',
                        duration: 2,
                    });
                }
            } catch (err: any) {
                console.error('Growth config write-back failed:', err);
                const errMsg = err?.json?.message || err.message || 'Unknown error';

                // Revert Optimistic Update
                setRows(prev =>
                    prev.map(row =>
                        row.project === project ? { ...row, [field]: previousValue } : row
                    )
                );

                notification.error({
                    message: t('Failed to save changes'),
                    description: errMsg,
                    placement: 'bottomRight',
                    duration: 3,
                });
            }
        },
        [rows, scenarioName, bu]
    );

    return {
        rows,
        isFetching,
        saveCell,
    };
}
