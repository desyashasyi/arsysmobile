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
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 120.0), // Increased bottom padding
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
                  if (isSupervisor)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddExaminerSheet(context, ref, participantId),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Examiner'),
                        ),
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

  void _showAddExaminerSheet(BuildContext context, WidgetRef ref, int participantId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.green[100],
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddExaminerSheet(participantId: participantId),
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

class AddExaminerSheet extends ConsumerStatefulWidget {
  final int participantId;
  const AddExaminerSheet({super.key, required this.participantId});

  @override
  ConsumerState<AddExaminerSheet> createState() => _AddExaminerSheetState();
}

class _AddExaminerSheetState extends ConsumerState<AddExaminerSheet> {
  final _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  dynamic _selectedStaff;

  void _searchStaff(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final results = await ref.read(preDefenseRepositoryProvider).searchStaff(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  void _addExaminer() async {
    if (_selectedStaff == null) return;
    try {
      await ref.read(preDefenseRepositoryProvider).addExaminer(widget.participantId, _selectedStaff['id']);
      ref.invalidate(preDefenseParticipantDetailProvider(widget.participantId));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 60.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Examiner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by staff code',
                border: OutlineInputBorder(),
              ),
              onChanged: _searchStaff,
            ),
            if (_isLoading)
              const LinearProgressIndicator(),
            if (_searchResults.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final staff = _searchResults[index];
                    return ListTile(
                      title: Text('${staff['first_name']} ${staff['last_name']}'),
                      subtitle: Text(staff['code']),
                      onTap: () {
                        setState(() {
                          _selectedStaff = staff;
                          _searchController.text = '${staff['first_name']} ${staff['last_name']}';
                          _searchResults = [];
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _selectedStaff != null ? _addExaminer : null,
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
