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
import { Button, Input, Tabs, message } from 'antd';
import styled from '@emotion/styled';
import { SupersetClient } from '@superset-ui/core';
import { ComparativeChart } from './ComparativeChart';
import { FilterPanel } from './FilterPanel';
import { EditableDataTable } from './EditableDataTable';
import type { ScenarioMetadata, FilterState } from './types';

const { TabPane } = Tabs;
const { TextArea } = Input;

// --- Layout ---

const PageWrapper = styled.div`
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: #f5f5f5;
`;

const PageHeader = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 24px;
  background: #fff;
  border-bottom: 1px solid #f0f0f0;
  position: sticky;
  top: 0;
  z-index: 10;
`;

const HeaderLeft = styled.div`
  display: flex;
  align-items: center;
  gap: 16px;
`;

const BackButton = styled(Button)`
  padding: 0;
  font-size: 13px;
`;

const PageTitle = styled.h1`
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #262626;
`;

const PageSubtitle = styled.span`
  font-size: 12px;
  color: #8c8c8c;
`;

const HeaderActions = styled.div`
  display: flex;
  gap: 8px;
`;

const PageContent = styled.div`
  flex: 1;
  padding: 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
`;

const MetadataSection = styled.div`
  background: #fff;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
  padding: 16px;
  display: flex;
  gap: 16px;

  & > div {
    flex: 1;
  }
`;

const FieldLabel = styled.label`
  display: block;
  font-size: 12px;
  font-weight: 600;
  color: #595959;
  margin-bottom: 4px;
`;

const TabsWrapper = styled.div`
  background: #fff;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
  padding: 0 16px;
`;

const SubTabContent = styled.div`
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding-top: 4px;
`;

const PlaceholderContent = styled.div`
  padding: 40px;
  text-align: center;
  color: #8c8c8c;
  font-size: 13px;
