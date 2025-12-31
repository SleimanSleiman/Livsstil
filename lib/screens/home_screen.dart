import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
// identity card moved; import removed to avoid unused import
import '../widgets/week_view.dart';
import '../widgets/workout_week_view.dart';
import '../widgets/quick_actions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header med streak
              _buildHeader(context),
              const SizedBox(height: 24),
        
              
              // Veckovy - appens kärna
              const WeekView(),
              const SizedBox(height: 16),
              
              // Träningsvecka
              const WorkoutWeekView(),
              const SizedBox(height: 24),
              
              // Snabbåtgärder
              const QuickActions(),
              const SizedBox(height: 24),
              
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Livsstil',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (state.currentStreak > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentWarm.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      '${state.currentStreak}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentWarm,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'God morgon';
    if (hour < 17) return 'God eftermiddag';
    return 'God kväll';
  }


}


