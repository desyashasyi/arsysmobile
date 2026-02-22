import 'package:arsys/features/staff/supervise/data/supervise_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supervisedResearchProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, page) async {
  final repository = ref.watch(superviseRepositoryProvider);
  return repository.getSupervisedResearches(page: page);
});

final researchDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, researchId) async {
  final repository = ref.watch(superviseRepositoryProvider);
  return repository.getResearchDetail(researchId);
});

final researchApprovalsProvider = FutureProvider.autoDispose.family<List<dynamic>, int>((ref, researchId) async {
  final repository = ref.watch(superviseRepositoryProvider);
  return repository.getResearchApprovals(researchId);
});
