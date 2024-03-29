import 'dart:convert';

import 'package:http/http.dart' show Response;
import 'package:requests/requests.dart';

import 'package:dart_ipmi/src/exception.dart';

/// Main IPMI class which can control IPMI hosts
class IPMI {
  /// Creates an instance of IPMI to control a single IPMI host
  IPMI(
    this.ipAddress, {
    this.port,
    required this.username,
    required this.password,

    /// Use https (true) instead of http (false)
    this.secured = false,

    /// Verify https certificates
    this.verifyCertificates = true,
  });

  /// IP Address of the IPMI host
  final String ipAddress;

  /// Network port to use to communicate with the host
  ///
  /// Defaults to 80 for http and 443 for https
  final int? port;

  /// Username of an account with permission to access the IPMI
  final String username;

  /// Password for the IPMI user
  final String password;

  /// Use https (true) instead of http (false)
  final bool secured;

  /// Verify https certificates
  final bool verifyCertificates;

  String _csrfToken = '';

  String get _host {
    String host = secured ? 'https://$ipAddress' : 'http://$ipAddress';
    if (port != null) host = '$host:$port';

    return host;
  }

  Future<Response> _execute<T>(Future<Response> Function() request) async {
    final r = await request();
    if (r.hasError && r.body.contains('Invalid Authentication')) {
      await refreshAuthToken();

      return await request();
    }

    return r;
  }

  /// Login to the IPMI host with the previously supplied username
  /// and password. Returns true for success, false for failure
  ///
  /// This will fetch and store the authentication cookie as well as the
  /// CSRF token to be used for future requests
  ///
  /// You may call this additional times if you need to refresh the token(s)
  /// once they expire
  Future<void> refreshAuthToken() async {
    final r = await Requests.post(
      '$_host/api/session',
      body: {
        'username': username,
        'password': password,
      },
      bodyEncoding: RequestBodyEncoding.FormURLEncoded,
      persistCookies: true,
      verify: verifyCertificates,
    );
    if (!r.success) throw IpmiException(r.body);

    final json = jsonDecode(r.body);
    _csrfToken = json['CSRFToken'];
  }

  /// Signs the user out of the IPMI device and clears stored tokens
  Future<void> signOut() async {
    final r = await _execute(() => Requests.delete(
          '$_host/api/session',
          headers: {'X-CSRFTOKEN': _csrfToken},
          verify: verifyCertificates,
        ));
    if (!r.success) throw IpmiException(r.body);

    Requests.clearStoredCookies(ipAddress);
    _csrfToken = '';
  }

  /// Command the IPMI device to perform the supplied [PowerAction]
  ///
  /// Returns true for success, false for failure
  Future<void> powerAction(PowerAction action) async {
    final r = await _execute(() => Requests.post(
          '$_host/api/actions/power',
          headers: {'X-CSRFTOKEN': _csrfToken},
          json: {'power_command': action.code},
          verify: verifyCertificates,
        ));

    if (!r.success) throw IpmiException(r.body);
  }

  /// Gets the power state of the computer
  Future<PowerState> getPowerState() async {
    final r = await _execute(() => Requests.get(
          '$_host/api/chassis-status',
          headers: {'X-CSRFTOKEN': _csrfToken},
          verify: verifyCertificates,
        ));

    if (!r.success) throw IpmiException(r.body);

    final status = r.json()['power_status'];
    switch (status) {
      case 0:
        return PowerState.off;
      case 1:
        return PowerState.on;
      default:
        return PowerState.unknown;
    }
  }
}

/// Power action to perform
enum PowerAction {
  /// Immediately halt the system. Equivalent to holding the power button.
  offImmediate(0),

  /// Turn on the system
  on(1),

  /// Power cycle the system. Equivalent to holding the power button and then
  /// turning the system back on.
  cycle(2),

  /// Resets the system without fully powering off. This is equivalent to
  /// pressing the onboard reset button.
  reset(3),

  /// Requests that the kernel or OS powers the system down cleanly.
  offOrderly(5);

  /// Power action to perform
  const PowerAction(this.code);

  /// Code to send to the IPMI system to indicate the action to take
  final int code;
}

/// Power status of the computer
enum PowerState {
  /// Computer is on
  on,

  /// Computer is off
  off,

  /// Computer power state could not be determined
  unknown
}
