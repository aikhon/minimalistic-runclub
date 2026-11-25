import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;
import Toybox.Weather;

// Reads recorded data only; never enables a sensor. Refreshed once per minute.
class FaceData {
    var stepCount as Number or Null = null;
    var stepGoal as Number = DesignTokens.DEFAULT_STEP_GOAL;
    var distanceCm as Number or Null = null;
    var calories as Number or Null = null;
    var activeWeek as Number or Null = null;
    var activeWeekGoal as Number = DesignTokens.DEFAULT_ACTIVE_WEEK_GOAL;
    var heartRate as Number or Null = null;
    var temperatureC as Number or Float or Null = null;
    var batteryLevel as Number or Float or Null = null;

    function initialize() {}

    function refresh() as Void {
        batteryLevel = System.getSystemStats().battery;
        var activity = ActivityMonitor.getInfo();
        var tracking = System.getDeviceSettings().activityTrackingOn;
        stepCount = tracking ? activity.steps : null;
        distanceCm = tracking ? activity.distance : null;
        calories = activity.calories;
        var goal = activity.stepGoal;
        stepGoal = (goal != null && goal > 0) ? goal : DesignTokens.DEFAULT_STEP_GOAL;
        activeWeek = null;
        if (activity has :activeMinutesWeek) {
            var week = activity.activeMinutesWeek;
            if (week != null) { activeWeek = week.total; }
        }
        var weekGoal = (activity has :activeMinutesWeekGoal) ? activity.activeMinutesWeekGoal : null;
        activeWeekGoal = (weekGoal != null && weekGoal > 0) ? weekGoal : DesignTokens.DEFAULT_ACTIVE_WEEK_GOAL;

        // Forecast data synced from the phone; null when never synced.
        temperatureC = null;
        if (Toybox has :Weather) {
            var conditions = Weather.getCurrentConditions();
            if (conditions != null) {
                var t = conditions.temperature;
                if (t != null) { temperatureC = t.toFloat(); }
            }
        }

        heartRate = null;
        if ((Toybox has :SensorHistory) && (SensorHistory has :getHeartRateHistory)) {
            var iterator = SensorHistory.getHeartRateHistory({
                :period => new Time.Duration(300), :order => SensorHistory.ORDER_NEWEST_FIRST });
            var sample = iterator.next();
            while (sample != null) {
                var reading = sample.data;
                if (reading != null && reading > 0) { heartRate = reading.toNumber(); break; }
                sample = iterator.next();
            }
        }
    }
}
