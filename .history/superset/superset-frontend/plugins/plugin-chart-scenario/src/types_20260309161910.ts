import { QueryFormData, supersetTheme, TimeseriesDataRecord } from '@superset-ui/core';

export interface ScenarioChartStylesProps {
    height: number;
    width: number;
}

export type ScenarioChartFormData = QueryFormData & {
    colorScheme?: string;
};

export type ScenarioChartProps = ScenarioChartStylesProps & {
    data: TimeseriesDataRecord[];
    formData: ScenarioChartFormData;
};
