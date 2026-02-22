import 'dart:convert';
import 'package:arsys/features/auth/data/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/auth/application/auth_provider.dart';
import 'package:flutter/foundation.dart';

final superviseRepositoryProvider = Provider<SuperviseRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return SuperviseRepository(authService);
});

class SuperviseRepository {
  final AuthService _authService;

  SuperviseRepository(this._authService);

  Future<Map<String, dynamic>> getSupervisedResearches({int page = 1}) async {
    final response = await _authService.get('/staff/supervise?page=$page');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load supervised researches');
    }
  }

  Future<Map<String, dynamic>> getResearchDetail(int researchId) async {
    final response = await _authService.get('/staff/supervise/$researchId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load research detail');
    }
  }

  Future<List<dynamic>> getResearchApprovals(int researchId) async {
    try {
      final response = await _authService.get('/staff/supervise/$researchId/approvals');
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load research approvals: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getResearchApprovals: $e');
      rethrow;
    }
  }

  Future<void> approveResearch(int approvalId) async {
    final response = await _authService.post('/staff/supervise/approvals/$approvalId/approve', {});
    if (response.statusCode != 200) {
      throw Exception('Failed to approve research');
    }
  }
}
