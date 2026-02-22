import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/staff/review/application/review_provider.dart';
import 'package:arsys/features/staff/review/data/review_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewDetailPage extends ConsumerWidget {
  final int researchId;

  const ReviewDetailPage({super.key, required this.researchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewDetailAsync = ref.watch(reviewDetailProvider(researchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Review Detail')),
      body: reviewDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (detail) {
          final studentInfo = detail['student_info'] as Map<String, dynamic>;
          final reviewers = detail['reviewers'] as List<dynamic>;
          final abstract = detail['abstract'] as String?;
          final fileUrl = detail['file_url'] as String?;
          final researchTitle = detail['research_title'] as String? ?? 'No Title';

          return RefreshIndicator(
            onRefresh: () => ref.refresh(reviewDetailProvider(researchId).future),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Student Information'),
                  Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        '${studentInfo['nim']} - ${studentInfo['name'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(researchTitle.toUpperCase()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Reviewers'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: reviewers.map<Widget>((reviewer) {
                          final String code = reviewer['code'];
                          final String decision = reviewer['decision'] == 'Not Defined' 
                              ? 'Undefined' 
                              : reviewer['decision'];
                          Color chipColor;
                          Color labelColor;

                          switch (decision) {
                            case 'Approve':
                              chipColor = Colors.green;
                              labelColor = Colors.white;
                              break;
                            case 'Reject':
                              chipColor = Colors.red;
                              labelColor = Colors.white;
                              break;
                            default: // Undefined
                              chipColor = Colors.grey.shade300;
                              labelColor = Colors.black54;
                          }

                          return Chip(
                            label: Text('$code: $decision'),
                            backgroundColor: chipColor,
                            labelStyle: TextStyle(color: labelColor, fontWeight: FontWeight.bold),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (abstract != null) ...[
                    _buildSectionTitle('Abstract'),
                    Text(abstract),
                    const SizedBox(height: 20),
                  ],
                  if (fileUrl != null) ...[
                    _buildSectionTitle('File'),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(fileUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not launch $fileUrl')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.link),
                      label: const Text('Open Proposal File'),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildSectionTitle('Decision'),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildDecisionButtons(context, ref),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDecisionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _submitDecision(context, ref, 'approve'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Approve'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _submitDecision(context, ref, 'reject'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Reject'),
          ),
        ),
      ],
    );
  }

  void _submitDecision(BuildContext context, WidgetRef ref, String decision) async {
    try {
      await ref.read(reviewRepositoryProvider).submitReview(researchId, decision);
      
      ref.invalidate(reviewListProvider(1));
      ref.invalidate(reviewDetailProvider(researchId));

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
