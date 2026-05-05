import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

(:background)
module ConnectivityStatus {
    (:background)
    var _activeReader = null;

    (:background)
    class Status {
        var bluetoothOk;
        var wifiSupported;
        var wifiOk;
        var wifiUnknown;
        var wifiErrorCode;
        var checkedAt;

        function initialize() {
            bluetoothOk = false;
            wifiSupported = false;
            wifiOk = false;
            wifiUnknown = false;
            wifiErrorCode = null;
            checkedAt = Time.now().value();
        }

        function markChecked() {
            checkedAt = Time.now().value();
        }

        function setBluetoothConnected(connected) {
            bluetoothOk = (connected == true);
        }

        function setWifiUnsupported() {
            wifiSupported = false;
            wifiOk = false;
            wifiUnknown = false;
        }

        function setWifiUnknown() {
            wifiSupported = false;
            wifiOk = false;
            wifiUnknown = true;
        }

        function setWifiConnected(connected) {
            wifiSupported = true;
            wifiOk = (connected == true);
            wifiUnknown = false;
        }

        function applyWifiCheckResult(result as {:wifiAvailable as Lang.Boolean, :errorCode as Communications.WifiConnectionStatus}) {
            if (result != null) {
                if (result.hasKey(:wifiAvailable)) {
                    setWifiConnected(result[:wifiAvailable] == true);
                } else {
                    setWifiConnected(false);
                }

                if (result.hasKey(:errorCode)) {
                    wifiErrorCode = result[:errorCode];
                }
            }

            wifiUnknown = false;
            markChecked();
        }

        function isWifiConnected() {
            return (wifiSupported == true) && (wifiOk == true);
        }

        function isAllOff() {
            return (bluetoothOk != true) && !isWifiConnected();
        }

        function summary() {
            return "bt=" + bluetoothOk.toString() +
                " wifiSupported=" + wifiSupported.toString() +
                " wifiOk=" + wifiOk.toString();
        }
    }

    (:background)
    class Reader {
        var _callback;
        var _status;

        function initialize(callback) {
            _callback = callback;
            _status = null;
        }

        function start() {
            var mode = Settings.wifiCheckMode();
            Settings.log("status read start mode=" + mode);

            _status = readDeviceStatus(mode);

            if (shouldRunPreciseWifiCheck(mode) && startPreciseWifiCheck()) {
                return;
            }

            finish();
        }

        function onWifiCheckComplete(result as {:wifiAvailable as Lang.Boolean, :errorCode as Communications.WifiConnectionStatus}) as Void {
            try {
                _status.applyWifiCheckResult(result);
                Settings.log("checkWifiConnection done wifiOk=" + _status.wifiOk.toString());
            } catch (e) {
                Settings.debug("Wi-Fi callback parse failed");
            }

            finish();
        }

        function shouldRunPreciseWifiCheck(mode) {
            return (mode == Settings.WIFI_MODE_PRECISE) && (_status.wifiSupported == true);
        }

        function startPreciseWifiCheck() {
            if (!(Communications has :checkWifiConnection)) {
                return false;
            }

            try {
                Settings.log("checkWifiConnection start");
                Communications.checkWifiConnection(method(:onWifiCheckComplete));
                return true;
            } catch (e) {
                Settings.debug("checkWifiConnection failed; using simple Wi-Fi state");
            }

            return false;
        }

        function finish() {
            var callback = _callback;
            var status = _status;
            _callback = null;
            ConnectivityStatus._activeReader = null;

            if (callback != null) {
                callback.invoke(status);
            }
        }
    }

    (:background)
    function read(callback) {
        _activeReader = new Reader(callback);
        _activeReader.start();
    }

    (:background)
    function readDeviceStatus(mode) {
        var status = new Status();
        status.markChecked();

        try {
            var deviceSettings = System.getDeviceSettings();
            status.setBluetoothConnected(deviceSettings.phoneConnected == true);
            updateWifiFromDeviceSettings(status, deviceSettings, mode);
            Settings.log("device settings " + status.summary());
        } catch (e) {
            Settings.debug("System.getDeviceSettings failed");
        }

        return status;
    }

    (:background)
    function updateWifiFromDeviceSettings(status, deviceSettings, mode) {
        if (mode == Settings.WIFI_MODE_OFF) {
            status.setWifiUnsupported();
            return;
        }

        try {
            var wifiInfo = getWifiInfo(deviceSettings);
            if (wifiInfo == null) {
                status.setWifiUnsupported();
                return;
            }

            status.setWifiConnected(wifiInfo.state == System.CONNECTION_STATE_CONNECTED);
        } catch (e) {
            status.setWifiUnknown();
            Settings.debug("connectionInfo Wi-Fi read failed");
        }
    }

    (:background)
    function getWifiInfo(deviceSettings) {
        if (!(deviceSettings has :connectionInfo)) {
            return null;
        }

        var connectionInfo = deviceSettings.connectionInfo as Lang.Dictionary;
        if ((connectionInfo == null) || !connectionInfo.hasKey(:wifi)) {
            return null;
        }

        return connectionInfo[:wifi];
    }
}
