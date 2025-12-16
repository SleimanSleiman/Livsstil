import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/habit.dart';
import '../models/weight_entry.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inställningar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identitet
            _buildIdentitySection(context),
            const SizedBox(height: 24),
            
            // Hantera vanor
            _buildHabitsSection(context),
            const SizedBox(height: 24),
            
            // Hantera träningstyper
            _buildWorkoutTypesSection(context),
            const SizedBox(height: 24),
            
            // Vikt (valfritt)
            _buildWeightSection(context),
            const SizedBox(height: 24),
            
            // Streak info
            _buildStreakSection(context),
            const SizedBox(height: 24),
            
            // App info
            _buildAppInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentitySection(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(
                      'Min identitet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    state.identityStatement,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Denna mening är stabil och ändras inte dagligen.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitsSection(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text(
                          'Mina vanor',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Text(
                      '${state.activeHabits.length}/5 aktiva',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                ...state.habits.map((habit) => _buildHabitItem(context, habit, state)),
                
                const SizedBox(height: 12),
                
                // Lägg till ny vana
                OutlinedButton.icon(
                  onPressed: () => _showAddHabitDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Lägg till vana'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutTypesSection(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🏃', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text(
                          'Mina träningstyper',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Text(
                      '${state.activeWorkoutTypes.length}/5 aktiva',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Välj vilka träningstyper som visas på hemskärmen.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                
                ...state.workoutTypes.map((type) => _buildWorkoutTypeItem(context, type, state)),
                
                const SizedBox(height: 12),
                
                // Lägg till ny träningstyp
                OutlinedButton.icon(
                  onPressed: () => _showAddWorkoutTypeDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Lägg till träningstyp'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitItem(BuildContext context, Habit habit, AppState state) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(habit.icon, style: const TextStyle(fontSize: 24)),
      title: Text(habit.title),
      subtitle: habit.myVersion != null 
          ? Text(habit.myVersion!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: Switch(
        value: habit.isActive,
        onChanged: state.activeHabits.length >= 5 && !habit.isActive
            ? null
            : (_) => state.toggleHabitActive(habit.id),
        activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.5),
        activeThumbColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildWorkoutTypeItem(BuildContext context, WorkoutType type, AppState state) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(type.icon, style: const TextStyle(fontSize: 24)),
      title: Text(type.title),
      trailing: Switch(
        value: type.isActive,
        onChanged: state.activeWorkoutTypes.length >= 5 && !type.isActive
            ? null
            : (_) => state.toggleWorkoutTypeActive(type.id),
        activeTrackColor: AppTheme.accentWarm.withValues(alpha: 0.5),
        activeThumbColor: AppTheme.accentWarm,
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final iconController = TextEditingController(text: '✨');
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final myVersionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ny vana'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'Emoji',
                  hintText: '🚶‍♂️',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  hintText: 'T.ex. Rört på mig',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Beskrivning',
                  hintText: 'T.ex. Minst 10 minuter',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: myVersionController,
                decoration: const InputDecoration(
                  labelText: 'Min version (valfritt)',
                  hintText: 'T.ex. Promenad eller stretch',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Avbryt'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<AppState>().addHabit(Habit(
                  icon: iconController.text.isEmpty ? '✨' : iconController.text,
                  title: titleController.text,
                  description: descriptionController.text,
                  myVersion: myVersionController.text.isEmpty ? null : myVersionController.text,
                  isActive: false,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Lägg till'),
          ),
        ],
      ),
    );
  }

  void _showAddWorkoutTypeDialog(BuildContext context) {
    final iconController = TextEditingController(text: '💪');
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ny träningstyp'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'Emoji',
                  hintText: '🏋️',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  hintText: 'T.ex. Styrketräning',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Avbryt'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<AppState>().addWorkoutType(WorkoutType(
                  icon: iconController.text.isEmpty ? '💪' : iconController.text,
                  title: titleController.text,
                  isActive: false,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Lägg till'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSection(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final latestWeight = state.getLatestWeightEntry();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⚖️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(
                      'Vikt (valfritt)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Endast för månadsvis reflektion, inte daglig kontroll.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                
                if (latestWeight != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.neutralGray.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Senaste: ${latestWeight.weight.toStringAsFixed(1)} kg',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          _formatDate(latestWeight.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                OutlinedButton.icon(
                  onPressed: () => _showWeightDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Lägg till månadsvikt'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = ['jan', 'feb', 'mar', 'apr', 'maj', 'jun', 
                    'jul', 'aug', 'sep', 'okt', 'nov', 'dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showWeightDialog(BuildContext context) {
    final weightController = TextEditingController();
    final reflectionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Månadsvikt'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Vikt är sekundärt. Fokusera på beteenden.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Vikt (kg)',
                  suffixText: 'kg',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reflectionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Reflektion (valfritt)',
                  hintText: 'Hur känns det?',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Avbryt'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text.replaceAll(',', '.'));
              if (weight != null) {
                context.read<AppState>().addWeightEntry(WeightEntry(
                  date: DateTime.now(),
                  weight: weight,
                  reflection: reflectionController.text.isEmpty ? null : reflectionController.text,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Spara'),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(
                      'Streak',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStreakCard(
                        context,
                        'Nu',
                        '${state.currentStreak}',
                        'dagar',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStreakCard(
                        context,
                        'Bästa',
                        '${state.bestStreak}',
                        'dagar',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Bruten streak är inte misslyckande – nästa val är det som räknas.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreakCard(BuildContext context, String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentWarm.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.accentWarm,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Om Livsstil',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Denna app hjälper dig agera som en hälsosam person genom små, konsekventa val. Fokus ligger på identitet och beteenden, inte kalorier, vikt eller perfektion.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    '"Tillräckligt är bra"',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
