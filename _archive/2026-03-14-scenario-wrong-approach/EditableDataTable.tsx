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

import { useCallback, useEffect, useMemo, useState } from 'react';
import { Table } from 'antd';
import styled from '@emotion/styled';
import { SupersetClient } from '@superset-ui/core';
import { EditableCell } from '@superset-ui/writeback';
import { useWriteBack } from '@superset-ui/writeback';
import type { FilterState, EmissionRow, PivotRow } from './types';

const TableWrapper = styled.div`
  background: #fff;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
  padding: 16px;
  overflow-x: auto;
`;

const TableTitle = styled.h3`
  margin: 0 0 12px;
  font-size: 14px;
  font-weight: 600;
  color: #262626;
`;

interface EditableDataTableProps {
  filters: FilterState;
  scenarioId: string;
}

function buildTableTitle(filters: FilterState): string {
  const base = 'Operational Control \u2013 Emission by Sources';
  if (filters.opu) return `${base} \u2013 ${filters.opu}`;
  if (filters.bu) return `${base} \u2013 ${filters.bu}`;
  return base;
}

function pivotData(rows: EmissionRow[]): { pivotRows: PivotRow[]; years: number[] } {
  const yearSet = new Set<number>();
  const rowMap: Record<string, PivotRow> = {};

  rows.forEach(r => {
    yearSet.add(r.year);
    const key = `${r.bu}|${r.opu}|${r.scope}|${r.source}`;
    if (!rowMap[key]) {
      rowMap[key] = { key, bu: r.bu, opu: r.opu, scope: r.scope, source: r.source };
    }
    rowMap[key][String(r.year)] = r.value;
  });

  const years = [...yearSet].sort((a, b) => a - b);
  const pivotRows = Object.values(rowMap);
  return { pivotRows, years };
}

export function EditableDataTable({ filters, scenarioId }: EditableDataTableProps) {
  const [rows, setRows] = useState<EmissionRow[]>([]);
  const [loading, setLoading] = useState(false);
  const { save, isSaving } = useWriteBack({ successMessage: 'Saved' });

  const title = useMemo(() => buildTableTitle(filters), [filters]);

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
      setRows((response.json as { data: EmissionRow[] }).data || []);
    } catch {
      setRows([]);
    } finally {
      setLoading(false);
    }
  }, [filters, scenarioId]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const handleCellSave = useCallback(
    async (pivotRow: PivotRow, year: number, value: number) => {
      await save({
        endpoint: '/api/v1/scenario/emission-sources',
        jsonPayload: {
          bu: pivotRow.bu,
          opu: pivotRow.opu,
          scope: pivotRow.scope,
          source: pivotRow.source,
          year,
          value,
          scenario_id: scenarioId,
        },
      });
      // Optimistic update
      setRows(prev =>
        prev.map(r =>
          r.bu === pivotRow.bu &&
          r.opu === pivotRow.opu &&
          r.scope === pivotRow.scope &&
          r.source === pivotRow.source &&
          r.year === year
            ? { ...r, value }
            : r,
        ),
      );
    },
    [save, scenarioId],
  );

  const { pivotRows, years } = useMemo(() => pivotData(rows), [rows]);

  const fixedColumns = [
    { title: 'BU', dataIndex: 'bu', key: 'bu', width: 80, fixed: 'left' as const },
    { title: 'OPU', dataIndex: 'opu', key: 'opu', width: 120, fixed: 'left' as const },
    { title: 'Scope', dataIndex: 'scope', key: 'scope', width: 90 },
    { title: 'Source', dataIndex: 'source', key: 'source', width: 110 },
  ];

  const yearColumns = years.map(yr => ({
    title: String(yr),
    dataIndex: String(yr),
    key: String(yr),
    width: 80,
    align: 'right' as const,
    render: (cellValue: number | undefined, record: PivotRow) => (
      <EditableCell
        value={cellValue ?? 0}
        onSave={next => handleCellSave(record, yr, next)}
        disabled={isSaving}
      />
    ),
  }));

  return (
    <TableWrapper>
      <TableTitle>{title}</TableTitle>
      <Table
        dataSource={pivotRows}
        columns={[...fixedColumns, ...yearColumns]}
        loading={loading}
        pagination={false}
        scroll={{ x: 'max-content', y: 360 }}
        size="small"
        rowKey="key"
      />
    </TableWrapper>
  );
}
