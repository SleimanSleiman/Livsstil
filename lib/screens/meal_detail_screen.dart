import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/meal_entry.dart';
import '../theme/app_theme.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  int? _satietyAfter;
  MealRating _rating = MealRating.none;
  bool _isEditing = false;
  final _reflectionController = TextEditingController();
  bool _isEditingReflection = false;

  @override
  void initState() {
    super.initState();
    _loadMealData();
  }

  void _loadMealData() {
    final meal = context.read<AppState>().getMealById(widget.mealId);
    if (meal != null) {
      setState(() {
        _satietyAfter = meal.satietyAfter;
        _rating = meal.rating;
        _reflectionController.text = meal.reflection ?? '';
      });
    }
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final meal = state.getMealById(widget.mealId);
        if (meal == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Måltid')),
            body: const Center(child: Text('Måltiden hittades inte')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(meal.name ?? 'Måltid'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteMeal(context, meal),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bild
                if (meal.imagePath != null && File(meal.imagePath!).existsSync())
                  Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(meal.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                // Tid och datum
                _buildInfoCard(context, meal),
                const SizedBox(height: 20),

                // Hunger före (om det finns)
                if (meal.hungerBefore != null)
                  _buildHungerCard(context, meal),
                
                const SizedBox(height: 20),

                // Mättnad efter - redigerbar
                _buildSatietySection(context, meal),
                const SizedBox(height: 20),

                // Betyg - redigerbar
                _buildRatingSection(context, meal),
                const SizedBox(height: 20),

                // Måltidsreflektion - alltid tillgänglig
                _buildReflectionSection(context, meal),
                const SizedBox(height: 20),

                // Anledning
                if (meal.eatingReason != null)
                  _buildReasonCard(context, meal),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, MealEntry meal) {
    final weekdays = ['Måndag', 'Tisdag', 'Onsdag', 'Torsdag', 'Fredag', 'Lördag', 'Söndag'];
    final date = '${weekdays[meal.timestamp.weekday - 1]} ${meal.timestamp.day}/${meal.timestamp.month}';
    final time = '${meal.timestamp.hour.toString().padLeft(2, '0')}:${meal.timestamp.minute.toString().padLeft(2, '0')}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.schedule, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: Theme.of(context).textTheme.titleMedium),
                Text('Kl. $time', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHungerCard(BuildContext context, MealEntry meal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🍽️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text('Hunger före måltid', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${meal.hungerBefore}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    MealEntry.hungerDescription(meal.hungerBefore!),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSatietySection(BuildContext context, MealEntry meal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('✅', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text('Mättnad efter måltid', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                if (meal.satietyAfter != null && !_isEditing)
                  TextButton(
                    onPressed: () => setState(() => _isEditing = true),
                    child: const Text('Ändra'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (meal.satietyAfter != null && !_isEditing) ...[
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${meal.satietyAfter}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      MealEntry.satietyDescription(meal.satietyAfter!),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Hur kändes det efteråt?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              _buildScaleSelector(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _satietyAfter != null ? () => _saveSatiety(meal) : null,
                  child: const Text('Spara mättnad'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScaleSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(10, (index) {
        final level = index + 1;
        final isSelected = _satietyAfter == level;
        
        return GestureDetector(
          onTap: () => setState(() => _satietyAfter = level),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : AppTheme.neutralGray.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                '$level',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRatingSection(BuildContext context, MealEntry meal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text('Hur kändes måltiden?', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRatingButton(meal, MealRating.bronze, '🥉', 'Okej'),
                _buildRatingButton(meal, MealRating.silver, '🥈', 'Bra'),
                _buildRatingButton(meal, MealRating.gold, '🥇', 'Riktigt bra'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButton(MealEntry meal, MealRating rating, String emoji, String label) {
    final isSelected = (meal.rating == rating) || (_rating == rating && meal.rating == MealRating.none);
    
    return GestureDetector(
      onTap: () {
        setState(() => _rating = rating);
        _saveRating(meal, rating);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _getRatingColor(rating).withValues(alpha: 0.15) : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _getRatingColor(rating) : AppTheme.neutralGray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? _getRatingColor(rating) : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(MealRating rating) {
    switch (rating) {
      case MealRating.bronze:
        return AppTheme.bronzeColor;
      case MealRating.silver:
        return AppTheme.silverColor;
      case MealRating.gold:
        return AppTheme.goldColor;
      case MealRating.none:
        return AppTheme.neutralGray;
    }
  }

  Widget _buildReasonCard(BuildContext context, MealEntry meal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('💭', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Anledning', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  MealEntry.eatingReasonText(meal.eatingReason!),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionSection(BuildContext context, MealEntry meal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('📝', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text('Måltidsreflektion', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                if (meal.reflection != null && meal.reflection!.isNotEmpty && !_isEditingReflection)
                  TextButton(
                    onPressed: () => setState(() => _isEditingReflection = true),
                    child: const Text('Ändra'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (meal.reflection != null && meal.reflection!.isNotEmpty && !_isEditingReflection)
              Text(meal.reflection!, style: Theme.of(context).textTheme.bodyLarge)
            else ...[
              Text(
                'Hur upplevde du måltiden? Vad kan du ta med dig?',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reflectionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'T.ex. "Åt långsamt och kände mig nöjd efteråt..."',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _reflectionController.text.isNotEmpty
                      ? () => _saveReflection(meal)
                      : null,
                  child: const Text('Spara reflektion'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveReflection(MealEntry meal) {
    final updatedMeal = meal.copyWith(reflection: _reflectionController.text);
    context.read<AppState>().updateMealEntry(updatedMeal);
    setState(() => _isEditingReflection = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reflektion sparad'), behavior: SnackBarBehavior.floating),
    );
  }

  void _saveSatiety(MealEntry meal) {
    if (_satietyAfter != null) {
      final updatedMeal = meal.copyWith(satietyAfter: _satietyAfter);
      context.read<AppState>().updateMealEntry(updatedMeal);
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mättnad sparad'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _saveRating(MealEntry meal, MealRating rating) {
    final updatedMeal = meal.copyWith(rating: rating);
    context.read<AppState>().updateMealEntry(updatedMeal);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Betyg sparat'), behavior: SnackBarBehavior.floating),
    );
  }

  void _deleteMeal(BuildContext context, MealEntry meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ta bort måltid?'),
        content: const Text('Är du säker på att du vill ta bort denna måltid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Avbryt'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteMealEntry(meal.id);
              Navigator.pop(context); // Stäng dialog
              Navigator.pop(context); // Gå tillbaka
            },
            child: const Text('Ta bort', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
