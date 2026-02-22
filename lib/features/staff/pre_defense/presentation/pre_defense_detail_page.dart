import 'package:arsys/features/staff/pre_defense/presentation/applicant_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/staff/pre_defense/application/pre_defense_provider.dart';

class PreDefenseDetailPage extends ConsumerWidget {
  final int eventId;

  const PreDefenseDetailPage({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(preDefenseParticipantsProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Pre Defense Participants')),
      body: participantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $err'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () =>
                      ref.refresh(preDefenseParticipantsProvider(eventId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (participantData) {
          final List<dynamic> participants = participantData['data'];

          if (participants.isEmpty) {
            return RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(preDefenseParticipantsProvider(eventId).future),
                child: const Center(
                    child: Text('No participants found for you in this event.')));
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(preDefenseParticipantsProvider(eventId).future),
            child: ListView.builder(
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 12, color: Colors.blueGrey),
                            const SizedBox(width: 4),
                            Text(
                              participant['room_name'] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, size: 12, color: Colors.blueGrey),
                            const SizedBox(width: 4),
                            Text(
                              participant['session_time'] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${participant['program_code']} . ${participant['student_nim']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            participant['student_name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (participant['research_title'] ?? 'No Title').toUpperCase(),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApplicantDetailPage(participantId: participant['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
