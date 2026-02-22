import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/staff/supervise/application/supervise_provider.dart';
import 'package:arsys/features/staff/supervise/data/supervise_repository.dart';

class Approval {
  final int id;
  final String approverName;
  final String approverCode;
  final String type;
  final bool isApproved;
  final bool isCurrentUser;
  final bool isLocked;

  Approval({
    required this.id,
    required this.approverName,
    required this.approverCode,
    required this.type,
    required this.isApproved,
    required this.isCurrentUser,
    required this.isLocked,
  });

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      id: int.parse(json['id'].toString()),
      approverName: json['approver_name'] as String? ?? 'N/A',
      approverCode: json['approver_code'] as String? ?? 'N/A',
      type: json['type'] as String? ?? 'unknown',
      isApproved: json['is_approved'] == true || json['is_approved'] == 1,
      isCurrentUser: json['is_current_user'] as bool? ?? false,
      isLocked: json['is_locked'] as bool? ?? false,
    );
  }

  String get displayName {
    final name = approverName.trim();
    if (name.isEmpty || name == 'Unknown' || name == 'N/A') {
      return approverCode;
    }
    return name;
  }
}

class SuperviseDetailPage extends ConsumerWidget {
  final int researchId;

  const SuperviseDetailPage({super.key, required this.researchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final researchDetailAsync = ref.watch(researchDetailProvider(researchId));
    final approvalsAsync = ref.watch(researchApprovalsProvider(researchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Research Detail')),
      body: researchDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (research) {
          final student = research['student'];
          final supervisors = research['supervisors'] as List;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(researchDetailProvider(researchId));
              ref.invalidate(researchApprovalsProvider(researchId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Student Information'),
                  _buildInfoCard(
                    '${student['nim']} - ${student['name'] ?? ''}',
                    (research['title'] ?? '').toUpperCase(),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Supervisors'),
                  ...supervisors.map(
                    (s) => _buildSupervisorTile(s['name'] ?? '', s['role']),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Approval Requests'),
                  approvalsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Failed to load approvals: $err')),
                    data: (approvalListRaw) {
                      if (approvalListRaw.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text('No approval requests found.')),
                          ),
                        );
                      }

                      final approvals = approvalListRaw
                          .map((item) => Approval.fromJson(item as Map<String, dynamic>))
                          .toList();

                      return Card(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: approvals.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final approval = approvals[index];
                            final bool canBeToggled = approval.isCurrentUser && !approval.isLocked;

                            return ListTile(
                              title: Text(approval.displayName),
                              subtitle: Text(approval.type),
                              trailing: IconButton(
                                icon: Icon(
                                  approval.isApproved ? Icons.check_circle : Icons.check_circle_outline,
                                  color: approval.isApproved ? Colors.green : Colors.grey,
                                ),
                                onPressed: canBeToggled
                                    ? () async {
                                        try {
                                          await ref.read(superviseRepositoryProvider).approveResearch(approval.id);
                                          ref.invalidate(researchApprovalsProvider(researchId));
                                          ref.invalidate(researchDetailProvider(researchId));
                                          ref.invalidate(supervisedResearchProvider(1));

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Approval status updated')),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to update approval: $e')),
                                            );
                                          }
                                        }
                                      }
                                    : null,
                              ),
                            );
                          },
                        ),
                      );
                    },
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

  Widget _buildInfoCard(String title, String subtitle) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildSupervisorTile(String name, String role) {
    String displayRole;
    if (role == 'Pembimbing 1') {
      displayRole = 'Supervisor';
    } else {
      displayRole = 'Co-supervisor';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text(name),
        subtitle: Text(displayRole),
      ),
    );
  }
}
