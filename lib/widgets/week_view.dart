import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  DateTime _selectedDate = DateTime.now();

  void _changeWeek(int offset) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: offset * 7));
    });
  }

  int _getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final weekDays = _getWeekDays(_selectedDate);
        final dayNames = ['M', 'T', 'O', 'T', 'F', 'L', 'S'];
        final currentWeekNum = _getWeekNumber(DateTime.now());
        final selectedWeekNum = _getWeekNumber(_selectedDate);
        final isCurrentWeek = currentWeekNum == selectedWeekNum && _selectedDate.year == DateTime.now().year;

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
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => _changeWeek(-1),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCurrentWeek ? 'Denna vecka' : 'Vecka $selectedWeekNum',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: isCurrentWeek ? null : () => _changeWeek(1),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          color: isCurrentWeek ? AppTheme.neutralGray : null,
                        ),
                      ],
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
                                  color: isToday ? AppTheme.primaryColor : Theme.of(context).textTheme.bodySmall?.color,
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
                          child: Tooltip(
                            message: habit.title,
                            preferBelow: true,
                            triggerMode: TooltipTriggerMode.longPress,
                            child: GestureDetector(
                              onLongPress: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${habit.icon} ${habit.title}'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Text(
                                habit.icon,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
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

  List<DateTime> _getWeekDays(DateTime date) {
    final now = date;
    final currentWeekDay = now.weekday;
    final firstDayOfWeek = now.subtract(Duration(days: currentWeekDay - 1));
    
    return List.generate(7, (index) {
      return firstDayOfWeek.add(Duration(days: index));
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
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
}
