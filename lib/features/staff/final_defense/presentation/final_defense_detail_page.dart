import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/staff/final_defense/application/final_defense_provider.dart';

class FinalDefenseDetailPage extends ConsumerWidget {
  final int eventId;
  final String eventCode;
  const FinalDefenseDetailPage({super.key, required this.eventId, required this.eventCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(finalDefenseDetailProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: Text(eventCode)),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load rooms: $err')),
        data: (data) {
          final rooms = data['data'] as List<dynamic>? ?? [];
          if (rooms.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(finalDefenseDetailProvider(eventId).future),
              child: const Center(child: Text('No rooms found for you in this event.'))
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(finalDefenseDetailProvider(eventId).future),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index] as Map<String, dynamic>;
                return _RoomDetailCard(room: room);
              },
            ),
          );
        },
      ),
    );
  }
}

class _RoomDetailCard extends ConsumerWidget {
  final Map<String, dynamic> room;

  const _RoomDetailCard({required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomId = room['id'] as int;
    final roomDetailAsync = ref.watch(finalDefenseRoomDetailProvider(roomId));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(child: Text(room['room_name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(room['session_time'] ?? 'N/A'),
              ],
            ),
            const Divider(height: 24),
            roomDetailAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (detailData) {
                final roomDetail = detailData['room'] as Map<String, dynamic>? ?? {};
                final moderator = roomDetail['moderator'] as Map<String, dynamic>?;
                final examiners = roomDetail['examiners'] as List<dynamic>? ?? [];
                final applicants = roomDetail['applicants'] as List<dynamic>? ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (moderator != null) ...[
                      Row(
                        children: [
                          Text('${moderator['name'] ?? ''} (${moderator['code'] ?? ''})'),
                          const SizedBox(width: 8),
                          Chip(
                            label: const Text('Moderator'),
                            backgroundColor: Colors.blue.shade100,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    const Text('Examiners:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...examiners.map((e) {
                      final examiner = e as Map<String, dynamic>;
                      return Text('- ${examiner['name'] ?? ''} (${examiner['code'] ?? ''})');
                    }),
                    const SizedBox(height: 8),
                    const Text('Applicants:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...applicants.map((a) {
                      final applicant = a as Map<String, dynamic>;
                      return Text('- ${applicant['student_name'] ?? ''} (${applicant['student_nim'] ?? ''})');
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
