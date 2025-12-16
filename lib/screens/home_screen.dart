import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/identity_card.dart';
import '../widgets/week_view.dart';
import '../widgets/workout_week_view.dart';
import '../widgets/quick_actions.dart';
import 'meal_entry_screen.dart';
import 'meals_list_screen.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

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
              
              // Identitetskort
              const IdentityCard(),
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
              
              // Motiverande text
              _buildMotivationalText(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
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

  Widget _buildMotivationalText(BuildContext context) {
    final messages = [
      'Små val räknas',
      'Du bygger något hållbart',
      'Tillräckligt är bra',
      'Fokus på nästa val',
      'Varje steg spelar roll',
    ];
    
    final index = DateTime.now().day % messages.length;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('✨', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            messages[index],
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_rounded,
                label: 'Hem',
                isSelected: true,
                onTap: () {},
              ),
              _buildNavItem(
                context,
                icon: Icons.restaurant_rounded,
                label: 'Måltider',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MealsListScreen()),
                ),
                onLongPress: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MealEntryScreen()),
                  );
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.bar_chart_rounded,
                label: 'Statistik',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                ),
              ),
              _buildNavItem(
                context,
                icon: Icons.lightbulb_outline_rounded,
                label: 'Insikter',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InsightsScreen()),
                ),
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_rounded,
                label: 'Mer',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.neutralGray,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.primaryColor : AppTheme.neutralGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
