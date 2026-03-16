import { t, validateNonEmpty } from '@superset-ui/core';
import { ControlPanelConfig, sections, sharedControls } from '@superset-ui/chart-controls';

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
