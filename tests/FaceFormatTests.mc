import Toybox.Test;
import Toybox.Lang;

(:test)
function timeBoundaries(logger as Test.Logger) as Boolean {
    Test.assertEqual(FaceFormat.time(0, 0, true), "00:00");
    Test.assertEqual(FaceFormat.time(0, 5, false), "12:05");
    Test.assertEqual(FaceFormat.time(12, 0, false), "12:00");
    Test.assertEqual(FaceFormat.time(23, 59, false), "11:59");
    Test.assertEqual(FaceFormat.time(23, 59, true), "23:59");
    return true;
}

(:test)
function missingAndLargeData(logger as Test.Logger) as Boolean {
    Test.assertEqual(FaceFormat.steps(null), "0");
    Test.assertEqual(FaceFormat.steps(-1), "0");
    Test.assertEqual(FaceFormat.steps(0), "0");
    Test.assertEqual(FaceFormat.steps(999), "999");
    Test.assertEqual(FaceFormat.steps(1000), "1.0K");
    Test.assertEqual(FaceFormat.steps(10005), "10.0K");
    Test.assertEqual(FaceFormat.steps(12400), "12.4K");
    Test.assertEqual(FaceFormat.steps(99999), "100K");
    Test.assertEqual(FaceFormat.steps(100000), "100K");
    Test.assertEqual(FaceFormat.heart(null), "--");
    Test.assertEqual(FaceFormat.heart(0), "--");
    Test.assertEqual(FaceFormat.heart(85), "85");
    Test.assertEqual(FaceFormat.battery(null), "--%");
    Test.assertEqual(FaceFormat.battery(0), "0%");
    Test.assertEqual(FaceFormat.battery(99.9), "99%");
    Test.assertEqual(FaceFormat.battery(101), "100%");
    return true;
}

(:test)
function dailyDistanceUnits(logger as Test.Logger) as Boolean {
    Test.assertEqual(FaceFormat.distance(null), "0.0");
    Test.assertEqual(FaceFormat.distance(-1), "0.0");
    Test.assertEqual(FaceFormat.distance(0), "0.0");
    Test.assertEqual(FaceFormat.distance(480000), "4.8");
    Test.assertEqual(FaceFormat.distance(995000), "10");
    Test.assertEqual(FaceFormat.distance(1200000), "12");
    Test.assertEqual(FaceFormat.distance(1280000), "13");
    return true;
}

(:test)
function extendedStats(logger as Test.Logger) as Boolean {
    Test.assertEqual(FaceFormat.count(null), "--");
    Test.assertEqual(FaceFormat.count(-1), "--");
    Test.assertEqual(FaceFormat.count(0), "0");
    Test.assertEqual(FaceFormat.count(73), "73");
    Test.assertEqual(FaceFormat.temperature(null, false), "--");
    Test.assertEqual(FaceFormat.temperature(14, false), "14°");
    Test.assertEqual(FaceFormat.temperature(-3.6, false), "-4°");
    Test.assertEqual(FaceFormat.temperature(20, true), "68°");
    Test.assertEqual(FaceFormat.calories(null), "--");
    Test.assertEqual(FaceFormat.calories(2140), "2140");
    Test.assertEqual(FaceFormat.calories(12400), "12.4K");
    Test.assertEqual(FaceFormat.progress(null, 100), 0.0);
    Test.assertEqual(FaceFormat.progress(50, 100), 0.5);
    Test.assertEqual(FaceFormat.progress(300, 150), 1.0);
    Test.assertEqual(FaceFormat.progress(10, 0), 0.0);
    return true;
}
