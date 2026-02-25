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
          final allRooms = data['data'] as List<dynamic>? ?? [];
          if (allRooms.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(finalDefenseDetailProvider(eventId).future),
              child: const Center(child: Text('No rooms found for you in this event.'))
            );
          }

          final examinerRooms = allRooms.where((r) => r['is_examiner_or_moderator'] == true).toList();
          final supervisorRooms = allRooms.where((r) => (r['supervised_applicant_ids'] as List).isNotEmpty).toList();

          return RefreshIndicator(
            onRefresh: () => ref.refresh(finalDefenseDetailProvider(eventId).future),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (examinerRooms.isNotEmpty)
                  ...examinerRooms.map((room) => _ExaminerRoomCard(room: room as Map<String, dynamic>)),
                if (supervisorRooms.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text("Supervised Students", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...supervisorRooms.map((room) => _SupervisorRoomCard(room: room as Map<String, dynamic>)),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExaminerRoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  const _ExaminerRoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final moderator = room['moderator'] as Map<String, dynamic>?;
    final examiners = room['examiners'] as List<dynamic>? ?? [];
    final applicants = room['applicants'] as List<dynamic>? ?? [];
    final supervisedApplicantIds = (room['supervised_applicant_ids'] as List).cast<int>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
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
            ]
          ),
          _buildCard(
            title: 'Examiners and Moderator',
            children: [
              if (moderator != null) ...[
                _buildPersonRow(
                  name: '${moderator['name']} (${moderator['code']})',
                  isModerator: true,
                ),
                const Divider(),
              ],
              ...examiners.map((e) {
                final examiner = e as Map<String, dynamic>;
                return _buildPersonRow(
                  name: '${examiner['name']} (${examiner['code']})',
                  isPresent: examiner['is_present'] ?? false,
                );
              }).toList(),
            ]
          ),
          _buildCard(
            title: 'Participants',
            children: applicants.map((a) {
              final applicant = a as Map<String, dynamic>;
              final applicantId = applicant['id'] as int;
              final bool isSupervised = supervisedApplicantIds.contains(applicantId);

              return _buildParticipantRow(
                name: '${applicant['student_name']} (${applicant['student_nim']})',
                onPressed: () => _showScoreBottomSheet(context, applicantId),
                showScoreButton: !isSupervised,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SupervisorRoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  const _SupervisorRoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final supervisedApplicantIds = (room['supervised_applicant_ids'] as List).cast<int>();
    final applicants = (room['applicants'] as List<dynamic>? ?? [])
        .where((a) => supervisedApplicantIds.contains(a['id']))
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          _buildCard(
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
            ]
          ),
          _buildCard(
            children: applicants.map((a) {
              final applicant = a as Map<String, dynamic>;
              final applicantId = applicant['id'] as int;
              return _buildParticipantRow(
                name: '${applicant['student_name']} (${applicant['student_nim']})',
                onPressed: () => _showScoreBottomSheet(context, applicantId),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

void _showScoreBottomSheet(BuildContext context, int applicantId) {
  final scoreController = TextEditingController();
  final remarkController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
          child: Container(
            color: Colors.green.shade100,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Submit Score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: scoreController,
                  decoration: const InputDecoration(
                    labelText: 'Score',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: remarkController,
                  decoration: const InputDecoration(
                    labelText: 'Remark',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement score submission logic
                    final score = scoreController.text;
                    final remark = remarkController.text;
                    debugPrint('Submitting for applicant $applicantId: Score=$score, Remark=$remark');
                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildCard({String? title, required List<Widget> children}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
        ],
        ...children,
      ],
    ),
  );
}

Widget _buildPersonRow({required String name, bool isPresent = false, bool isModerator = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Expanded(child: Text(name)),
        if (isModerator) ...[
          const SizedBox(width: 8),
          Chip(
            label: const Text('Moderator'),
            backgroundColor: Colors.blue.shade100,
            padding: EdgeInsets.zero,
          ),
        ],
        if (!isModerator) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.check_circle,
            color: isPresent ? Colors.green : Colors.grey.shade300,
          ),
        ]
      ],
    ),
  );
}

Widget _buildParticipantRow({required String name, required VoidCallback onPressed, bool showScoreButton = true}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Expanded(child: Text(name)),
        if (showScoreButton) ...[
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onPressed,
            child: const Text('Score'),
          ),
        ]
      ],
    ),
  );
}
