import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'meals_list_screen.dart';
import 'statistics_screen.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';
import 'meal_entry_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MealsListScreen(),
    const StatisticsScreen(),
    const InsightsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
                  index: 0,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.restaurant_rounded,
                  label: 'Måltider',
                  index: 1,
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
                  index: 2,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.lightbulb_outline_rounded,
                  label: 'Insikter',
                  index: 3,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings_rounded,
                  label: 'Mer',
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    VoidCallback? onLongPress,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);
      },
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