`;

// --- Component ---

const DEFAULT_FILTERS: FilterState = {
  bu: null,
  opu: null,
  scope: null,
  source: null,
};

const DEFAULT_METADATA: ScenarioMetadata = {
  name: '',
  description: '',
  status: 'draft',
};

export function ScenarioCreationPage() {
  const [metadata, setMetadata] = useState<ScenarioMetadata>(DEFAULT_METADATA);
  const [scenarioId, setScenarioId] = useState<string>('base');
  const [activeTopTab, setActiveTopTab] = useState<string>('opu');
  const [activeSubTab, setActiveSubTab] = useState<string>('emission-sources');
  const [filters, setFilters] = useState<FilterState>(DEFAULT_FILTERS);
  const [saving, setSaving] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const handleBack = useCallback(() => {
    window.history.back();
  }, []);

  const handleSaveDraft = useCallback(async () => {
    if (!metadata.name.trim()) {
      message.warning('Scenario name is required');
      return;
    }
    setSaving(true);
    try {
      if (metadata.id) {
        await SupersetClient.put({
          endpoint: `/api/v1/scenario/metadata/${metadata.id}`,
          jsonPayload: { name: metadata.name, description: metadata.description },
        });
        message.success('Draft saved');
      } else {
        const response = await SupersetClient.post({
          endpoint: '/api/v1/scenario/metadata/',
          jsonPayload: { name: metadata.name, description: metadata.description },
        });
        const result = response.json as { data: { id: string } };
        setMetadata(prev => ({ ...prev, id: result.data.id }));
        setScenarioId(result.data.id);
        message.success('Draft saved');
      }
    } catch {
      message.error('Failed to save draft');
    } finally {
      setSaving(false);
    }
  }, [metadata]);

  const handleSubmit = useCallback(async () => {
    if (!metadata.id) {
      message.warning('Save as draft first before submitting');
      return;
    }
    setSubmitting(true);
    try {
      await SupersetClient.post({
        endpoint: `/api/v1/scenario/metadata/${metadata.id}/submit`,
        jsonPayload: {},
      });
      setMetadata(prev => ({ ...prev, status: 'pending_approval' }));
      message.success('Submitted for approval');
    } catch {
      message.error('Failed to submit scenario');
    } finally {
      setSubmitting(false);
    }
  }, [metadata]);

  const isLocked = metadata.status !== 'draft';

  const emissionSubTab = (
    <SubTabContent>
      <ComparativeChart filters={filters} scenarioId={scenarioId} />
      <FilterPanel
        filters={filters}
        scenarioId={scenarioId}
        onFilterChange={setFilters}
      />
      <EditableDataTable filters={filters} scenarioId={scenarioId} />
    </SubTabContent>
  );

  const placeholderTab = (label: string) => (
    <PlaceholderContent>
      {label} configuration will be available in a future release.
    </PlaceholderContent>
  );

  return (
    <PageWrapper>
      <PageHeader>
        <HeaderLeft>
          <BackButton type="link" onClick={handleBack}>
            &#8592; Back
          </BackButton>
          <div>
            <PageTitle>Scenario Creation</PageTitle>
            <PageSubtitle>Configure specific equity shares and growth parameters for the simulation.</PageSubtitle>
          </div>
        </HeaderLeft>
        <HeaderActions>
          <Button
            onClick={handleSaveDraft}
            loading={saving}
            disabled={isLocked}
            data-test="save-draft-btn"
          >
            Save Draft
          </Button>
          <Button
            type="primary"
            onClick={handleSubmit}
            loading={submitting}
            disabled={isLocked || !metadata.id}
            data-test="submit-btn"
          >
            Submit for Approval
          </Button>
        </HeaderActions>
      </PageHeader>

      <PageContent>
        <MetadataSection>
          <div>
            <FieldLabel htmlFor="scenario-name">NAME</FieldLabel>
            <Input
              id="scenario-name"
              value={metadata.name}
              onChange={e => setMetadata(prev => ({ ...prev, name: e.target.value }))}
              placeholder="Input text"
              disabled={isLocked}
              data-test="scenario-name-input"
              maxLength={256}
            />
          </div>
          <div>
            <FieldLabel htmlFor="scenario-description">DESCRIPTION</FieldLabel>
            <TextArea
              id="scenario-description"
              value={metadata.description}
              onChange={e =>
                setMetadata(prev => ({ ...prev, description: e.target.value }))
              }
              placeholder="Input text"
              disabled={isLocked}
              data-test="scenario-description-input"
              rows={1}
              maxLength={2000}
            />
          </div>
        </MetadataSection>

        <TabsWrapper>
          <Tabs
            activeKey={activeTopTab}
            onChange={setActiveTopTab}
            data-test="top-tabs"
          >
            <TabPane tab="Equity Share Configuration" key="equity">
              {placeholderTab('Equity Share')}
            </TabPane>
            <TabPane tab="Growth Configuration" key="growth">
              {placeholderTab('Growth')}
            </TabPane>
            <TabPane
              tab="OPU Configuration"
              key="opu"
              data-test="tab-opu-configuration"
            >
              <Tabs
                activeKey={activeSubTab}
                onChange={setActiveSubTab}
                size="small"
                data-test="sub-tabs"
              >
                <TabPane
                  tab="Emission by Sources"
                  key="emission-sources"
                  data-test="subtab-emission-sources"
                >
                  {emissionSubTab}
                </TabPane>
                <TabPane tab="Production" key="production">
                  {placeholderTab('Production')}
                </TabPane>
                <TabPane tab="Emission by Gases" key="emission-gases">
                  {placeholderTab('Emission by Gases')}
                </TabPane>
                <TabPane tab="Energy Consumption" key="energy">
                  {placeholderTab('Energy Consumption')}
                </TabPane>
                <TabPane tab="Intensity" key="intensity">
                  {placeholderTab('Intensity')}
                </TabPane>
                <TabPane tab="Reduction" key="reduction">
                  {placeholderTab('Reduction')}
                </TabPane>
              </Tabs>
            </TabPane>
          </Tabs>
        </TabsWrapper>
      </PageContent>
    </PageWrapper>
  );
}
