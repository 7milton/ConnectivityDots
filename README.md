# Connectivity Dots

Connectivity Dots is a Garmin Connect IQ watch app that publishes Bluetooth and Wi-Fi status as text Connect IQ Complications. It is a publisher only: it does not draw a watch face, and it does not turn Bluetooth or Wi-Fi on or off.

## What It Does

The app reads the watch connection state, stores the latest snapshot, and publishes compact values that compatible watch faces can display in complication slots. The consuming watch face controls layout, color, font, size, refresh display, and clipping.

The app screen is only a status and manual refresh view. Any button/action or screen tap refreshes the current status; Back/Esc exits.

## Published Complications

The public complication IDs are stable:

| ID | Long label | Short label | Values |
| --- | --- | --- | --- |
| `0` | Connectivity Dots | `LINK` | `BT+ WiFi+`, `BT+ WiFi-`, `BT- WiFi+`, `OFF` |
| `1` | Bluetooth | `BT` | `BT+`, `BT-` |
| `2` | Wi-Fi | `WiFi` | `WiFi+`, `WiFi-` |

Value meaning:

| Value | Meaning |
| --- | --- |
| `BT+` | Phone/Bluetooth connection is OK. |
| `BT-` | Phone/Bluetooth connection is unavailable or problematic. |
| `WiFi+` | Wi-Fi is available/connected. |
| `WiFi-` | Wi-Fi is unavailable, disconnected, unsupported, unknown, or Wi-Fi checks are disabled. |
| `OFF` | Combined field only: both Bluetooth and Wi-Fi are unavailable/problematic. |

Examples:

| Bluetooth | Wi-Fi | Combined | Bluetooth field | Wi-Fi field |
| --- | --- | --- | --- | --- |
| OK | OK | `BT+ WiFi+` | `BT+` | `WiFi+` |
| OK | Problem | `BT+ WiFi-` | `BT+` | `WiFi-` |
| Problem | OK | `BT- WiFi+` | `BT-` | `WiFi+` |
| Problem | Problem | `OFF` | `BT-` | `WiFi-` |

## Compatibility

`manifest.xml` targets watch apps with Connect IQ API `4.2.0` or newer and complication support. The default local build target is `epix2pro51mm`; override it with `CIQ_DEVICE`.

Known to work with the paid/pro version of Watch Face Portal when configured to display Connect IQ Complications. This project is not affiliated with Watch Face Portal, Garmin, or any watch face vendor. Appearance and update presentation depend on the selected watch face.

Devices without Wi-Fi support publish `WiFi-`. If Bluetooth is also disconnected, the combined field publishes `OFF`.

## Build

Install the Garmin Connect IQ SDK, then set environment variables as needed:

```sh
export CIQ_SDK="/path/to/connectiq-sdk"
export CIQ_KEY="/path/to/connectiq-key.der"
export CIQ_DEVICE="epix2pro51mm"
```

Build the app:

```sh
./scripts/build.sh
```

Build for a specific target:

```sh
CIQ_DEVICE="fenix7" ./scripts/build.sh
```

If `CIQ_KEY` is not set, the scripts create a local development key under the ignored `build/` directory.

## Run In Simulator

```sh
./scripts/run-publisher.sh
```

Restart the simulator before running:

```sh
CIQ_RESTART_SIMULATOR=1 ./scripts/run-publisher.sh
```

## Tests

Unit tests cover the published values for Bluetooth and Wi-Fi combinations, including unsupported/off/unknown Wi-Fi states.

```sh
./scripts/test.sh
```

The script builds with `monkeyc -t`, starts the simulator if needed, and runs tests with `monkeydo ... -t`.
Set `CIQ_TEST_TIMEOUT_SECONDS` if the simulator needs more time to start or shut down.

## Physical Watch Install

1. Build for the product ID that matches the watch.
2. Sideload the generated `.prg` to `GARMIN/APPS` or install through your Connect IQ developer flow.
3. Launch Connectivity Dots once to refresh values and register the background refresh event.
4. Open a compatible watch face that can display Connect IQ Complications.
5. Add `Connectivity Dots`, `Bluetooth`, and/or `Wi-Fi` to complication slots.
6. Disconnect/reconnect the phone to validate `BT+` and `BT-`.
7. Test unavailable Wi-Fi or set `wifiCheckMode=off` to validate `WiFi-` and combined `OFF`.

## Settings

| Property | Default | Notes |
| --- | --- | --- |
| `wifiCheckMode` | `precise` | Valid values: `precise`, `simple`, `off`. |
| `refreshIntervalMinutes` | `15` | Minimum enforced in code: 5 minutes. |
| `showCombined` | `true` | Publishes complication ID `0`. |
| `showBluetooth` | `true` | Publishes complication ID `1`. |
| `showWifi` | `true` | Publishes complication ID `2`. |
| `debugMode` | `false` | Enables extra diagnostic log lines with the `[ConnectivityDots]` prefix. |

`wifiCheckMode=precise` uses `Communications.checkWifiConnection(callback)` when available and falls back to simple state reading. `wifiCheckMode=simple` reads `System.getDeviceSettings().connectionInfo[:wifi].state`. `wifiCheckMode=off` treats Wi-Fi as `WiFi-`.

## Privacy

Connectivity Dots does not collect, transmit, or store personal data outside the watch. It stores only the latest local connectivity snapshot and the compact complication values in Connect IQ app storage.

## Limitations

- The app cannot enable, disable, repair, or pair Bluetooth or Wi-Fi.
- Background refresh timing is limited by Connect IQ scheduling and is never scheduled below 5 minutes.
- Watch faces may truncate or restyle text values.
- Wi-Fi availability can be unavailable or unknown on some devices; those states publish `WiFi-`.

## Release Checklist

Run the release check before publishing or tagging:

```sh
./scripts/release-check.sh
```

Optional no-Wi-Fi validation:

```sh
CIQ_VALIDATE_NOWIFI=1 ./scripts/release-check.sh
```

The release check runs the private-data scan, unit tests, default device build, optional no-Wi-Fi build, and `.iq` export.
