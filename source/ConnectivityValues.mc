(:background)
module ConnectivityValues {
    const VALUE_OFF = "OFF";
    const VALUE_BLUETOOTH_ON = "BT+";
    const VALUE_BLUETOOTH_OFF = "BT-";
    const VALUE_WIFI_ON = "WiFi+";
    const VALUE_WIFI_OFF = "WiFi-";

    (:background)
    class PublishedValues {
        var combined;
        var bluetooth;
        var wifi;

        function initialize(bluetoothOk, wifiConnected) {
            bluetooth = ConnectivityValues.buildBluetoothToken(bluetoothOk);
            wifi = ConnectivityValues.buildWifiToken(wifiConnected);
            combined = ConnectivityValues.buildCombinedToken(bluetoothOk, wifiConnected);
        }
    }

    (:background)
    function build(status) {
        if (status == null) {
            return buildFromFlags(false, false);
        }

        return buildFromFlags(status.bluetoothOk == true, status.isWifiConnected());
    }

    (:background)
    function buildFromFlags(bluetoothOk, wifiConnected) {
        return new PublishedValues(bluetoothOk == true, wifiConnected == true);
    }

    (:background)
    function buildCombinedValue(status) {
        return build(status).combined;
    }

    (:background)
    function buildBluetoothValue(status) {
        return build(status).bluetooth;
    }

    (:background)
    function buildWifiValue(status) {
        return build(status).wifi;
    }

    (:background)
    function buildCombinedToken(bluetoothOk, wifiConnected) {
        if ((bluetoothOk != true) && (wifiConnected != true)) {
            return VALUE_OFF;
        }

        return buildBluetoothToken(bluetoothOk) + " " + buildWifiToken(wifiConnected);
    }

    (:background)
    function buildBluetoothToken(bluetoothOk) {
        return (bluetoothOk == true) ? VALUE_BLUETOOTH_ON : VALUE_BLUETOOTH_OFF;
    }

    (:background)
    function buildWifiToken(wifiConnected) {
        return (wifiConnected == true) ? VALUE_WIFI_ON : VALUE_WIFI_OFF;
    }
}
