import Toybox.WatchUi;

class ConnectivityDotsDelegate extends WatchUi.BehaviorDelegate {
    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onKey(keyEvent) {
        try {
            if ((keyEvent != null) && (keyEvent.getKey() == WatchUi.KEY_ESC)) {
                return false;
            }
        } catch (e) {
        }

        return refresh();
    }

    function onSelect() {
        return refresh();
    }

    function onNextPage() {
        return refresh();
    }

    function onPreviousPage() {
        return refresh();
    }

    function onMenu() {
        return refresh();
    }

    function onActionMenu() {
        return refresh();
    }

    function onBack() {
        return false;
    }

    function onTap(evt) {
        return refresh();
    }

    function refresh() {
        _view.requestRefresh();
        return true;
    }
}
