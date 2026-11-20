# Smart Surveillance mobile app

The Android app for Smart Surveillance: live video from every camera, alerts with snapshots and clips, counts and occupancy, people and number plates, and the setup of sites, connectors and cameras. It talks to the platform's API, or to a simulated site built into the app when no server is configured.

## Layout

```
lib/
  main.dart          starts the app with the backend the build asks for
  app/               bootstrap, router, theme, localisation, the shell and the simulated site
  core/              design system, shared widgets, media, storage and the network layer
    network/api/     the generated API client, never edited by hand
    network/client/  the HTTP client: bearer tokens, one shared refresh, the site header and errors
  features/<domain>/ data, domain and presentation of one business domain
packages/            push_bridge_foss and push_bridge_play, the two push implementations
integration_test/    the emulator tours, on the simulated site and against a real server
test/                unit, widget and golden tests
```

The domains are identity, tenancy, billing, devices, media, analytics, events, alerting, investigation, insights and operations. Each keeps its repository interface in domain/, a simulated implementation (fake_*) and a server implementation (api_*) in data/, and its screens in presentation/. Pairing methods live in lib/features/devices/pairing/methods/<method_id>/, one folder per method, behind the PairingMethod interface; the server's pairing catalog ranks them and the app shows only the methods it returns.

## Run

The app needs Flutter 3.47 and the Android SDK with an emulator or a phone.

```
flutter pub get
flutter run --flavor foss
```

Without defines the app runs on the simulated site. To use a server, run the platform's development kit and point the app at it:

```
flutter run --flavor foss --dart-define=SSS_BACKEND=api
flutter run --flavor foss --dart-define=SSS_BACKEND=api --dart-define=SSS_API_URL=https://surveillance.example.com
```

The default server address, http://10.0.2.2:18700, is the development kit's API as the Android emulator sees the host. Users can change the address on the sign-in screen.

## Configuration

| Define | Default | Meaning |
|---|---|---|
| SSS_BACKEND | fake | fake for the simulated site, api for a server |
| SSS_API_URL | http://10.0.2.2:18700 | Server address used until the user enters another one |
| SCREENSHOTS | false | Makes the integration tests save screenshots |

Release cleartext traffic is allowed only to 10.0.2.2, localhost and 127.0.0.1; a real server needs HTTPS. Debug builds allow any address.

## Flavors

| Flavor | Application id | Push |
|---|---|---|
| foss | uz.smartsurveillance.app | None; alerts arrive while the app runs |
| play | uz.smartsurveillance.app | Firebase Cloud Messaging |

The play flavor needs android/app/src/play/google-services.json and a pubspec_overrides.yaml that points push_bridge at packages/push_bridge_play; the Gradle build fails a play build without the Firebase file. The foss flavor has no Google services at all.

## Build

```
flutter build apk --release --flavor foss
```

Release builds sign with android/key.properties when it exists and with the debug keystore otherwise. key.properties and the keystore stay out of git.

## Generated code

```
scripts/generate-api.sh
dart run build_runner build
flutter gen-l10n
```

scripts/generate-api.sh regenerates lib/core/network/api from packages/contracts/openapi.json with swagger_parser, leaving out the connector device, TV, floor plan and discovery operations, and then runs build_runner. build_runner writes the freezed models, Riverpod providers and typed routes; flutter gen-l10n writes the English, Russian and Uzbek strings from the ARB files in lib/app/l10n.

## Test

```
flutter analyze
flutter test
flutter test --tags golden --update-goldens
```

The golden tests render the main screens in the light and dark themes with alchemist. Their images stay on the machine that made them, because the repository keeps no generated images; run them with --update-goldens once, then without it to compare.

The integration tests run on an emulator through the driver, which saves screenshots under SCREENSHOT_DIR:

```
flutter build apk --profile --flavor foss -t integration_test/app_test.dart --dart-define=SCREENSHOTS=true
SCREENSHOT_DIR=build/screenshots flutter drive --profile --use-application-binary build/app/outputs/flutter-apk/app-foss-profile.apk --driver test_driver/integration_test.dart --target integration_test/app_test.dart
```

integration_test/app_test.dart tours every screen on the simulated site. integration_test/api_test.dart signs up through the mail of the development kit's Mailpit, then signs in as its demo owner and viewer and tours the real site. It takes the demo account domain and password as --dart-define=SSS_TEST_DOMAIN and SSS_TEST_PASSWORD; with SSS_TEST_CAMERA_HOST and SSS_TEST_CAMERA_PASSWORD it also identifies the store camera by address and tests its stream.
