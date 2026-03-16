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
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
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

// Mock SupersetClient
jest.mock('@superset-ui/core', () => ({
    SupersetClient: {
        post: jest.fn().mockResolvedValue({ json: { status: 'success' } }),
    },
    t: (text: string) => text,
}));

describe('ScenarioChart', () => {
    const defaultProps = {
        height: 400,
        width: 600,
    };

    beforeEach(() => {
        jest.clearAllMocks();
    });

    test('renders tabs correctly', () => {
        render(<ScenarioChart {...defaultProps} />);

        // Check if the two tabs are rendered
        expect(screen.getByText('Existing Equity Share')).toBeInTheDocument();
        expect(screen.getByText('Growth Scenarios')).toBeInTheDocument();
    });

    test('renders the table with data', () => {
        render(<ScenarioChart {...defaultProps} />);

        // Check existing data rows
        expect(screen.getByText('Base')).toBeInTheDocument();
        expect(screen.getByText('Upside')).toBeInTheDocument();
    });

    test('handles cell edit optimistic update and API call', async () => {
        render(<ScenarioChart {...defaultProps} />);

        // Find the inputs created for edits (they start with the default test data values)
        const inputs = screen.getAllByDisplayValue('45');

        expect(inputs.length).toBeGreaterThan(0);
        const valueCell = inputs[0];

        expect(valueCell).toBeInTheDocument();

        // Trigger cell edit
        fireEvent.change(valueCell, { target: { value: '55' } });
        fireEvent.blur(valueCell);

        // After blur, it should have triggered SupersetClient.post and optimistic update
        await waitFor(() => {
            expect(SupersetClient.post).toHaveBeenCalled();
        });

        expect(screen.getAllByDisplayValue('55').length).toBeGreaterThan(0);
    });
});
