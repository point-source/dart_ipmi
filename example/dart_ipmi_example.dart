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
