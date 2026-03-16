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
import ScenarioChart from '../src/ScenarioChart';

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
    render(<ScenarioChart {...defaultProps} />);

    expect(screen.getByText('Equity Share Configuration')).toBeInTheDocument();
    expect(screen.getByText('Growth Configuration')).toBeInTheDocument();
    expect(screen.getByText('OPU Configuration')).toBeInTheDocument();
  });

  test('renders mock tables with existing and growth rows', () => {
    render(<ScenarioChart {...defaultProps} />);

    // Existing assets table sample rows
    expect(screen.getByText('MLNG')).toBeInTheDocument();
    // Growth projects table sample rows
    expect(screen.getByText('LNGC2')).toBeInTheDocument();
  });

  test('handles cell edit optimistic update and API call', async () => {
    render(<ScenarioChart {...defaultProps} />);

    // MLNG in MOCK_EXISTING has 70
    const input = screen.getAllByDisplayValue('70')[0];
    fireEvent.change(input, { target: { value: '55' } });
    fireEvent.blur(input);

    await waitFor(() => {
      expect(SupersetClient.post).toHaveBeenCalledTimes(1);
    });

    expect(screen.getByDisplayValue('55')).toBeInTheDocument();
    expect(SupersetClient.post).toHaveBeenCalledWith(
      expect.objectContaining({
        endpoint: '/api/v1/scenario/writeback',
        jsonPayload: expect.objectContaining({
          scenario_name: 'existing_assets',
          bu: 'LNGA',
          opu: 'MLNG',
          year: 2020,
          value: 55,
        }),
      }),
    );
  });

  test('shows stat cards with total assets', () => {
    render(<ScenarioChart {...defaultProps} />);

    const totalLabel = screen.getByText('Total Assets');
    const card = totalLabel.parentElement as HTMLElement;
    expect(card).toBeInTheDocument();
    expect(within(card).getByText(/\d+/)).toBeInTheDocument();
  });
});
