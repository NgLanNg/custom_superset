import { QueryFormData } from '@superset-ui/core';

export interface ScenarioChartStylesProps {
    height: number;
    width: number;
}

export type ScenarioChartFormData = QueryFormData & {
    colorScheme?: string;
};

export type ScenarioChartProps = any;
