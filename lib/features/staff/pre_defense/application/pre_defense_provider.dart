import 'package:arsys/features/staff/pre_defense/data/pre_defense_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final preDefenseEventsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, page) async {
  final repository = ref.watch(preDefenseRepositoryProvider);
  return repository.getEvents(page: page);
});

final preDefenseParticipantsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, eventId) async {
  final repository = ref.watch(preDefenseRepositoryProvider);
  return repository.getParticipants(eventId);
});

final preDefenseParticipantDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, participantId) async {
  final repository = ref.watch(preDefenseRepositoryProvider);
  return repository.getParticipantDetails(participantId);
});

final scoreGuideProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repository = ref.watch(preDefenseRepositoryProvider);
  return repository.getScoreGuide();
});
