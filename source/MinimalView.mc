import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Layout (top to bottom): logo, date, clock, divider, 3+3 stat grid, footer.
// Two thin bezel rings frame the face: steps goal (left), weekly intensity (right).
class MinimalView extends WatchUi.WatchFace {
    private var _sleeping as Boolean = false;
    private var _amoled as Boolean = false;
    private var _data as FaceData;
    private var _lastMinute as Number = -1;
    private var _s as Number = 0;
    private var _left as Numeric = 0;
    private var _top as Numeric = 0;
    private var _logo as WatchUi.BitmapResource;
    private var _sleepLogo as WatchUi.BitmapResource;
    private var _time as Graphics.FontType;
    private var _sleepTime as Graphics.FontType;
    private var _sleepDate as Graphics.FontType;
    private var _ui as Graphics.FontType;
    private var _bold as Graphics.FontType;
    private var _label as Graphics.FontType;

    function initialize() {
        WatchFace.initialize();
        _data = new FaceData();
        _amoled = DisplayProfile.AMOLED;
        _logo = WatchUi.loadResource(Rez.Drawables.ClubLogo) as WatchUi.BitmapResource;
        _sleepLogo = WatchUi.loadResource(Rez.Drawables.SleepLogo) as WatchUi.BitmapResource;
        _time = WatchUi.loadResource(Rez.Fonts.TimeFilled) as WatchUi.FontResource;
        _sleepTime = WatchUi.loadResource(Rez.Fonts.SleepTime) as WatchUi.FontResource;
        _sleepDate = WatchUi.loadResource(Rez.Fonts.SleepDate) as WatchUi.FontResource;
        _ui = WatchUi.loadResource(Rez.Fonts.UiSemiBold) as WatchUi.FontResource;
        _bold = WatchUi.loadResource(Rez.Fonts.UiBold) as WatchUi.FontResource;
        _label = WatchUi.loadResource(Rez.Fonts.UiLabel) as WatchUi.FontResource;
    }

    function onShow() as Void { _lastMinute = -1; }
    function onLayout(dc as Graphics.Dc) as Void {
        _s = dc.getWidth() < dc.getHeight() ? dc.getWidth() : dc.getHeight();
        _left = (dc.getWidth()-_s)/2;
        _top = (dc.getHeight()-_s)/2;
        _lastMinute = -1;
    }
    function onEnterSleep() as Void { _sleeping = true; WatchUi.requestUpdate(); }
    function onExitSleep() as Void { _sleeping = false; _lastMinute = -1; WatchUi.requestUpdate(); }

    function onUpdate(dc as Graphics.Dc) as Void {
        if (_s == 0) { onLayout(dc); }
        var now = Time.now();
        var minute = (now.value()/60).toNumber();
        var clock = System.getClockTime();
        var is24 = System.getDeviceSettings().is24Hour;
        var timeText = FaceFormat.time(clock.hour, clock.min, is24);
        var date = Gregorian.info(now, Time.FORMAT_SHORT);
        var days = ["SUN","MON","TUE","WED","THU","FRI","SAT"];
        var months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];
        var day = days[(date.day_of_week as Number)-1];
        var rest = date.day.format("%02d") + " " + months[(date.month as Number)-1];
        dc.setColor(DesignTokens.WHITE, DesignTokens.BACKGROUND);
        dc.clear();
        if (_sleeping) {
            drawSleep(dc, timeText, day+" "+rest, minute);
            return;
        }
        if (_lastMinute != minute) { _data.refresh(); _lastMinute = minute; }

        drawRings(dc);
        drawLogo(dc, _logo, DesignTokens.LOGO_Y);
        drawDate(dc, day, rest);
        drawTime(dc, timeText);

        dc.setPenWidth(1);
        dc.setColor(DesignTokens.GRAPHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x(0.30), y(DesignTokens.DIVIDER_Y), x(0.70), y(DesignTokens.DIVIDER_Y));

        var d = _data;
        stat(dc, 0.25, DesignTokens.ROW1_VALUE_Y, DesignTokens.ROW1_LABEL_Y, FaceFormat.steps(d.stepCount), "STEPS");
        stat(dc, 0.50, DesignTokens.ROW1_VALUE_Y, DesignTokens.ROW1_LABEL_Y, FaceFormat.distance(d.distanceCm), "KM");
        stat(dc, 0.75, DesignTokens.ROW1_VALUE_Y, DesignTokens.ROW1_LABEL_Y, FaceFormat.heart(d.heartRate), "BPM");
        stat(dc, 0.29, DesignTokens.ROW2_VALUE_Y, DesignTokens.ROW2_LABEL_Y, FaceFormat.calories(d.calories), "KCAL");
        stat(dc, 0.50, DesignTokens.ROW2_VALUE_Y, DesignTokens.ROW2_LABEL_Y, FaceFormat.count(d.bodyBattery), "BODY");
        stat(dc, 0.71, DesignTokens.ROW2_VALUE_Y, DesignTokens.ROW2_LABEL_Y, FaceFormat.count(d.stress), "STRESS");

