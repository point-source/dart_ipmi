import 'package:dart_ipmi/dart_ipmi.dart';

Future<void> main() async {
  final ipmi = IPMI(
    '37.101.8.122', // IP Address of the IPMI host
    username: 'admin', // Username of IPMI user
    password: 'boxx-B195016', // Password for IPMI user
    secured: true, // Use https to connect
    verifyCertificates: false, // Ignore certificate errors
  );

  /// Get an active session cookie
  await ipmi.refreshAuthToken();

  /// Turn on the system
  var p = await ipmi.getPowerState();

  print(p);
}
