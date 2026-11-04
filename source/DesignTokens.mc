// Run Club Atyrau Minimal: same palette as the first face, fewer ornaments,
// more data. All positions are fractions of the centered square.
module DesignTokens {
    const BACKGROUND = 0x000000;
    const LIME = 0xCCFF00;
    const WHITE = 0xF4F4F4;
    const SECONDARY = 0xBEBEBE;
    const GRAPHITE = 0x454545;
    const GRAPHITE_DARK = 0x222222;

    const LOGO_Y = 0.105;
    const DATE_Y = 0.198;
    const TIME_Y = 0.360;
    const DIVIDER_Y = 0.482;
    const ROW1_VALUE_Y = 0.555;
    const ROW1_LABEL_Y = 0.612;
    const ROW2_VALUE_Y = 0.700;
    const ROW2_LABEL_Y = 0.757;
    const FOOTER_Y = 0.850;
    const BATTERY_BAR_Y = 0.895;

    // Outer bezel rings: left = daily step goal, right = weekly intensity minutes.
    const RING_INSET = 0.022;
    const RING_SPAN = 100;
    const DEFAULT_STEP_GOAL = 10000;
    const DEFAULT_ACTIVE_WEEK_GOAL = 150;
}
