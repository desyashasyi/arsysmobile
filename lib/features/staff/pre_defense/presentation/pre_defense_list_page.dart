import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsys/features/staff/pre_defense/application/pre_defense_provider.dart';
import 'package:arsys/features/staff/pre_defense/presentation/pre_defense_detail_page.dart';

class PreDefenseListPage extends ConsumerWidget {
  const PreDefenseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(preDefenseEventsProvider(1));

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
                  onPressed: () => ref.refresh(preDefenseEventsProvider(1)),
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
              onRefresh: () => ref.refresh(preDefenseEventsProvider(1).future),
              child: const Center(child: Text('No pre-defense events found for you.'))
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(preDefenseEventsProvider(1).future),
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
                        Text(
                          (ev['event_id_string'] ?? 'Event ${ev['id'] ?? index}').toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PreDefenseDetailPage(eventId: id)));
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
