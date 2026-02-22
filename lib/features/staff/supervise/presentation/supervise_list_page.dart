import 'package:arsys/features/staff/supervise/application/supervise_provider.dart';
import 'package:arsys/features/staff/supervise/presentation/supervise_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuperviseListPage extends ConsumerWidget {
  const SuperviseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final researchAsyncValue = ref.watch(supervisedResearchProvider(1));

    return researchAsyncValue.when(
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
                onPressed: () => ref.refresh(supervisedResearchProvider(1)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (researchData) {
        final List<dynamic> researches = researchData['data'];

        if (researches.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(supervisedResearchProvider(1).future),
            child: const Center(child: Text('No active research found.')),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(supervisedResearchProvider(1).future),
          child: ListView.builder(
            itemCount: researches.length,
            itemBuilder: (context, index) {
              final research = researches[index];
              final bool needsApproval = research['needs_approval'] ?? false;

              final milestoneCode = research['milestone_code'];
              final milestonePhase = research['milestone_phase'];
              Widget milestoneWidget;

              if (milestoneCode != null && milestonePhase != null) {
                milestoneWidget = RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
                    children: <TextSpan>[
                      TextSpan(text: milestoneCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' | '),
                      TextSpan(text: milestonePhase, style: const TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                );
              } else {
                milestoneWidget = const Text('No milestone data', style: TextStyle(fontSize: 12));
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: needsApproval ? Colors.orange[100] : null,
                child: ListTile(
                  title: Text(
                    '${research['student_nim']} - ${research['student_name'] ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (research['research_title'] ?? 'No Title').toUpperCase(),
                        ),
                        const SizedBox(height: 8),
                        milestoneWidget,
                      ],
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuperviseDetailPage(researchId: research['id']),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
