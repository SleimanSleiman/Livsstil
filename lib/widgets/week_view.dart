import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class WeekView extends StatelessWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final weekDays = _getWeekDays();
        final dayNames = ['M', 'T', 'O', 'T', 'F', 'L', 'S'];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Denna vecka',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Header med veckodagar
                Row(
                  children: [
                    const SizedBox(width: 48), // Plats för emoji
                    ...weekDays.asMap().entries.map((entry) {
                      final isToday = _isToday(entry.value);
                      return Expanded(
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: isToday
                                ? BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  )
                                : null,
                            child: Center(
                              child: Text(
                                dayNames[entry.key],
                                style: TextStyle(
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                  color: isToday ? AppTheme.primaryColor : AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Vanor med checkboxar
                ...state.activeHabits.map((habit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: Text(
                            habit.icon,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        ...weekDays.map((date) {
                          final isCompleted = state.isHabitCompleted(habit.id, date);
                          final isFuture = date.isAfter(DateTime.now());
                          final entry = state.getHabitEntry(habit.id, date);
                          final hasTime = entry?.durationMinutes != null;
                          
                          return Expanded(
                            child: Center(
                              child: GestureDetector(
                                onTap: isFuture 
                                    ? null 
                                    : () {
                                        HapticFeedback.lightImpact();
                                        state.toggleHabitEntry(habit.id, date);
                                      },
                                onLongPress: isFuture || !habit.trackTime
                                    ? null 
                                    : () {
                                        HapticFeedback.mediumImpact();
                                        _showTimeDialog(context, state, habit, date, entry?.durationMinutes);
                                      },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? AppTheme.primaryColor.withValues(alpha: 0.15)
                                        : isFuture
                                            ? AppTheme.neutralGray.withValues(alpha: 0.05)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isCompleted
                                          ? AppTheme.primaryColor.withValues(alpha: 0.3)
                                          : AppTheme.neutralGray.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: isCompleted
                                        ? hasTime
                                            ? Text(
                                                '${entry!.durationMinutes}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.primaryColor,
                                                ),
                                              )
                                            : Icon(
                                                Icons.check,
                                                size: 18,
                                                color: AppTheme.primaryColor,
                                              )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTimeDialog(BuildContext context, AppState state, habit, DateTime date, int? currentMinutes) {
    int minutes = currentMinutes ?? 30;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('${habit.icon} ${habit.title}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Hur lång tid?'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: minutes > 5 
                          ? () => setDialogState(() => minutes -= 5)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$minutes min',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setDialogState(() => minutes += 5),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Avbryt'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!state.isHabitCompleted(habit.id, date)) {
                    state.toggleHabitEntry(habit.id, date, durationMinutes: minutes);
                  } else {
                    state.updateHabitEntryDuration(habit.id, date, minutes);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Spara'),
              ),
            ],
          );
        },
      ),
    );
  }

  List<DateTime> _getWeekDays() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => DateTime(
      monday.year,
      monday.month,
      monday.day + i,
    ));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}
