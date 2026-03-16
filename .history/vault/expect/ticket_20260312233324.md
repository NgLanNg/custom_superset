

A. Description





The Scenario Creation Page allows users to create and configure a scenario through a structured page that combines scenario metadata, configuration tabs, comparative preview, and editable data tables.



The page includes:



Scenario metadata entry

Save Draft and Submit for Approval actions

Configuration tabs for Equity Share, Growth, and OPU data

A comparative chart preview

A detailed editable table for the selected configuration dataset

For the scope of this story, the detailed table shown is Operational Control – Emission by Sources.



B. Functional Requirements

B.1 Data Logic

The page shall allow the user to enter:

Scenario Name

Scenario Description



The page shall support the following top-level configuration tabs:

Equity Share Configuration

Growth Configuration

OPU Configuration



Under OPU Configuration, the page shall support the following data sub-tabs:

Emission by Sources

Production

Emission by Gases

Energy Consumption

Intensity

Reduction

For this story, the active editable dataset is:

Operational Control – Emission by Sources

The data table shall display records from the Emission by Sources dataset under Operational Control.

The chart shown above the table shall be a comparative total GHG emissions preview for the current scenario context.

The chart and the table must respond to the same selected filters.

When the user changes filters, the table data must refresh accordingly.

The chart title must update dynamically based on the selected filter context.

Example:

Default title: Comparative Total GHG Emissions

If BU = LNGA is selected, title becomes:

Comparative Total GHG Emissions – LNGA

The table title must also reflect the selected context while preserving the dataset name.

Example:

Operational Control – Emission by Sources

If filtered by BU = LNGA, it may show:

Operational Control – Emission by Sources – LNGA

Save Draft:

Stores the current scenario as draft

Scenario remains editable

Submit for Approval:

Submits the current scenario into approval workflow

Scenario status changes to Pending Approval



B.2 Filter Logic

The page shall support the following filters for the Operational Control – Emission by Sources table and the comparative chart:

BU

OPU

Scope

Sources

Filter behavior:

All filters apply to both:

The comparative chart

The table below

Filters are combinable

Only records matching the selected filter values are displayed

If no filter is selected, the page displays the full default dataset for the selected tab

Title text must update based on the active filter selection, using the highest-priority visible business context



B.3 Groupings

For Operational Control – Emission by Sources, data is grouped by:

BU

OPU

Scope

Source

Year

Table structure follows Excel-style year-based display:

Each year is shown as a separate column

Each row represents one data record grouping based on the selected dataset structure

The comparative chart groups data by:

Scenario

Year

C. Visualisation Requirements

C.1 Layout

The page layout shall contain the following sections in order:

Page Header

Back navigation

Page title: Scenario Creation

Scenario subtitle / helper text

Top Action Area

Save Draft button

Submit for Approval button

Scenario Metadata Area

Name input field

Description input field

Top-Level Tabs

Equity Share Configuration

Growth Configuration

OPU Configuration

Sub-Tab Navigation

Emission by Sources

Production

Emission by Gases

Energy Consumption

Intensity

Reduction

Comparative Chart Section

Title updates dynamically based on filter context

Displays comparative total GHG emissions

Detailed Data Table Section

Title: Operational Control – Emission by Sources

Excel-style table

Year-based columns

Filter Action

Filter control positioned near the chart / table area

C.2 Filter

A dedicated Filter control shall be available on the page

The filter panel shall allow users to select:

BU

OPU

Scope

Sources

Once applied:

The comparative chart refreshes

The table refreshes

Relevant titles refresh

Filter state remains active while the user stays on the page

