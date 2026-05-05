import Toybox.Application;
import Toybox.WatchUi;

(:background)
class ConnectivityDotsApp extends Application.AppBase {
    var _view;

    function initialize() {
        AppBase.initialize();
        _view = null;
    }

    function onStart(state) {
        Settings.log("onStart");
        ConnectivityBackground.registerTemporalEventIfNeeded();
        refreshNow(null);
    }

    function onStop(state) {
    }

    function onAppInstall() {
        Settings.log("onAppInstall");
        ConnectivityBackground.registerTemporalEventIfNeeded();
    }

    function onAppUpdate() {
        Settings.log("onAppUpdate");
        ConnectivityBackground.registerTemporalEventIfNeeded();
    }

    function getInitialView() {
        _view = new ConnectivityDotsView();
        return [_view, new ConnectivityDotsDelegate(_view)];
    }

    function getServiceDelegate() {
        return [new ConnectivityDotsServiceDelegate()];
    }

    function onBackgroundData(data) {
        requestViewUpdate();
    }

    function onStorageChanged() {
        requestViewUpdate();
    }

    function refreshNow(view) {
        Settings.log("manual refresh start");
        beginRefresh(view);

        try {
            ConnectivityStatus.read(method(:onStatusReady));
        } catch (e) {
            Settings.debug("Manual status read failed");
            finishRefresh();
        }
    }

    function onStatusReady(status) {
        try {
            Settings.log("status ready " + status.summary());
            publishStatus(status);
            ConnectivityBackground.registerTemporalEventIfNeeded();
        } catch (e) {
            Settings.debug("Manual publish failed");
        }

        finishRefresh();
    }

    function beginRefresh(view) {
        if (view == null) {
            return;
        }

        _view = view;
        _view.setRefreshing(true);
        requestViewUpdate();
    }

    function finishRefresh() {
        if (_view != null) {
            _view.setRefreshing(false);
        }

        requestViewUpdate();
    }

    function publishStatus(status) {
        if (status == null) {
            return;
        }

        ConnectivityPublisher.publishAll(status);
    }

    function requestViewUpdate() {
        if (_view != null) {
            WatchUi.requestUpdate();
        }
    }
}

function getApp() {
    return Application.getApp() as ConnectivityDotsApp;
}
