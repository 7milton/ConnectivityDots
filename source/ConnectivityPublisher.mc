import Toybox.Complications;

(:background)
module ConnectivityPublisher {
    const INDEX_COMBINED = 0;
    const INDEX_BLUETOOTH = 1;
    const INDEX_WIFI = 2;

    const SHORT_COMBINED = "LINK";
    const SHORT_BLUETOOTH = "BT";
    const SHORT_WIFI = "WiFi";

    (:background)
    function publishAll(status) {
        var values = ConnectivityValues.build(status);
        Settings.log("publish combined=" + values.combined + " bt=" + values.bluetooth + " wifi=" + values.wifi);

        ConnectivityStore.writeSnapshot(status, values);
        publishConfigured(values);
    }

    (:background)
    function publishCombined(status) {
        publishCombinedValue(buildCombinedValue(status));
    }

    (:background)
    function publishBluetooth(status) {
        publishBluetoothValue(buildBluetoothValue(status));
    }

    (:background)
    function publishWifi(status) {
        publishWifiValue(buildWifiValue(status));
    }

    (:background)
    function buildCombinedValue(status) {
        return ConnectivityValues.buildCombinedValue(status);
    }

    (:background)
    function buildBluetoothValue(status) {
        return ConnectivityValues.buildBluetoothValue(status);
    }

    (:background)
    function buildWifiValue(status) {
        return ConnectivityValues.buildWifiValue(status);
    }

    (:background)
    function publishConfigured(values) {
        if (Settings.showCombined()) {
            publishCombinedValue(values.combined);
        }

        if (Settings.showBluetooth()) {
            publishBluetoothValue(values.bluetooth);
        }

        if (Settings.showWifi()) {
            publishWifiValue(values.wifi);
        }
    }

    (:background)
    function publishCombinedValue(value) {
        update(INDEX_COMBINED, SHORT_COMBINED, value);
    }

    (:background)
    function publishBluetoothValue(value) {
        update(INDEX_BLUETOOTH, SHORT_BLUETOOTH, value);
    }

    (:background)
    function publishWifiValue(value) {
        update(INDEX_WIFI, SHORT_WIFI, value);
    }

    (:background)
    function update(index, shortLabel, value) {
        try {
            Complications.updateComplication(index, {
                :shortLabel => shortLabel,
                :value => value
            });
        } catch (e) {
            Settings.debug("Complication update failed: " + index.toString());
        }
    }
}