        drawFooter(dc, is24 ? "" : (clock.hour < 12 ? "AM" : "PM"));
    }

    private function x(r as Numeric) as Numeric { return _left+_s*r; }
    private function y(r as Numeric) as Numeric { return _top+_s*r; }

    // Hours white, minutes lime: one weight, one accent.
    private function drawTime(dc as Graphics.Dc, value as String) as Void {
        var split = value.length()-2;
        var hours = value.substring(0, split) as String;
        var minutes = value.substring(split, value.length()) as String;
        var hw = dc.getTextWidthInPixels(hours, _time);
        var mw = dc.getTextWidthInPixels(minutes, _time);
        var start = x(0.5)-(hw+mw)/2;
        var flags = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
        dc.setColor(DesignTokens.WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(start, y(DesignTokens.TIME_Y), _time, hours, flags);
        dc.setColor(DesignTokens.LIME, Graphics.COLOR_TRANSPARENT);
        dc.drawText(start+hw, y(DesignTokens.TIME_Y), _time, minutes, flags);
    }

    private function drawDate(dc as Graphics.Dc, day as String, rest as String) as Void {
        var a = day+" ";
        var aw = dc.getTextWidthInPixels(a, _ui);
        var start = x(0.5)-(aw+dc.getTextWidthInPixels(rest, _ui))/2;
        var flags = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
        dc.setColor(DesignTokens.LIME, Graphics.COLOR_TRANSPARENT);
        dc.drawText(start, y(DesignTokens.DATE_Y), _ui, a, flags);
        dc.setColor(DesignTokens.WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(start+aw, y(DesignTokens.DATE_Y), _ui, rest, flags);
    }

    private function stat(dc as Graphics.Dc, cx as Float, valueY as Float, labelY as Float, value as String, label as String) as Void {
        var font = _bold;
        if (dc.getTextWidthInPixels(value, font) > _s*0.17) { font = _ui; }
        text(dc, value, x(cx), y(valueY), font, DesignTokens.WHITE);
        text(dc, label, x(cx), y(labelY), _label, DesignTokens.SECONDARY);
    }

    // Battery bar + percent, weekly intensity minutes, and AM/PM in 12-hour mode.
    private function drawFooter(dc as Graphics.Dc, meridiem as String) as Void {
        var d = _data;
        var week = FaceFormat.count(d.activeWeek);
        var footer = week+"/"+d.activeWeekGoal.toString()+" MIN";
        if (!meridiem.equals("")) { footer = footer+"  "+meridiem; }
        text(dc, footer, x(0.5), y(DesignTokens.FOOTER_Y), _label, DesignTokens.SECONDARY);

        var w = _s*0.16;
        var h = (_s*0.016).toNumber();
        if (h < 3) { h = 3; }
        var left = x(0.5)-w/2;
        var top = y(DesignTokens.BATTERY_BAR_Y)-h/2;
        dc.setColor(DesignTokens.GRAPHITE_DARK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(left, top, w, h);
        var level = d.batteryLevel;
        if (level != null) {
            var pct = FaceFormat.clampPercent(level);
            dc.setColor(pct <= 15 ? DesignTokens.WHITE : DesignTokens.LIME, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(left, top, w*pct/100.0, h);
        }
        text(dc, FaceFormat.battery(level), left+w+_s*0.045, y(DesignTokens.BATTERY_BAR_Y), _label, DesignTokens.SECONDARY);
    }

    // Bezel progress rings fill from the bottom upward.
    private function drawRings(dc as Graphics.Dc) as Void {
        var d = _data;
        var r = _s*(0.5-DesignTokens.RING_INSET);
        var cx = x(0.5);
        var cy = y(0.5);
        var stroke = (6*_s/454.0).toNumber();
        if (stroke < 3) { stroke = 3; }
        var span = DesignTokens.RING_SPAN;
        var leftStart = 180+span/2;   // lower-left, drawn clockwise upward
        var rightStart = 360-span/2;  // lower-right, drawn counter-clockwise upward
        dc.setPenWidth(stroke);
        dc.setColor(DesignTokens.GRAPHITE_DARK, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, leftStart, leftStart-span);
        dc.drawArc(cx, cy, r, Graphics.ARC_COUNTER_CLOCKWISE, rightStart, (rightStart+span)%360);
        var steps = FaceFormat.progress(d.stepCount, d.stepGoal);
        var week = FaceFormat.progress(d.activeWeek, d.activeWeekGoal);
        dc.setColor(DesignTokens.LIME, Graphics.COLOR_TRANSPARENT);
        if (steps > 0.01) {
            dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, leftStart, (leftStart-span*steps).toNumber());
        }
        if (week > 0.01) {
            dc.drawArc(cx, cy, r, Graphics.ARC_COUNTER_CLOCKWISE, rightStart, (rightStart+span*week).toNumber()%360);
        }
        dc.setPenWidth(1);
    }

    private function drawLogo(dc as Graphics.Dc, logo as WatchUi.BitmapResource, centerY as Numeric) as Void {
        var w = logo.getWidth();
        var h = logo.getHeight();
        var left = x(0.5)-w/2;
        var top = y(centerY)-h/2;
        dc.drawBitmap(left, top, logo);
        // Hide the embedded EST text, as in the first face.
        dc.setColor(DesignTokens.BACKGROUND, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(left+w*899/1440.0, top+h*287/481.0, w*203/1440.0, h*44/481.0);
    }

    private function drawSleep(dc as Graphics.Dc, clock as String, date as String, minute as Number) as Void {
        if (!_amoled) {
            text(dc, date, x(0.5), y(DesignTokens.DATE_Y), _ui, DesignTokens.SECONDARY);
            drawTime(dc, clock);
            drawLogo(dc, _sleepLogo, DesignTokens.LOGO_Y);
            return;
        }
        // Four non-overlapping bands rotate each minute to rest AMOLED pixels.
        var center = 0.215+(minute%4)*0.19;
        drawLogo(dc, _sleepLogo, center-0.070);
        text(dc, clock, x(0.5), y(center-0.005), _sleepTime, DesignTokens.SECONDARY);
        text(dc, date, x(0.5), y(center+0.060), _sleepDate, DesignTokens.SECONDARY);
    }

    private function text(dc as Graphics.Dc, value as String, px as Numeric, py as Numeric, font as Graphics.FontType, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(px, py, font, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
