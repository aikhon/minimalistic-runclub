import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;

// Reads recorded data only; never enables a sensor. Refreshed once per minute.
class FaceData {
    var stepCount as Number or Null = null;
    var stepGoal as Number = DesignTokens.DEFAULT_STEP_GOAL;
    var distanceCm as Number or Null = null;
    var calories as Number or Null = null;
    var floors as Number or Null = null;
    var activeWeek as Number or Null = null;
    var activeWeekGoal as Number = DesignTokens.DEFAULT_ACTIVE_WEEK_GOAL;
    var heartRate as Number or Null = null;
    var bodyBattery as Number or Null = null;
    var stress as Number or Null = null;
    var batteryLevel as Number or Float or Null = null;
    var notifications as Number or Null = null;

    function initialize() {}

    function refresh() as Void {
        var stats = System.getSystemStats();
        batteryLevel = stats.battery;
        var settings = System.getDeviceSettings();
        notifications = settings.notificationCount;
        var activity = ActivityMonitor.getInfo();
        var tracking = settings.activityTrackingOn;
        stepCount = tracking ? activity.steps : null;
        distanceCm = tracking ? activity.distance : null;
        calories = activity.calories;
        floors = (activity has :floorsClimbed) ? activity.floorsClimbed : null;
        var goal = activity.stepGoal;
        stepGoal = (goal != null && goal > 0) ? goal : DesignTokens.DEFAULT_STEP_GOAL;
        activeWeek = null;
        if (activity has :activeMinutesWeek) {
            var week = activity.activeMinutesWeek;
            if (week != null) { activeWeek = week.total; }
        }
        var weekGoal = (activity has :activeMinutesWeekGoal) ? activity.activeMinutesWeekGoal : null;
        activeWeekGoal = (weekGoal != null && weekGoal > 0) ? weekGoal : DesignTokens.DEFAULT_ACTIVE_WEEK_GOAL;

        heartRate = null;
        bodyBattery = null;
        stress = null;
        if (Toybox has :SensorHistory) {
            if (SensorHistory has :getHeartRateHistory) {
                heartRate = latest(SensorHistory.getHeartRateHistory({
                    :period => new Time.Duration(300), :order => SensorHistory.ORDER_NEWEST_FIRST }));
            }
            if (SensorHistory has :getBodyBatteryHistory) {
                bodyBattery = latest(SensorHistory.getBodyBatteryHistory({
                    :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST }));
            }
            if (SensorHistory has :getStressHistory) {
                stress = latest(SensorHistory.getStressHistory({
                    :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST }));
            }
        }
    }

    // First non-negative sample from a newest-first iterator, or null.
    private function latest(iterator as SensorHistory.SensorHistoryIterator) as Number or Null {
        var sample = iterator.next();
        while (sample != null) {
            var reading = sample.data;
            if (reading != null && reading >= 0) { return reading.toNumber(); }
            sample = iterator.next();
        }
        return null;
    }
}
