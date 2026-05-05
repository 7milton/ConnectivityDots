import Toybox.Test;

(:test)
class ConnectivityValuesTestSuite {
    static function assertPublishedValues(status, expectedCombined, expectedBluetooth, expectedWifi) {
        var values = ConnectivityValues.build(status);

        Test.assertEqual(expectedCombined, values.combined);
        Test.assertEqual(expectedBluetooth, values.bluetooth);
        Test.assertEqual(expectedWifi, values.wifi);
    }

    static function statusWithWifi(bluetoothOk, wifiOk) {
        return new ConnectivityValuesTestStatus(bluetoothOk, wifiOk);
    }

    static function statusWithUnsupportedWifi(bluetoothOk) {
        return new ConnectivityValuesTestStatus(bluetoothOk, false);
    }

    static function statusWithUnknownWifi(bluetoothOk) {
        return new ConnectivityValuesTestStatus(bluetoothOk, false);
    }

    (:test)
    static function bluetoothAndWifiOk(logger) {
        ConnectivityValuesTestSuite.assertPublishedValues(
            ConnectivityValuesTestSuite.statusWithWifi(true, true),
            "BT+ WiFi+",
            "BT+",
            "WiFi+"
        );
        return true;
    }

    (:test)
    static function bluetoothOkWifiDown(logger) {
        ConnectivityValuesTestSuite.assertPublishedValues(
            ConnectivityValuesTestSuite.statusWithWifi(true, false),
            "BT+ WiFi-",
            "BT+",
            "WiFi-"
        );
        return true;
    }

    (:test)
    static function bluetoothDownWifiOk(logger) {
        ConnectivityValuesTestSuite.assertPublishedValues(
            ConnectivityValuesTestSuite.statusWithWifi(false, true),
            "BT- WiFi+",
            "BT-",
            "WiFi+"
        );
        return true;
    }

    (:test)
    static function bluetoothAndWifiDown(logger) {
        ConnectivityValuesTestSuite.assertPublishedValues(
            ConnectivityValuesTestSuite.statusWithWifi(false, false),
            "OFF",
            "BT-",
            "WiFi-"
        );
        return true;
    }

    (:test)
    static function wifiUnsupportedIsWifiMinus(logger) {
        ConnectivityValuesTestSuite.assertPublishedValues(
            ConnectivityValuesTestSuite.statusWithUnsupportedWifi(true),
            "BT+ WiFi-",
            "BT+",
            "WiFi-"
        );
        ConnectivityValuesTestSuite.assertPublishedValues(
            ConnectivityValuesTestSuite.statusWithUnsupportedWifi(false),
            "OFF",
            "BT-",
            "WiFi-"
        );
        return true;
    }

    (:test)
    static function wifiCheckOffIsWifiMinus(logger) {
        ConnectivityValuesTestSuite.assertPublishedValues(
            ConnectivityValuesTestSuite.statusWithUnsupportedWifi(true),
            "BT+ WiFi-",
            "BT+",
            "WiFi-"
        );
        return true;
    }

    (:test)
    static function wifiUnknownIsWifiMinus(logger) {
        ConnectivityValuesTestSuite.assertPublishedValues(
            ConnectivityValuesTestSuite.statusWithUnknownWifi(true),
            "BT+ WiFi-",
            "BT+",
            "WiFi-"
        );
        ConnectivityValuesTestSuite.assertPublishedValues(
            ConnectivityValuesTestSuite.statusWithUnknownWifi(false),
            "OFF",
            "BT-",
            "WiFi-"
        );
        return true;
    }
}

class ConnectivityValuesTestStatus {
    var bluetoothOk;
    var _wifiConnected;

    function initialize(bluetoothOkValue, wifiConnectedValue) {
        bluetoothOk = (bluetoothOkValue == true);
        _wifiConnected = (wifiConnectedValue == true);
    }

    function isWifiConnected() {
        return _wifiConnected == true;
    }
}
