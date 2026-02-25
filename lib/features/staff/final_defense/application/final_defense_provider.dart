import 'package:arsys/features/staff/final_defense/data/final_defense_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final finalDefenseEventsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, page) async {
  final repository = ref.watch(finalDefenseRepositoryProvider);
  return repository.getEvents(page: page);
});

final finalDefenseDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, eventId) async {
  final repository = ref.watch(finalDefenseRepositoryProvider);
  return repository.getRooms(eventId);
});

final finalDefenseRoomDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, roomId) async {
  final repository = ref.watch(finalDefenseRepositoryProvider);
  return repository.getRoomDetail(roomId);
});

final finalDefenseScoreGuideProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repository = ref.watch(finalDefenseRepositoryProvider);
  return repository.getScoreGuide();
});
