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

import { useCallback, useEffect, useState } from 'react';
import { Select } from 'antd';
import styled from '@emotion/styled';
import { SupersetClient } from '@superset-ui/core';
import type { FilterState, EmissionRow } from './types';

const PanelWrapper = styled.div`
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: #fafafa;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
  flex-wrap: wrap;
`;

const FilterLabel = styled.span`
  font-size: 12px;
  font-weight: 600;
  color: #595959;
  min-width: 40px;
`;

const StyledSelect = styled(Select)`
  min-width: 140px;
`;

interface FilterPanelProps {
  filters: FilterState;
  scenarioId: string;
  onFilterChange: (next: FilterState) => void;
}

export function FilterPanel({ filters, scenarioId, onFilterChange }: FilterPanelProps) {
  const [options, setOptions] = useState<{
    bu: string[];
    opu: string[];
    scope: string[];
    source: string[];
  }>({ bu: [], opu: [], scope: [], source: [] });

  const fetchOptions = useCallback(async () => {
    try {
      const response = await SupersetClient.get({
        endpoint: `/api/v1/scenario/emission-sources?scenario_id=${encodeURIComponent(scenarioId)}`,
      });
      const rows: EmissionRow[] = (response.json as { data: EmissionRow[] }).data || [];

      setOptions({
        bu: [...new Set(rows.map(r => r.bu))].sort(),
        opu: [...new Set(rows.map(r => r.opu))].sort(),
        scope: [...new Set(rows.map(r => r.scope))].sort(),
        source: [...new Set(rows.map(r => r.source))].sort(),
      });
    } catch {
      // keep empty options on error
    }
  }, [scenarioId]);

  useEffect(() => {
    fetchOptions();
  }, [fetchOptions]);

  const handle =
    (key: keyof FilterState) => (value: string | null) => {
      onFilterChange({ ...filters, [key]: value || null });
    };

  return (
    <PanelWrapper>
      <FilterLabel>Filter:</FilterLabel>

      <StyledSelect
        allowClear
        placeholder="BU"
        value={filters.bu ?? undefined}
        onChange={handle('bu') as (v: unknown) => void}
        data-test="filter-bu"
        size="small"
        options={options.bu.map(v => ({ label: v, value: v }))}
      />

      <StyledSelect
        allowClear
        placeholder="OPU"
        value={filters.opu ?? undefined}
        onChange={handle('opu') as (v: unknown) => void}
        data-test="filter-opu"
        size="small"
        options={options.opu.map(v => ({ label: v, value: v }))}
      />

      <StyledSelect
        allowClear
        placeholder="Scope"
        value={filters.scope ?? undefined}
        onChange={handle('scope') as (v: unknown) => void}
        data-test="filter-scope"
        size="small"
        options={options.scope.map(v => ({ label: v, value: v }))}
      />

      <StyledSelect
        allowClear
        placeholder="Sources"
        value={filters.source ?? undefined}
        onChange={handle('source') as (v: unknown) => void}
        data-test="filter-source"
        size="small"
        options={options.source.map(v => ({ label: v, value: v }))}
      />
    </PanelWrapper>
  );
}
