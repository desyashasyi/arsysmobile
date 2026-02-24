import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/staff/final_defense/application/final_defense_provider.dart';
import 'package:arsys/features/staff/final_defense/presentation/final_defense_detail_page.dart';

class FinalDefenseListPage extends ConsumerWidget {
  const FinalDefenseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(finalDefenseEventsProvider(1));

    return Scaffold(
      body: eventsAsync.when(
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
                  onPressed: () => ref.refresh(finalDefenseEventsProvider(1)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          final items = data['data'] as List<dynamic>? ?? [];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(finalDefenseEventsProvider(1).future),
              child: const Center(child: Text('No final defense events found for you.'))
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(finalDefenseEventsProvider(1).future),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final ev = items[index] as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.event, color: Colors.blueGrey),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${ev['event_code'] ?? 'Event ${ev['id'] ?? index}'} ${ev['name'] ?? ''}'.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (((ev['program_code'] ?? '') as String).isNotEmpty || ((ev['program_abbrev'] ?? '') as String).isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${ev['program_code'] ?? ''}${(ev['program_code'] ?? '') != '' && (ev['program_abbrev'] ?? '') != '' ? ' ' : ''}${ev['program_abbrev'] ?? ''}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          ev['event_date'] ?? '',
                          style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final id = ev['id'] as int?;
                      if (id != null) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => FinalDefenseDetailPage(eventId: id)));
                      }
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
