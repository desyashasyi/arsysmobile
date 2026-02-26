import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/staff/pre_defense/application/pre_defense_provider.dart';
import 'package:arsys/features/staff/pre_defense/data/pre_defense_repository.dart';

class ApplicantDetailPage extends ConsumerWidget {
  final int participantId;

  const ApplicantDetailPage({super.key, required this.participantId});

  Future<void> _showAlertDialog(BuildContext context, String title, String message, {VoidCallback? onOk}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                onOk?.call();
              },
            ),
          ],
        );
      },
    );
  }

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
          final isExaminer = data['is_examiner'] as bool? ?? false;
          final isExaminerPresent = data['is_examiner_present'] as bool? ?? false;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(preDefenseParticipantDetailProvider(participantId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 120.0),
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
                      participantId,
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
                  const SizedBox(height: 20),
                  _buildSectionTitle('Submit Score'),
                  _buildScoreButtons(context, ref, participantId, isSupervisor, isExaminer, isExaminerPresent, data),
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

  void _showSubmitScoreSheet(BuildContext context, WidgetRef ref, int participantId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.green[100],
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SubmitScoreSheet(participantId: participantId, data: data),
      ),
    );
  }

  void _showScoreGuideSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.green[100],
      builder: (context) => const ScoreGuideSheet(),
    );
  }

  Widget _buildScoreButtons(BuildContext context, WidgetRef ref, int participantId, bool isSupervisor, bool isExaminer, bool isExaminerPresent, Map<String, dynamic> data) {
    final myScoreColorName = data['my_score_color'] as String?;
    final cardColor = myScoreColorName == 'success' ? Colors.green[100] : null;

    return Card(
      elevation: 2,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isSupervisor)
              ElevatedButton(
                onPressed: () => _showSubmitScoreSheet(context, ref, participantId, data),
                child: const Text('Supervisor Score'),
              ),
            if (isExaminer && isExaminerPresent)
              ElevatedButton(
                onPressed: () => _showSubmitScoreSheet(context, ref, participantId, data),
                child: const Text('Examiner Score'),
              ),
            ElevatedButton(
              onPressed: () => _showScoreGuideSheet(context, ref),
              child: const Text('Scoring Guide'),
            ),
          ],
        ),
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
    int participantId,
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
                      _showAlertDialog(context, 'Error', 'Failed to update presence: $e');
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

  Future<void> _showAlertDialog(BuildContext context, String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
      if (mounted) {
        _showAlertDialog(context, 'Error', 'Failed to search staff: $e');
      }
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
      if (mounted) {
        _showAlertDialog(context, 'Error', 'Failed to add examiner: $e');
      }
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

class SubmitScoreSheet extends ConsumerStatefulWidget {
  final int participantId;
  final Map<String, dynamic> data;
  const SubmitScoreSheet({super.key, required this.participantId, required this.data});

  @override
  ConsumerState<SubmitScoreSheet> createState() => _SubmitScoreSheetState();
}

class _SubmitScoreSheetState extends ConsumerState<SubmitScoreSheet> {
  final _scoreController = TextEditingController();
  final _remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scoreController.text = widget.data['my_score']?.toString() ?? '';
    _remarkController.text = widget.data['my_remark'] ?? '';
  }

  Future<void> _showAlertDialog(BuildContext context, String title, String message, {VoidCallback? onOk}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                onOk?.call();
              },
            ),
          ],
        );
      },
    );
  }

  void _submitScore() async {
    final score = int.tryParse(_scoreController.text);
    final remark = _remarkController.text;
    if (score == null || score < 1 || score > 400) {
      _showAlertDialog(context, 'Invalid Score', 'Please enter a valid score between 1 and 400');
      return;
    }
    try {
      await ref.read(preDefenseRepositoryProvider).submitScore(widget.participantId, score, remark: remark);
      ref.invalidate(preDefenseParticipantDetailProvider(widget.participantId));
      if (mounted) {
        _showAlertDialog(context, 'Success', 'Score submitted successfully', onOk: () {
          Navigator.of(context).pop();
        });
      }
    } catch (e) {
      if (mounted) {
        _showAlertDialog(context, 'Error', 'Failed to submit score: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ovalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: Colors.grey),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 60.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Submit Score and Remark', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _scoreController,
              decoration: InputDecoration(
                labelText: 'Score (1-400)',
                border: ovalBorder,
                focusedBorder: ovalBorder,
                enabledBorder: ovalBorder,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _remarkController,
              decoration: InputDecoration(
                labelText: 'Remark',
                border: ovalBorder,
                focusedBorder: ovalBorder,
                enabledBorder: ovalBorder,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _submitScore,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreGuideSheet extends ConsumerWidget {
  const ScoreGuideSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreGuideAsync = ref.watch(scoreGuideProvider);
    return scoreGuideAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (scoreGuide) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 60.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Scoring Guide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(3),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Colors.black12),
                      children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Value', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    ...scoreGuide.map((score) {
                      return TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(8.0), child: Text(score['code'])),
                          Padding(padding: const EdgeInsets.all(8.0), child: Text(score['value'])),
                          Padding(padding: const EdgeInsets.all(8.0), child: Text(score['description'])),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
