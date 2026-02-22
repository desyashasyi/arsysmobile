import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/staff/pre_defense/application/pre_defense_provider.dart';
import 'package:arsys/features/staff/pre_defense/data/pre_defense_repository.dart';

class ApplicantDetailPage extends ConsumerWidget {
  final int participantId;

  const ApplicantDetailPage({super.key, required this.participantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defenseDetailAsync = ref.watch(preDefenseParticipantDetailProvider(participantId));

    return Scaffold(
      appBar: AppBar(title: const Text('Applicant Detail')),
      body: defenseDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          final participant = data['participant'];
          final research = participant['research'];
          final student = research['student'];
          final supervisors = (research['supervisor'] as List?)?.where((s) => s != null).toList() ?? [];
          final examiners = (participant['defense_examiner'] as List?)?.where((e) => e != null).toList() ?? [];
          
          final isSupervisor = data['is_supervisor'] as bool? ?? false;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(preDefenseParticipantDetailProvider(participantId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Student Information'),
                  _buildInfoCard(
                    participant['room_name'] ?? 'N/A',
                    participant['session_time'] ?? 'N/A',
                    student?['program_code'] ?? 'N/A',
                    student?['number'] ?? 'N/A',
                    '${student?['first_name'] ?? ''} ${student?['last_name'] ?? ''}',
                    (research?['title'] ?? 'No Title').toUpperCase(),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Supervisors'),
                  ...supervisors.map(
                    (s) => _buildSupervisorTile(
                      s['code'] ?? 'N/A',
                      s['name'] ?? 'Unknown Supervisor'
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Examiners'),
                  ...examiners.map(
                    (e) => _buildExaminerTile(
                      context,
                      ref,
                      e['id'],
                      e['code'] ?? 'N/A',
                      e['name'] ?? 'Unknown Examiner',
                      e['is_present'] as bool? ?? false,
                      isSupervisor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(String room, String session, String program, String nim, String name, String title) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(
                  room,
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
                  session,
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
              '$program . $nim',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildSupervisorTile(String code, String name) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text(name),
        subtitle: Text(code),
      ),
    );
  }

  Widget _buildExaminerTile(
    BuildContext context,
    WidgetRef ref,
    int examinerId,
    String code,
    String name,
    bool isPresent,
    bool isSupervisor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text(name),
        subtitle: Text(code),
        trailing: isSupervisor
            ? Checkbox(
                value: isPresent,
                onChanged: (bool? value) async {
                  try {
                    await ref.read(preDefenseRepositoryProvider).toggleExaminerPresence(examinerId);
                    ref.invalidate(preDefenseParticipantDetailProvider(participantId));
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update presence: $e')),
                      );
                    }
                  }
                },
              )
            : Icon(
                Icons.check_circle,
                color: isPresent ? Colors.green : Colors.grey,
              ),
      ),
    );
  }
}
