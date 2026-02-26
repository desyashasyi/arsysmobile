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

  Future<Map<String, dynamic>> getRooms(int eventId) async {
    final response = await _authService.get('/staff/final-defense/$eventId/rooms');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load final-defense rooms');
    }
  }

  Future<void> switchModerator(int roomId, int newModeratorId) async {
    final response = await _authService.post(
      '/staff/final-defense/room/$roomId/switch-moderator',
      {'new_moderator_id': newModeratorId},
    );
    if (response.statusCode != 200) {
      try {
        final error = json.decode(response.body);
        final message = error['message'] ?? 'An unknown error occurred.';
        if (error.containsKey('errors')) {
          final errors = error['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first as List<dynamic>;
          throw Exception(firstError.first ?? message);
        }
        throw Exception(message);
      } catch (e) {
        throw Exception('Failed to switch moderator. Please try again.');
      }
    }
  }

  Future<void> toggleExaminerPresence(int roomId, int examinerId) async {
    final response = await _authService.post(
      '/staff/final-defense/room/$roomId/examiner/$examinerId/presence',
      {},
    );
    if (response.statusCode != 200) {
      try {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update presence');
      } catch (e) {
        throw Exception('Failed to update presence. Invalid error format.');
      }
    }
  }

  Future<void> submitScore(int applicantId, int score, String? remark) async {
    final response = await _authService.post(
      '/final-defense/applicant/$applicantId/score',
      {
        'score': score,
        'remark': remark,
      },
    );
    if (response.statusCode != 200) {
      try {
        final error = json.decode(response.body);
        final message = error['message'] ?? 'An unknown error occurred.';
        if (error.containsKey('errors')) {
          final errors = error['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first as List<dynamic>;
          throw Exception(firstError.first ?? message);
        }
        throw Exception(message);
      } catch (e) {
        throw Exception('Failed to submit score. Please try again.');
      }
    }
  }

  Future<Map<String, dynamic>> getRoomDetail(int roomId) async {
    final response = await _authService.get('/staff/final-defense/room/$roomId');
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['success'] == true) {
        return body['data'] as Map<String, dynamic>;
      } else {
        throw Exception(body['message'] ?? 'Failed to load room detail');
      }
    } else {
      throw Exception('Failed to load room detail (${response.statusCode})');
    }
  }

  Future<List<dynamic>> getScoreGuide() async {
    final response = await _authService.get('/staff/final-defense/score-guide');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load score guide');
    }
  }
}
