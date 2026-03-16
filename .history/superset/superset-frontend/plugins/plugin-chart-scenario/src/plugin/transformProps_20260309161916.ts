import { ChartProps } from '@superset-ui/core';
import { ScenarioChartProps } from '../types';

export default function transformProps(chartProps: ChartProps): ScenarioChartProps {
    const { width, height, formData, queriesData } = chartProps;
    const data = queriesData[0].data as ScenarioChartProps['data'];

    return {
        width,
        height,
        data,
        formData: formData as any,
    };
}
