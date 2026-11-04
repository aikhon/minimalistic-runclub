import Toybox.Lang;

// Pure formatting helpers, also exercised by simulator unit tests.
module FaceFormat {
    function time(hour as Number, minute as Number, is24 as Boolean) as String {
        var h = hour;
        if (!is24) {
            h = hour % 12;
            if (h == 0) { h = 12; }
        }
        return h.format(is24 ? "%02d" : "%d") + ":" + minute.format("%02d");
    }

    function steps(value as Number or Null) as String {
        if (value == null || value < 0) { return "0"; }
        if (value < 1000) { return value.toString(); }
        if (value < 99950) { return (value / 1000.0).format("%.1f") + "K"; }
        return (value / 1000.0).format("%.0f") + "K";
    }

    function distance(value as Number or Null) as String {
        if (value == null || value < 0) { return "0.0"; }
        var km = value / 100000.0;
        return km < 9.95 ? km.format("%.1f") : km.format("%.0f");
    }

    // Generic count; missing or invalid values show a dash pair.
    function count(value as Number or Null) as String {
        return (value == null || value < 0) ? "--" : value.toString();
    }

    // Calories above 9999 abbreviate like steps.
    function calories(value as Number or Null) as String {
        if (value == null || value < 0) { return "--"; }
        if (value < 10000) { return value.toString(); }
        return (value / 1000.0).format("%.1f") + "K";
    }

    function heart(value as Number or Null) as String {
        return (value == null || value <= 0) ? "--" : value.toString();
    }

    function battery(value as Number or Float or Null) as String {
        if (value == null) { return "--%"; }
        return clampPercent(value).toString() + "%";
    }

    function clampPercent(value as Number or Float) as Number {
        var p = value.toNumber();
        if (p < 0) { return 0; }
        if (p > 100) { return 100; }
        return p;
    }

    function progress(value as Number or Null, goal as Number) as Float {
        if (value == null || value <= 0 || goal <= 0) { return 0.0; }
        var p = value.toFloat() / goal;
        return p > 1.0 ? 1.0 : p;
    }
}
