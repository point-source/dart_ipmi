import 'package:dart_ipmi/dart_ipmi.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final ipmi = IPMI('127.0.0.1', username: '', password: '');

    test('First Test', () {
      expect(ipmi, isA<IPMI>());
    });
  });
}
