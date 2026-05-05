import Toybox.Application.Properties;
import Toybox.System;

(:background)
module Settings {
    const WIFI_MODE_PRECISE = "precise";
    const WIFI_MODE_SIMPLE = "simple";
    const WIFI_MODE_OFF = "off";
    const MIN_REFRESH_MINUTES = 5;

    (:background)
    function wifiCheckMode() {
        var mode = getString("wifiCheckMode", WIFI_MODE_PRECISE);
        if ((mode == WIFI_MODE_SIMPLE) || (mode == WIFI_MODE_OFF)) {
            return mode;
        }

        return WIFI_MODE_PRECISE;
    }

    (:background)
    function refreshIntervalMinutes() {
        var value = getNumber("refreshIntervalMinutes", 15);
        if (value < MIN_REFRESH_MINUTES) {
            return MIN_REFRESH_MINUTES;
        }

        return value;
    }

    (:background)
    function showCombined() {
        return getBoolean("showCombined", true);
    }

    (:background)
    function showBluetooth() {
        return getBoolean("showBluetooth", true);
    }

    (:background)
    function showWifi() {
        return getBoolean("showWifi", true);
    }

    (:background)
    function debugMode() {
        return getBoolean("debugMode", false);
    }

    (:background)
    function debug(message) {
        if (debugMode()) {
            log(message);
        }
    }

    (:background)
    function log(message) {
        System.println("[ConnectivityDots] " + message);
    }

    (:background)
    function getBoolean(key, fallback) {
        try {
            var value = Properties.getValue(key);
            if (value == true) {
                return true;
            } else if (value == false) {
                return false;
            }
        } catch (e) {
        }

        return fallback;
    }

    (:background)
    function getString(key, fallback) {
        try {
            var value = Properties.getValue(key);
            if (value != null) {
                return value.toString();
            }
        } catch (e) {
        }

        return fallback;
    }

    (:background)
    function getNumber(key, fallback) {
        try {
            var value = Properties.getValue(key);
            if (value != null) {
                return value;
            }
        } catch (e) {
        }

        return fallback;
    }
}
