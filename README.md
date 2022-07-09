
## dart_ipmi

A Dart library for controlling IPMI devices via a network

Note: This library has been tested against the IPMI module in a Gigabyte WRX80-SU8-IPMI motherboard. It may or may not work or perform as expected on other systems.

## Features

- [x] Sign In
- [x] Sign Out
- [x] Power On
- [x] Power Off
- [x] Hard Reset
- [x] Power Cycle
- [x] Orderly Shutdown
- [x] Get Power Status

## Usage

```dart
import 'package:dart_ipmi/dart_ipmi.dart';

Future<void> main() async {
  final ipmi = IPMI(
    '192.168.1.30', // IP Address of the IPMI host
    username: 'admin', // Username of IPMI user
    password: 'password', // Password for IPMI user
    secured: true, // Use https to connect
    verifyCertificates: false, // Ignore certificate errors
  );

  /// Get an active session cookie
  await ipmi.refreshAuthToken();

  /// Turn on the system
  await ipmi.powerAction(PowerAction.on);
}
```

## Additional information

Issues and feature requests can be submitted [here](https://github.com/point-source/dart_ipmi).
