// Run Club Atyrau Minimal: a dashboard grid in the club palette.
// All positions are fractions of the centered square.
module DesignTokens {
    const BACKGROUND = 0x000000;
    const LIME = 0xCCFF00;
    const WHITE = 0xF4F4F4;
    const SECONDARY = 0xBEBEBE;
    const GRAPHITE = 0x454545;
    const GRAPHITE_DARK = 0x222222;

    // Top block: date (left) | logo (right)
    const TOP_Y = 0.225;
    const DATE_X = 0.30;
    const LOGO_X = 0.660;
    const TOP_DIVIDER_X = 0.44;
    const LINE_1_Y = 0.325;

    // Middle block: time (left) | heart, calories, temperature (right)
    const TIME_Y = 0.485;
    // Time panel spans from past the 9 o'clock tick to the column divider.
    const TIME_LEFT_X = 0.065;
    const TIME_RIGHT_X = 0.675;
    const MID_DIVIDER_X = 0.700;
    const SIDE_ICON_X = 0.755;
    const SIDE_VALUE_X = 0.795;
    const SIDE_ROWS = [0.385, 0.485, 0.585];
    const LINE_2_Y = 0.645;

    // Bottom row: distance | steps | battery, then intensity footer
    const BOTTOM_Y = 0.725;
    const BOTTOM_COLUMNS = [0.25, 0.50, 0.75];
    const FOOTER_Y = 0.845;

    const DEFAULT_STEP_GOAL = 10000;
    const DEFAULT_ACTIVE_WEEK_GOAL = 150;
}
