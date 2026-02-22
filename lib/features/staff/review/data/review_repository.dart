import 'dart:convert';
import 'package:arsys/features/auth/data/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/auth/application/auth_provider.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ReviewRepository(authService);
});

class ReviewRepository {
  final AuthService _authService;

  ReviewRepository(this._authService);

  Future<Map<String, dynamic>> getReviews({int page = 1}) async {
    final response = await _authService.get('/staff/review?page=$page');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<Map<String, dynamic>> getReviewDetail(int researchId) async {
    final response = await _authService.get('/staff/review/$researchId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load review detail');
    }
  }

  Future<void> submitReview(int researchId, String decision) async {
    final response = await _authService.post(
      '/staff/review/$researchId/submit',
      {'decision': decision},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to submit review');
    }
  }
}
