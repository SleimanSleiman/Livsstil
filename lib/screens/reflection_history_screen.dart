import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/reflection.dart';
import '../models/daily_reflection.dart';
import 'daily_reflection_screen.dart';

class ReflectionHistoryScreen extends StatefulWidget {
  const ReflectionHistoryScreen({super.key});

  @override
  State<ReflectionHistoryScreen> createState() => _ReflectionHistoryScreenState();
}

class _ReflectionHistoryScreenState extends State<ReflectionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflektionshistorik'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dagliga'),
            Tab(text: 'Vecko'),
          ],
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyReflections(),
          _buildWeeklyReflections(),
        ],
      ),
    );
  }

  Widget _buildDailyReflections() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final reflections = state.dailyReflections;
        if (reflections.isEmpty) {
          return _buildEmptyState(
            '💭',
            'Inga dagliga reflektioner ännu',
            'Börja reflektera över din dag',
          );
        }

        // Sortera nyast först
        final sortedReflections = List<DailyReflection>.from(reflections)
          ..sort((a, b) => b.date.compareTo(a.date));

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: sortedReflections.length,
          itemBuilder: (context, index) {
            final reflection = sortedReflections[index];
            return _buildDailyCard(reflection);
          },
        );
      },
    );
  }

  Widget _buildDailyCard(DailyReflection reflection) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DailyReflectionScreen(date: reflection.date),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(reflection.date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (reflection.moodRating != null)
                    Text(
                      DailyReflection.moodEmoji(reflection.moodRating!),
                      style: const TextStyle(fontSize: 24),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('d MMMM yyyy', 'sv').format(reflection.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (reflection.gratitude != null || reflection.highlight != null) ...[
                const SizedBox(height: 12),
                if (reflection.gratitude != null && reflection.gratitude!.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🙏 ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          reflection.gratitude!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (reflection.highlight != null && reflection.highlight!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⭐ ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          reflection.highlight!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyReflections() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final reflections = state.reflections;
        if (reflections.isEmpty) {
          return _buildEmptyState(
            '📝',
            'Inga veckoreflektioner ännu',
            'Summera dina veckor med en veckoreflexion',
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
            return _buildWeeklyCard(reflection);
          },
        );
      },
    );
  }

  Widget _buildWeeklyCard(Reflection reflection) {
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
              DateFormat('d MMMM yyyy', 'sv').format(reflection.date),
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
            if (reflection.whatWasDifficult != null && reflection.whatWasDifficult!.isNotEmpty) ...[
              Text(
                'Vad var svårt:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(reflection.whatWasDifficult!),
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
  }

  Widget _buildEmptyState(String emoji, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) return 'Idag';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Igår';
    
    final weekdays = ['Mån', 'Tis', 'Ons', 'Tor', 'Fre', 'Lör', 'Sön'];
    return weekdays[date.weekday - 1];
  }
}
