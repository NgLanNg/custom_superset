import { t } from '@apache-superset/core/translation';
import { ControlPanelConfig, sections } from '@superset-ui/chart-controls';

const config: ControlPanelConfig = {
    controlPanelSections: [
        sections.legacyTimeseriesTime,
        {
            label: t('Query'),
            expanded: true,
            controlSetRows: [
                ['metrics'],
                ['groupby'],
                ['columns'],
            ],
        },
    ],
};

export default config;
