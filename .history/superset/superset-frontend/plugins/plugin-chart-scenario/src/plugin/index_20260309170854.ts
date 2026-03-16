import { ChartMetadata, ChartPlugin, ChartProps } from '@superset-ui/core';
import { t } from '@apache-superset/core/translation';
import buildQuery from './buildQuery';
import controlPanel from './controlPanel';
import transformProps from './transformProps';
import { ScenarioChartFormData, ScenarioChartProps } from '../types';

const metadata = new ChartMetadata({
    description: 'Interactive Grid to adjust Scenario percentages.',
    name: t('Scenario Creator'),
    thumbnail: '',
    useLegacyApi: false,
});

// ScenarioChartProps needs to satisfy ChartPlugin's ChartProps constraint.
// We extend ChartProps so the plugin generic is satisfied without losing our props.
export type ScenarioPluginProps = ChartProps & ScenarioChartProps;

export default class ScenarioChartPlugin extends ChartPlugin<
    ScenarioChartFormData,
    ScenarioPluginProps
> {
    constructor() {
        super({
            buildQuery,
            controlPanel,
            loadChart: () => import('../ScenarioChart') as any,
            metadata,
            transformProps,
        });
    }
}
