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
import '@testing-library/jest-dom';
import { render, screen, fireEvent, waitFor, within } from '@testing-library/react';
import { SupersetClient } from '@superset-ui/core';
import { supersetTheme, ThemeProvider } from '@apache-superset/core/theme';
import ScenarioChart from '../src/ScenarioChart';
// Mock Echart to avoid Redux/theme issues in plugin isolation
jest.mock('../../plugin-chart-echarts/src/components/Echart', () => {
  return function MockEchart() {
    return <div data-testid="mock-echart" />;
  };
});

// Mock the hooks
jest.mock('../src/useScenarioData', () => ({
  useScenarioData: jest.fn(() => ({
    existingData: [
      { bu: 'LNGA', gpu: 'MLNG', vals: [70, 75, 80, 85, 90] },
      { bu: 'LNGA', gpu: 'ALNG', vals: [60, 65, 70, 75, 80] },
    ],
    growthData: [],
    stats: {
      totalAssets: 10,
      avgEquity: 50,
      maxEquity: 70,
      minEquity: 60
    },
    chartOptions: {},
    handleSave: jest.fn(),
    saveBatch: jest.fn(),
    isSaving: false,
  })),
}));

jest.mock('../src/useGrowthConfig', () => ({
  useGrowthConfig: jest.fn(() => ({
    rows: [
      { project: 'LNGC2', fid_year: 2025, capacity_mtpa: 5.0, capex_billion: 12.5, status: 'On Track' },
    ],
    handleSave: jest.fn(),
    isSaving: false,
    stats: { totalCapacity: 5.0 },
  })),
}));

jest.mock('../src/useOPUConfig', () => ({
  useOPUConfig: jest.fn(() => ({
    rows: [
      { opu: 'MLNG', bu: 'LNGA', type: 'existing', base_equity_pct: 70, active: true },
    ],
    handleSave: jest.fn(),
    isSaving: false,
  })),
}));

// Polyfill window.matchMedia for Ant Design compatibility
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(), // Deprecated
    removeListener: jest.fn(), // Deprecated
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

// Mock ECharts to avoid canvas/DOM dependencies in Jest
const mockSetOption = jest.fn();
const mockResize = jest.fn();
const mockDispose = jest.fn();

jest.mock('echarts/core', () => ({
  use: jest.fn(),
  init: jest.fn(() => ({
    setOption: mockSetOption,
    resize: mockResize,
    dispose: mockDispose,
  })),
}));

jest.mock('echarts/charts', () => ({ LineChart: {} }));
jest.mock('echarts/components', () => ({
  GridComponent: {},
  LegendComponent: {},
  TitleComponent: {},
  TooltipComponent: {},
}));
jest.mock('echarts/renderers', () => ({ CanvasRenderer: {} }));

// Mock styled-components file to avoid styled undefined in Jest
jest.mock('../src/ScenarioChart.styles', () => {
  const React = require('react');
  const passthrough = (Tag: keyof JSX.IntrinsicElements = 'div') =>
    React.forwardRef(({ children, ...rest }: any, ref: React.Ref<any>) =>
      React.createElement(Tag, { ref, ...rest }, children),
    );
  return {
    ScenarioContainer: passthrough('div'),
    InfoBannerWrap: passthrough('div'),
    ChartPanel: passthrough('div'),
    ChartHeader: passthrough('div'),
    ChartBadge: passthrough('span'),
    StatsRowWrap: passthrough('div'),
    StatCard: passthrough('div'),
    SectionCard: passthrough('div'),
    SectionHead: passthrough('div'),
    SectionTitleWrap: passthrough('div'),
    FilterBtn: passthrough('button'),
    DataTable: passthrough('table'),
    EmptyState: passthrough('div'),
    TabContent: passthrough('div'),
    CellInput: passthrough('input'),
  };
});

// Spy on SupersetClient.post while keeping real module exports (styled/theme)
jest.spyOn(SupersetClient, 'post').mockResolvedValue({ json: { status: 'success' } } as any);

describe('ScenarioChart', () => {
  const defaultProps = {
    height: 400,
    width: 600,
    existingData: [],
    growthData: [],
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders tabs correctly', () => {
    render(
      <ThemeProvider theme={supersetTheme}>
        <ScenarioChart {...defaultProps} />
      </ThemeProvider>
    );

    expect(screen.getByText('Equity Share Configuration')).toBeInTheDocument();
    expect(screen.getByText('Growth Configuration')).toBeInTheDocument();
    expect(screen.getByText('OPU Configuration')).toBeInTheDocument();
  });

  test('renders tables with existing rows', () => {
    render(
      <ThemeProvider theme={supersetTheme}>
        <ScenarioChart {...defaultProps} />
      </ThemeProvider>
    );

    // From mock useScenarioData
    expect(screen.getByText('MLNG')).toBeInTheDocument();
  });

  test('renders growth project after switching tab', async () => {
    render(
      <ThemeProvider theme={supersetTheme}>
        <ScenarioChart {...defaultProps} />
      </ThemeProvider>
    );

    const growthTab = screen.getByText('Growth Configuration');
    fireEvent.click(growthTab);

    // From mock useGrowthConfig
    expect(await screen.findByText('LNGC2')).toBeInTheDocument();
  });

  test('handles cell edit optimistic update', async () => {
    const { useScenarioData } = require('../src/useScenarioData');
    const mockHandleSave = jest.fn();
    useScenarioData.mockReturnValue({
      existingData: [{ bu: 'LNGA', gpu: 'MLNG', vals: [70, 75, 80, 85, 90] }],
      growthData: [],
      stats: {
        totalAssets: 10,
        avgEquity: 50,
        maxEquity: 70,
        minEquity: 60
      },
      chartOptions: {},
      handleSave: mockHandleSave,
      isSaving: false,
    });

    render(
      <ThemeProvider theme={supersetTheme}>
        <ScenarioChart {...defaultProps} />
      </ThemeProvider>
    );

    const input = screen.getByDisplayValue('70');
    fireEvent.change(input, { target: { value: '55' } });
    fireEvent.blur(input);

    await waitFor(() => {
      expect(mockHandleSave).toHaveBeenCalledWith('existing', 0, 0, 55);
    });
  });

  test('shows stat cards with total assets', () => {
    render(
      <ThemeProvider theme={supersetTheme}>
        <ScenarioChart {...defaultProps} />
      </ThemeProvider>
    );

    const totalLabel = screen.getByText('Total Assets');
    const card = totalLabel.parentElement as HTMLElement;
    expect(card).toBeInTheDocument();
    // From mock
    expect(within(card).getByText('10')).toBeInTheDocument();
  });
});
