import 'package:arsys/features/auth/application/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final networkClientProvider = Provider<NetworkClient>((ref) {
  return NetworkClient(ref);
});

class NetworkClient {
  final Ref _ref;

  final String _baseUrl = 'http://192.168.100.26/api';
  //final String _baseUrl = 'http://127.0.0.1:8000/api';

  NetworkClient(this._ref);

  Future<http.Response> get(String url) async {
    final token = _ref.read(authTokenProvider);
    return http.get(
      Uri.parse('$_baseUrl$url'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> post(String url, {Object? body}) async {
    final token = _ref.read(authTokenProvider);
    return http.post(
      Uri.parse('$_baseUrl$url'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
  }
}
