import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Dashboard grid:
//   date | logo
//   ----------------------
//   HH:MM ss | heart / kcal / temp
//   ----------------------
//   km | steps | battery
//   weekly intensity footer
// Bezel ticks every 30 degrees, lime at 12/3/6/9.
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
    private var _icons as Dictionary<Symbol, WatchUi.BitmapResource>;
    private var _time as Graphics.FontType;
    private var _timeCompact as Graphics.FontType;
    private var _seconds as Graphics.FontType;
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
        _icons = {
            :heart => WatchUi.loadResource(Rez.Drawables.IconHeart) as WatchUi.BitmapResource,
            :flame => WatchUi.loadResource(Rez.Drawables.IconFlame) as WatchUi.BitmapResource,
            :temp => WatchUi.loadResource(Rez.Drawables.IconTemp) as WatchUi.BitmapResource,
            :run => WatchUi.loadResource(Rez.Drawables.IconRun) as WatchUi.BitmapResource,
            :steps => WatchUi.loadResource(Rez.Drawables.IconSteps) as WatchUi.BitmapResource
        };
        _time = WatchUi.loadResource(Rez.Fonts.TimeFilled) as WatchUi.FontResource;
        _timeCompact = WatchUi.loadResource(Rez.Fonts.TimeCompact) as WatchUi.FontResource;
        _seconds = WatchUi.loadResource(Rez.Fonts.TimeSeconds) as WatchUi.FontResource;
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
        var settings = System.getDeviceSettings();
        var is24 = settings.is24Hour;
        var timeText = FaceFormat.time(clock.hour, clock.min, is24);
        var meridiem = is24 ? "" : (clock.hour < 12 ? "AM" : "PM");
        var date = Gregorian.info(now, Time.FORMAT_SHORT);
        var days = ["SUN","MON","TUE","WED","THU","FRI","SAT"];
        var months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];
        var day = days[(date.day_of_week as Number)-1];
        var dayNum = date.day.format("%02d");
        var month = months[(date.month as Number)-1];
        dc.setColor(DesignTokens.WHITE, DesignTokens.BACKGROUND);
        dc.clear();
        if (_sleeping) {
            drawSleep(dc, timeText, meridiem, day+" "+dayNum+" "+month, minute);
            return;
        }
        if (_lastMinute != minute) { _data.refresh(); _lastMinute = minute; }

        drawTicks(dc);
        drawGrid(dc);
        drawDateBlock(dc, day, dayNum, month, (date.year as Number).toString());
        drawLogo(dc, _logo, DesignTokens.LOGO_X, DesignTokens.TOP_Y);
        drawTime(dc, timeText, clock.sec.format("%02d"), meridiem, DesignTokens.TIME_LEFT_X, DesignTokens.TIME_RIGHT_X);

        var d = _data;
        var fahrenheit = settings.temperatureUnits == System.UNIT_STATUTE;
        var rows = DesignTokens.SIDE_ROWS;
        sideStat(dc, rows[0], :heart, FaceFormat.heart(d.heartRate), "BPM");
        sideStat(dc, rows[1], :flame, FaceFormat.calories(d.calories), "KCAL");
        sideStat(dc, rows[2], :temp, FaceFormat.temperature(d.temperatureC, fahrenheit), fahrenheit ? "F" : "C");

        var cols = DesignTokens.BOTTOM_COLUMNS;
        bottomStat(dc, cols[0], :run, FaceFormat.distance(d.distanceCm), "KM");
        bottomStat(dc, cols[1], :steps, FaceFormat.steps(d.stepCount), "STEPS");
        bottomBattery(dc, cols[2]);

        var footer = "WEEK "+FaceFormat.count(d.activeWeek)+"/"+d.activeWeekGoal.toString()+" MIN";
        text(dc, footer, x(0.5), y(DesignTokens.FOOTER_Y), _label, DesignTokens.SECONDARY);
    }

    private function x(r as Numeric) as Numeric { return _left+_s*r; }
    private function y(r as Numeric) as Numeric { return _top+_s*r; }

    private function drawTicks(dc as Graphics.Dc) as Void {
        var cx = x(0.5);
        var cy = y(0.5);
        var outer = _s*0.495;
        var pen = (3*_s/454.0).toNumber();
        if (pen < 2) { pen = 2; }
        for (var i = 0; i < 12; i++) {
            var cardinal = i % 3 == 0;
            var inner = outer-_s*(cardinal ? 0.045 : 0.025);
            var a = Math.toRadians(i*30);
            var sn = Math.sin(a);
            var cs = Math.cos(a);
            dc.setPenWidth(cardinal ? pen+1 : pen);
            dc.setColor(cardinal ? DesignTokens.LIME : DisplayProfile.LINE, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(cx+sn*inner, cy-cs*inner, cx+sn*outer, cy-cs*outer);
        }
        dc.setPenWidth(1);
    }

    private function drawGrid(dc as Graphics.Dc) as Void {
        var pen = (2*_s/454.0+0.5).toNumber();
        if (pen < 1) { pen = 1; }
        dc.setPenWidth(pen);
        dc.setColor(DisplayProfile.LINE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x(0.10), y(DesignTokens.LINE_1_Y), x(0.90), y(DesignTokens.LINE_1_Y));
        dc.drawLine(x(0.10), y(DesignTokens.LINE_2_Y), x(0.90), y(DesignTokens.LINE_2_Y));
        dc.drawLine(x(DesignTokens.TOP_DIVIDER_X), y(0.150), x(DesignTokens.TOP_DIVIDER_X), y(0.300));
        dc.drawLine(x(DesignTokens.MID_DIVIDER_X), y(0.350), x(DesignTokens.MID_DIVIDER_X), y(0.620));
        var cols = DesignTokens.BOTTOM_COLUMNS;
        for (var i = 0; i < cols.size()-1; i++) {
            var dx = x((cols[i]+cols[i+1])/2.0);
            dc.drawLine(dx, y(0.680), dx, y(0.790));
        }
        dc.setPenWidth(1);
    }

    // SAT / 26 APR / 2026, right-aligned against the top divider.
    private function drawDateBlock(dc as Graphics.Dc, day as String, dayNum as String, month as String, year as String) as Void {
        var right = x(DesignTokens.TOP_DIVIDER_X-0.03);
        var flags = Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER;
        dc.setColor(DesignTokens.WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(right, y(DesignTokens.TOP_Y-0.058), _ui, day, flags);
        var monthText = " "+month;
        var mw = dc.getTextWidthInPixels(monthText, _bold);
        dc.drawText(right, y(DesignTokens.TOP_Y+0.002), _bold, monthText, flags);
        dc.setColor(DesignTokens.LIME, Graphics.COLOR_TRANSPARENT);
        dc.drawText(right-mw, y(DesignTokens.TOP_Y+0.002), _bold, dayNum, flags);
        dc.setColor(DesignTokens.SECONDARY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(right, y(DesignTokens.TOP_Y+0.058), _label, year, flags);
    }

    // HH:MM large white; seconds small grey, bottom-aligned; AM/PM above seconds.
    // Centered between leftX and rightX; falls back to a compact font when the
    // group would cross the panel edges (small screens, wide digits).
    private function drawTime(dc as Graphics.Dc, hhmm as String, secs as String or Null, meridiem as String, leftX as Float, rightX as Float) as Void {
        var sw = secs == null ? 0 : dc.getTextWidthInPixels(secs, _seconds);
        var gap = secs == null ? 0 : _s*0.012;
        var font = _time;
        var tw = dc.getTextWidthInPixels(hhmm, font);
        if (tw+gap+sw > _s*(rightX-leftX)) {
            font = _timeCompact;
            tw = dc.getTextWidthInPixels(hhmm, font);
        }
        var start = x((leftX+rightX)/2)-(tw+gap+sw)/2;
        var cy = y(DesignTokens.TIME_Y);
        var bigH = dc.getFontHeight(font);
        var flags = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
        dc.setColor(DesignTokens.WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(start, cy, font, hhmm, flags);
        if (secs != null) {
            var smallH = dc.getFontHeight(_seconds);
            dc.setColor(DesignTokens.SECONDARY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(start+tw+gap, cy+(bigH-smallH)/2, _seconds, secs, flags);
            if (!meridiem.equals("")) {
                dc.setColor(DesignTokens.LIME, Graphics.COLOR_TRANSPARENT);
                dc.drawText(start+tw+gap, cy-bigH/2+dc.getFontHeight(_label)/2, _label, meridiem, flags);
            }
        } else if (!meridiem.equals("")) {
            text(dc, meridiem, x((leftX+rightX)/2), cy+bigH/2+_s*0.02, _label, DesignTokens.SECONDARY);
        }
    }

    // Icon, value, small unit on one line in the right column.
    private function sideStat(dc as Graphics.Dc, rowY as Float, icon as Symbol, value as String, unit as String) as Void {
        var cy = y(rowY);
        var bmp = _icons[icon] as WatchUi.BitmapResource;
        dc.drawBitmap(x(DesignTokens.SIDE_ICON_X)-bmp.getWidth()/2, cy-bmp.getHeight()/2, bmp);
        var flags = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
        var vx = x(DesignTokens.SIDE_VALUE_X);
        dc.setColor(DesignTokens.WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(vx, cy, _bold, value, flags);
        var vw = dc.getTextWidthInPixels(value, _bold);
        var offset = (dc.getFontHeight(_bold)-dc.getFontHeight(_label))/2*0.75;
        dc.setColor(DesignTokens.SECONDARY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(vx+vw+_s*0.008, cy+offset, _label, unit, flags);
    }

    // Icon beside the value, label centered under the value.
    private function bottomStat(dc as Graphics.Dc, cx as Float, icon as Symbol, value as String, label as String) as Void {
        var bmp = _icons[icon] as WatchUi.BitmapResource;
        drawBottomCell(dc, cx, bmp.getWidth(), value, label);
        var start = bottomStart(dc, cx, bmp.getWidth(), value);
        dc.drawBitmap(start, y(DesignTokens.BOTTOM_Y)-bmp.getHeight()/2, bmp);
    }

    private function bottomBattery(dc as Graphics.Dc, cx as Float) as Void {
        var level = _data.batteryLevel;
        var w = (_s*0.050).toNumber();
        var h = (_s*0.026).toNumber();
        var value = FaceFormat.battery(level);
        drawBottomCell(dc, cx, w+2, value, "BATTERY");
        var left = bottomStart(dc, cx, w+2, value);
        var top = y(DesignTokens.BOTTOM_Y)-h/2;
        dc.setPenWidth(1);
        dc.setColor(DesignTokens.LIME, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(left, top, w, h);
        dc.fillRectangle(left+w, top+h*0.3, 2, h*0.4);
        if (level != null) {
            var pct = FaceFormat.clampPercent(level);
            if (pct <= 15) { dc.setColor(DesignTokens.WHITE, Graphics.COLOR_TRANSPARENT); }
            dc.fillRectangle(left+2, top+2, (w-4)*pct/100.0, h-4);
        }
    }

    private function bottomStart(dc as Graphics.Dc, cx as Float, iconW as Number, value as String) as Numeric {
        var total = iconW+_s*0.018+dc.getTextWidthInPixels(value, _bold);
        return x(cx)-total/2;
    }

    private function drawBottomCell(dc as Graphics.Dc, cx as Float, iconW as Number, value as String, label as String) as Void {
        var start = bottomStart(dc, cx, iconW, value);
        var vx = start+iconW+_s*0.018;
        var vw = dc.getTextWidthInPixels(value, _bold);
        dc.setColor(DesignTokens.WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(vx, y(DesignTokens.BOTTOM_Y), _bold, value, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        text(dc, label, vx+vw/2, y(DesignTokens.BOTTOM_Y+0.052), _label, DesignTokens.SECONDARY);
    }

    private function drawLogo(dc as Graphics.Dc, logo as WatchUi.BitmapResource, centerX as Numeric, centerY as Numeric) as Void {
        var w = logo.getWidth();
        var h = logo.getHeight();
        var left = x(centerX)-w/2;
        var top = y(centerY)-h/2;
        dc.drawBitmap(left, top, logo);
        // Hide the embedded EST text, as in the first face.
        dc.setColor(DesignTokens.BACKGROUND, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(left+w*899/1440.0, top+h*287/481.0, w*203/1440.0, h*44/481.0);
    }

    private function drawSleep(dc as Graphics.Dc, clock as String, meridiem as String, date as String, minute as Number) as Void {
        if (!_amoled) {
            drawLogo(dc, _sleepLogo, 0.5, 0.20);
            text(dc, date, x(0.5), y(0.30), _ui, DesignTokens.SECONDARY);
            drawTime(dc, clock, null, meridiem, 0.06, 0.94);
            return;
        }
        // Four non-overlapping bands rotate each minute to rest AMOLED pixels.
        var center = 0.215+(minute%4)*0.19;
        drawLogo(dc, _sleepLogo, 0.5, center-0.070);
        text(dc, clock, x(0.5), y(center-0.005), _sleepTime, DesignTokens.SECONDARY);
        text(dc, date, x(0.5), y(center+0.060), _sleepDate, DesignTokens.SECONDARY);
    }

    private function text(dc as Graphics.Dc, value as String, px as Numeric, py as Numeric, font as Graphics.FontType, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(px, py, font, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
