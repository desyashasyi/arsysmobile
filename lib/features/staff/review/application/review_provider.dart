import 'package:arsys/features/staff/review/data/review_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewListProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, page) async {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.getReviews(page: page);
});

final reviewDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, researchId) async {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.getReviewDetail(researchId);
});
