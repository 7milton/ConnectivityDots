import Toybox.Application.Storage;
import Toybox.Time;

(:background)
module ConnectivityStore {
    const KEY_LAST_BLUETOOTH_OK = "lastBluetoothOk";
    const KEY_LAST_WIFI_SUPPORTED = "lastWifiSupported";
    const KEY_LAST_WIFI_OK = "lastWifiOk";
    const KEY_LAST_WIFI_UNKNOWN = "lastWifiUnknown";
    const KEY_LAST_WIFI_ERROR_CODE = "lastWifiErrorCode";
    const KEY_LAST_CHECKED_AT = "lastCheckedAt";
    const KEY_LAST_COMBINED_VALUE = "lastCombinedValue";
    const KEY_LAST_BT_VALUE = "lastBtValue";
    const KEY_LAST_WIFI_VALUE = "lastWifiValue";
    const KEY_LAST_STORED_AT = "lastStoredAt";

    (:background)
    function writeSnapshot(status, values) {
        try {
            Storage.setValue(KEY_LAST_BLUETOOTH_OK, status.bluetoothOk);
            Storage.setValue(KEY_LAST_WIFI_SUPPORTED, status.wifiSupported);
            Storage.setValue(KEY_LAST_WIFI_OK, status.wifiOk);
            Storage.setValue(KEY_LAST_WIFI_UNKNOWN, status.wifiUnknown);
            Storage.setValue(KEY_LAST_WIFI_ERROR_CODE, errorCodeText(status));
            Storage.setValue(KEY_LAST_CHECKED_AT, status.checkedAt);
            Storage.setValue(KEY_LAST_COMBINED_VALUE, values.combined);
            Storage.setValue(KEY_LAST_BT_VALUE, values.bluetooth);
            Storage.setValue(KEY_LAST_WIFI_VALUE, values.wifi);
            Storage.setValue(KEY_LAST_STORED_AT, Time.now().value());
        } catch (e) {
            Settings.debug("Storage update failed");
        }
    }

    function readValue(key) {
        try {
            return Storage.getValue(key);
        } catch (e) {
        }

        return null;
    }

    function readString(key, fallback) {
        var value = readValue(key);
        if (value != null) {
            return value.toString();
        }

        return fallback;
    }

    function readBoolean(key) {
        var value = readValue(key);
        if ((value == true) || (value == false)) {
            return value;
        }

        return null;
    }

    (:background)
    function errorCodeText(status) {
        if (status.wifiErrorCode == null) {
            return "";
        }

        return status.wifiErrorCode.toString();
    }
}
