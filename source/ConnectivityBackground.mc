import Toybox.Background;
import Toybox.System;
import Toybox.Time;

(:background)
module ConnectivityBackground {
    const MIN_INTERVAL_SECONDS = 300;

    (:background)
    function registerTemporalEventIfNeeded() {
        try {
            if (Background.getTemporalEventRegisteredTime() == null) {
                registerNextTemporalEvent();
            }
        } catch (e) {
            registerNextTemporalEvent();
        }
    }

    (:background)
    function registerNextTemporalEvent() {
        var minTime = buildMinimumNextTime();
        var nextTime = safeNextTime();

        if (nextTime.value() < minTime.value()) {
            nextTime = minTime;
        }

        registerTemporalEvent(nextTime, minTime);
    }

    (:background)
    function safeNextTime() {
        var nextTime = Time.now().add(new Time.Duration(refreshIntervalSeconds()));
        var lastSafeTime = lastEventSafeTime();

        if ((lastSafeTime != null) && (nextTime.value() < lastSafeTime.value())) {
            return lastSafeTime;
        }

        return nextTime;
    }

    (:background)
    function refreshIntervalSeconds() {
        var seconds = Settings.refreshIntervalMinutes() * 60;
        if (seconds < MIN_INTERVAL_SECONDS) {
            return MIN_INTERVAL_SECONDS;
        }

        return seconds;
    }

    (:background)
    function buildMinimumNextTime() {
        return Time.now().add(new Time.Duration(MIN_INTERVAL_SECONDS));
    }

    (:background)
    function lastEventSafeTime() {
        try {
            var lastTime = Background.getLastTemporalEventTime();
            if (lastTime != null) {
                return lastTime.add(new Time.Duration(MIN_INTERVAL_SECONDS));
            }
        } catch (e) {
        }

        return null;
    }

    (:background)
    function registerTemporalEvent(nextTime, fallbackTime) {
        try {
            Background.registerForTemporalEvent(nextTime);
            Settings.debug("background temporal event scheduled");
        } catch (e) {
            registerFallbackTemporalEvent(fallbackTime);
        }
    }

    (:background)
    function registerFallbackTemporalEvent(fallbackTime) {
        try {
            Background.registerForTemporalEvent(fallbackTime);
            Settings.debug("background temporal event scheduled at minimum");
        } catch (e) {
            Settings.debug("Temporal event registration failed");
        }
    }
}

(:background)
class ConnectivityDotsServiceDelegate extends System.ServiceDelegate {
    var _exited;

    function initialize() {
        ServiceDelegate.initialize();
        _exited = false;
    }

    function onTemporalEvent() {
        _exited = false;
        Settings.log("background temporal event");

        try {
            ConnectivityStatus.read(method(:onStatusReady));
        } catch (e) {
            Settings.debug("Background status read failed");
            safeScheduleAndExit();
        }
    }

    function onStatusReady(status) {
        try {
            Settings.log("background status ready");
            publishStatus(status);
            ConnectivityBackground.registerNextTemporalEvent();
        } catch (e) {
            Settings.debug("Background publish failed");
        }

        safeExit();
    }

    function publishStatus(status) {
        if (status == null) {
            return;
        }

        ConnectivityPublisher.publishAll(status);
    }

    function safeScheduleAndExit() {
        try {
            ConnectivityBackground.registerNextTemporalEvent();
        } catch (e) {
        }

        safeExit();
    }

    function safeExit() {
        if (_exited) {
            return;
        }

        _exited = true;
        try {
            Background.exit(null);
        } catch (e) {
            try {
                Background.exit(null);
            } catch (ignored) {
            }
        }
    }
}
