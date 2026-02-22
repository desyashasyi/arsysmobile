import 'dart:convert';
import 'package:arsys/features/auth/data/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/auth/application/auth_provider.dart';

final finalDefenseRepositoryProvider = Provider<FinalDefenseRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return FinalDefenseRepository(authService);
});

class FinalDefenseRepository {
  final AuthService _authService;

  FinalDefenseRepository(this._authService);

  Future<Map<String, dynamic>> getEvents({int page = 1}) async {
    final response = await _authService.get('/staff/final-defense?page=$page');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load final-defense events');
    }
  }

  Future<Map<String, dynamic>> getDetail(int eventId) async {
    final response = await _authService.get('/staff/final-defense/$eventId/detail');
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['success'] == true) {
        return body['data'] as Map<String, dynamic>;
      } else {
        throw Exception(body['message'] ?? 'Failed to load event detail');
      }
    } else {
      throw Exception('Failed to load event detail (${response.statusCode})');
    }
  }
}
