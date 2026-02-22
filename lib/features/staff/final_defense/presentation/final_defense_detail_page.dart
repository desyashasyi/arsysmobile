import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/staff/final_defense/application/final_defense_provider.dart';

class FinalDefenseDetailPage extends ConsumerWidget {
  final int eventId;
  const FinalDefenseDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(finalDefenseDetailProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Final Defense Detail')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load detail: $err')),
        data: (data) {
          final rooms = data['rooms'] as List<dynamic>? ?? [];
          return RefreshIndicator(
            onRefresh: () => ref.refresh(finalDefenseDetailProvider(eventId).future),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event: ${(data['id'] ?? '').toString().toUpperCase()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...rooms.map((r) {
                    final room = r as Map<String, dynamic>;
                    final session = room['session'];
                    final space = room['space'];
                    final moderator = room['moderator'];
                    final examiners = room['examiners'] as List<dynamic>? ?? [];
                    final participants = room['participants'] as List<dynamic>? ?? [];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Room ${room['id'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (session != null) Text('Session: ${session['name'] ?? ''}'),
                            if (space != null) Text('Space: ${space['name'] ?? ''}'),
                            if (moderator != null) Text('Moderator: ${(moderator['name'] ?? '').toUpperCase()}'),
                            const SizedBox(height: 8),
                            const Text('Examiners:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...examiners.map((e) => Text('- ${(e['name'] ?? '').toUpperCase()}')),
                            const SizedBox(height: 8),
                            const Text('Participants:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...participants.map((p) => Text('- ${p['student'] != null ? (p['student']['number'] ?? '') + ' ' + (p['student']['first_name'] ?? '').toUpperCase() + ' ' + (p['student']['last_name'] ?? '').toUpperCase() : 'Participant ${p['id'] ?? ''}'}')),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
