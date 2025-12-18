import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/reflection.dart';

class ReflectionHistoryScreen extends StatelessWidget {
  const ReflectionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflektionshistorik'),
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final reflections = state.reflections;
          if (reflections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: AppTheme.neutralGray),
                  const SizedBox(height: 16),
                  Text(
                    'Inga reflektioner ännu',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Sortera nyast först
          final sortedReflections = List<Reflection>.from(reflections)
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: sortedReflections.length,
            itemBuilder: (context, index) {
              final reflection = sortedReflections[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vecka ${DateFormat('w').format(reflection.date)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMMM yyyy').format(reflection.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      if (reflection.whatWorked != null && reflection.whatWorked!.isNotEmpty) ...[
                        Text(
                          'Vad fungerade:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(reflection.whatWorked!),
                        const SizedBox(height: 8),
                      ],
                      if (reflection.nextWeekAdjustment != null && reflection.nextWeekAdjustment!.isNotEmpty) ...[
                        Text(
                          'Justering:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(reflection.nextWeekAdjustment!),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
