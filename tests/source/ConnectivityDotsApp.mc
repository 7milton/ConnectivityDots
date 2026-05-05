import Toybox.Application;
import Toybox.System;
import Toybox.Test;
import Toybox.WatchUi;

class ConnectivityDotsApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        System.println("[ConnectivityDotsTests] start");
        ConnectivityDotsManualTestRunner.run();
        System.exit();
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [new ConnectivityDotsTestView()];
    }
}

class ConnectivityDotsTestView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
    }
}

class ConnectivityDotsManualTestRunner {
    static function run() {
        var logger = new Test.Logger();

        ConnectivityValuesTestSuite.bluetoothAndWifiOk(logger);
        ConnectivityValuesTestSuite.bluetoothOkWifiDown(logger);
        ConnectivityValuesTestSuite.bluetoothDownWifiOk(logger);
        ConnectivityValuesTestSuite.bluetoothAndWifiDown(logger);
        ConnectivityValuesTestSuite.wifiUnsupportedIsWifiMinus(logger);
        ConnectivityValuesTestSuite.wifiCheckOffIsWifiMinus(logger);
        ConnectivityValuesTestSuite.wifiUnknownIsWifiMinus(logger);

        System.println("[ConnectivityDotsTests] all value tests passed");
    }
}
