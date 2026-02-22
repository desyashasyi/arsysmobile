import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/staff/review/application/review_provider.dart';
import 'package:arsys/features/staff/review/presentation/review_detail_page.dart';

class ReviewListPage extends ConsumerWidget {
  const ReviewListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewAsync = ref.watch(reviewListProvider(1));

    return Scaffold(
      body: reviewAsync.when(
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
                  onPressed: () => ref.refresh(reviewListProvider(1)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (reviewData) {
          final List<dynamic> reviews = reviewData['data'];

          if (reviews.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(reviewListProvider(1).future),
              child: const Center(child: Text('No reviews found.')),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(reviewListProvider(1).future),
            child: ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                final reviewers = review['reviewers'] as List<dynamic>;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      '${review['student_nim']} - ${review['student_name'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((review['research_title'] ?? 'No Title').toUpperCase()),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: reviewers.map<Widget>((reviewer) {
                              final String code = reviewer['reviewer_code'];
                              final String decision = reviewer['decision'];
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
                                default: // Not Defined
                                  chipColor = Colors.grey.shade300;
                                  labelColor = Colors.black54;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  label: Text('$code: $decision'),
                                  backgroundColor: chipColor,
                                  labelStyle: TextStyle(color: labelColor, fontWeight: FontWeight.bold),
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewDetailPage(researchId: review['id']),
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
