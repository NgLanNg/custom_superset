import { ChartMetadata, ChartPlugin } from '@superset-ui/core';
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

export default class ScenarioChartPlugin extends ChartPlugin<
    ScenarioChartFormData,
    ScenarioChartProps
> {
    constructor() {
        super({
            buildQuery,
            controlPanel,
            loadChart: () => import('../ScenarioChart'),
            metadata,
            transformProps,
        });
    }
}
