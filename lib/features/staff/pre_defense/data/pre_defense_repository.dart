import 'dart:convert';
import 'package:arsys/features/auth/data/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/auth/application/auth_provider.dart';

final preDefenseRepositoryProvider = Provider<PreDefenseRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return PreDefenseRepository(authService);
});

class PreDefenseRepository {
  final AuthService _authService;

  PreDefenseRepository(this._authService);

  Future<Map<String, dynamic>> getEvents({int page = 1}) async {
    final response = await _authService.get('/staff/pre-defense?page=$page');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load pre-defense events');
    }
  }

  Future<Map<String, dynamic>> getParticipants(int eventId) async {
    final response = await _authService.get('/staff/pre-defense/$eventId/participants');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load event participants');
    }
  }

  Future<Map<String, dynamic>> getParticipantDetails(int participantId) async {
    final response = await _authService.get('/staff/pre-defense/participant/$participantId');
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['success'] == true) {
        return body['data'];
      } else {
        throw Exception(body['message'] ?? 'Failed to load participant details');
      }
    } else {
      throw Exception('Failed to load participant details');
    }
  }

  Future<void> toggleExaminerPresence(int examinerId) async {
    final response = await _authService.post('/staff/pre-defense/examiner/$examinerId/presence', {});
    if (response.statusCode != 200) {
      throw Exception('Failed to update presence');
    }
  }

  Future<List<dynamic>> searchStaff(String query) async {
    final response = await _authService.get('/staff/pre-defense/staff/search?query=$query');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search staff');
    }
  }

  Future<void> addExaminer(int participantId, int staffId) async {
    final response = await _authService.post('/staff/pre-defense/participant/$participantId/add-examiner', {'staff_id': staffId});
    if (response.statusCode != 200) {
      throw Exception('Failed to add examiner');
    }
  }
}
