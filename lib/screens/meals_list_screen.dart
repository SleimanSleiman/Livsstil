import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/meal_entry.dart';
import '../theme/app_theme.dart';
import 'meal_entry_screen.dart';
import 'meal_detail_screen.dart';

class MealsListScreen extends StatefulWidget {
  const MealsListScreen({super.key});

  @override
  State<MealsListScreen> createState() => _MealsListScreenState();
}

class _MealsListScreenState extends State<MealsListScreen> {
  String _viewMode = 'week'; // 'week' eller 'month'
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Måltider'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MealEntryScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Vy-väljare
          _buildViewSelector(),
          
          // Period-väljare
          _buildPeriodSelector(),
          
          // Måltidslista
          Expanded(
            child: _buildMealsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MealEntryScreen()),
        ),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildViewSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildViewButton('Vecka', 'week'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildViewButton('Månad', 'month'),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(String label, String mode) {
    final isSelected = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.neutralGray.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    String periodText;
    if (_viewMode == 'week') {
      final monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      periodText = '${monday.day}/${monday.month} - ${sunday.day}/${sunday.month}';
    } else {
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Maj', 'Jun', 
                          'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dec'];
      periodText = '${monthNames[_selectedDate.month - 1]} ${_selectedDate.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                if (_viewMode == 'week') {
                  _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                } else {
                  _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
                }
              });
            },
          ),
          Text(
            periodText,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                if (_viewMode == 'week') {
                  _selectedDate = _selectedDate.add(const Duration(days: 7));
                } else {
                  _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        List<MealEntry> meals;
        if (_viewMode == 'week') {
          meals = state.getMealsForWeek(_selectedDate);
        } else {
          meals = state.getMealsForMonth(_selectedDate.year, _selectedDate.month);
        }

        if (meals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🍽️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'Inga måltider registrerade',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tryck + för att lägga till',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        // Gruppera efter datum
        final groupedMeals = <String, List<MealEntry>>{};
        for (final meal in meals) {
          final dateKey = _formatDateHeader(meal.timestamp);
          groupedMeals.putIfAbsent(dateKey, () => []).add(meal);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedMeals.length,
          itemBuilder: (context, index) {
            final dateKey = groupedMeals.keys.elementAt(index);
            final dayMeals = groupedMeals[dateKey]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    dateKey,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                ...dayMeals.map((meal) => _buildMealCard(meal)),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mealDate = DateTime(date.year, date.month, date.day);
    
    if (mealDate == today) {
      return 'Idag';
    } else if (mealDate == today.subtract(const Duration(days: 1))) {
      return 'Igår';
    } else {
      final weekdays = ['Mån', 'Tis', 'Ons', 'Tor', 'Fre', 'Lör', 'Sön'];
      return '${weekdays[date.weekday - 1]} ${date.day}/${date.month}';
    }
  }

  Widget _buildMealCard(MealEntry meal) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: meal.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neutralGray.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            // Bild eller ikon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: meal.imagePath != null && File(meal.imagePath!).existsSync()
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(meal.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Text('🍽️', style: TextStyle(fontSize: 28)),
                    ),
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meal.name ?? _formatTime(meal.timestamp),
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (meal.rating != MealRating.none)
                        Text(
                          MealEntry.ratingEmoji(meal.rating),
                          style: const TextStyle(fontSize: 20),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (meal.hungerBefore != null) ...[
                        _buildInfoChip('Före: ${meal.hungerBefore}'),
                        const SizedBox(width: 8),
                      ],
                      if (meal.satietyAfter != null)
                        _buildInfoChip('Efter: ${meal.satietyAfter}'),
                      if (meal.hungerBefore == null && meal.satietyAfter == null)
                        Text(
                          'Tryck för att lägga till detaljer',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Icon(Icons.chevron_right, color: AppTheme.neutralGray),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
