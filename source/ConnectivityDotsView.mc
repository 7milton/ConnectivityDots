import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class ConnectivityDotsView extends WatchUi.View {
    var _refreshing;

    function initialize() {
        View.initialize();
        _refreshing = false;
    }

    function setRefreshing(value) {
        _refreshing = value;
    }

    function requestRefresh() {
        getApp().refreshNow(self);
    }

    function onLayout(dc) {
    }

    function onShow() {
    }

    function onUpdate(dc) {
        var height = dc.getHeight();
        var textFont = Graphics.FONT_XTINY;
        var lineHeight = dc.getFontHeight(textFont) + 1;
        var y = 30;

        clear(dc);
        y = drawTitle(dc, y);
        y = drawStatusRows(dc, y, lineHeight);
        y = drawRefreshState(dc, y, lineHeight);

        drawLine(dc, y, "Monitors Bluetooth and Wi-Fi");
        drawSmallScreenHint(dc, height, lineHeight);
    }

    function onHide() {
    }

    function clear(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    }

    function drawTitle(dc, y) {
        var titleFont = Graphics.FONT_TINY;
        dc.drawText(dc.getWidth() / 2, y, titleFont, "Connectivity Dots", Graphics.TEXT_JUSTIFY_CENTER);
        return y + dc.getFontHeight(titleFont) + 2;
    }

    function drawStatusRows(dc, y, lineHeight) {
        y = drawRow(dc, y, lineHeight, "Combined", combinedValueText());
        y = drawRow(dc, y, lineHeight, "Bluetooth", bluetoothStatusText());
        y = drawRow(dc, y, lineHeight, "Wi-Fi", wifiStatusText());
        y = drawRow(dc, y, lineHeight, "Last", checkedAtText());
        return y + 2;
    }

    function drawRefreshState(dc, y, lineHeight) {
        if (!_refreshing) {
            return y;
        }

        drawLine(dc, y, "Refreshing...");
        return y + lineHeight;
    }

    function drawSmallScreenHint(dc, height, lineHeight) {
        if (height < 220) {
            drawLine(dc, height - lineHeight - 2, "Select/tap: refresh");
        }
    }

    function drawRow(dc, y, lineHeight, label, value) {
        drawLine(dc, y, label + ": " + value);
        return y + lineHeight;
    }

    function drawLine(dc, y, text) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, y, Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function combinedValueText() {
        return ConnectivityStore.readString(ConnectivityStore.KEY_LAST_COMBINED_VALUE, "-");
    }

    function bluetoothStatusText() {
        var bluetoothOk = ConnectivityStore.readBoolean(ConnectivityStore.KEY_LAST_BLUETOOTH_OK);
        if (bluetoothOk == null) {
            return "-";
        }

        return bluetoothOk ? "connected" : "not connected";
    }

    function wifiStatusText() {
        var wifiSupported = ConnectivityStore.readBoolean(ConnectivityStore.KEY_LAST_WIFI_SUPPORTED);
        var wifiOk = ConnectivityStore.readBoolean(ConnectivityStore.KEY_LAST_WIFI_OK);

        if ((wifiSupported == null) && (wifiOk == null)) {
            return "-";
        }

        if ((wifiSupported == true) && (wifiOk == true)) {
            return "connected";
        }

        return "not connected";
    }

    function checkedAtText() {
        try {
            var timestamp = ConnectivityStore.readValue(ConnectivityStore.KEY_LAST_CHECKED_AT);
            if (timestamp != null) {
                var info = Gregorian.info(new Time.Moment(timestamp), Time.FORMAT_SHORT);
                return Lang.format("$1$/$2$ $3$:$4$", [
                    info.month.format("%02d"),
                    info.day.format("%02d"),
                    info.hour.format("%02d"),
                    info.min.format("%02d")
                ]);
            }
        } catch (e) {
        }

        return "-";
    }
}
