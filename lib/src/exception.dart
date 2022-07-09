/// A failure has occured while communicating with an IPMI device
class IpmiException implements Exception {
  /// A failure has occured while communicating with an IPMI device
  IpmiException(this.message);

  /// A message to describe the failure that occured
  final String message;

  @override
  String toString() => 'IpmiException($message)';
}
