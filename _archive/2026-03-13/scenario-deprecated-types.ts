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

export interface ScenarioMetadata {
  id?: string;
  name: string;
  description: string;
  status: 'draft' | 'pending_approval' | 'approved' | 'rejected';
  createdBy?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface FilterState {
  bu: string | null;
  opu: string | null;
  scope: string | null;
  source: string | null;
}

export interface EmissionRow {
  bu: string;
  opu: string;
  scope: string;
  source: string;
  year: number;
  value: number;
}

export interface PivotRow {
  key: string;
  bu: string;
  opu: string;
  scope: string;
  source: string;
  [year: string]: string | number;
}

export interface ChartDataPoint {
  year: number;
  value: number;
}
