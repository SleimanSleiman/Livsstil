import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/habit.dart';

class WorkoutWeekView extends StatefulWidget {
  const WorkoutWeekView({super.key});

  @override
  State<WorkoutWeekView> createState() => _WorkoutWeekViewState();
}

class _WorkoutWeekViewState extends State<WorkoutWeekView> {
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
        final activeTypes = state.activeWorkoutTypes;
        final currentWeekNum = _getWeekNumber(DateTime.now());
        final selectedWeekNum = _getWeekNumber(_selectedDate);
        final isCurrentWeek = currentWeekNum == selectedWeekNum && _selectedDate.year == DateTime.now().year;

        if (activeTypes.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('🏃', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 12),
                  Text(
                    'Inga träningstyper aktiva',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aktivera träningstyper i inställningarna',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

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
                          isCurrentWeek ? 'Träning denna vecka' : 'Vecka $selectedWeekNum',
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
                                    color: AppTheme.accentWarm.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  )
                                : null,
                            child: Center(
                              child: Text(
                                dayNames[entry.key],
                                style: TextStyle(
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                  color: isToday ? AppTheme.accentWarm : Theme.of(context).textTheme.bodySmall?.color,
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
                
                // Träningstyper med checkboxar
                ...activeTypes.map((workoutType) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: Text(
                            workoutType.icon,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        ...weekDays.map((date) {
                          final entry = _getWorkoutEntry(state, workoutType.id, date);
                          final isCompleted = entry != null;
                          final isFuture = date.isAfter(DateTime.now());
                          
                          return Expanded(
                            child: Center(
                              child: GestureDetector(
                                onTap: isFuture 
                                    ? null 
                                    : () {
                                        HapticFeedback.lightImpact();
                                        _toggleWorkout(context, state, workoutType, date);
                                      },
                                onLongPress: isFuture
                                    ? null 
                                    : () {
                                        HapticFeedback.mediumImpact();
                                        _showWorkoutDialog(context, state, workoutType, date, entry);
                                      },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? AppTheme.accentWarm.withValues(alpha: 0.15)
                                        : isFuture
                                            ? AppTheme.neutralGray.withValues(alpha: 0.05)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isCompleted
                                          ? AppTheme.accentWarm.withValues(alpha: 0.3)
                                          : AppTheme.neutralGray.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: isCompleted
                                        ? entry.durationMinutes > 0
                                            ? Text(
                                                '${entry.durationMinutes}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.accentWarm,
                                                ),
                                              )
                                            : Icon(
                                                Icons.check,
                                                size: 18,
                                                color: AppTheme.accentWarm,
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

  WorkoutEntry? _getWorkoutEntry(AppState state, String typeId, DateTime date) {
    try {
      return state.workoutEntries.firstWhere(
        (e) => e.workoutTypeId == typeId && 
               e.date.year == date.year && 
               e.date.month == date.month && 
               e.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  void _toggleWorkout(BuildContext context, AppState state, WorkoutType type, DateTime date) {
    final existing = _getWorkoutEntry(state, type.id, date);
    if (existing != null) {
      // Ta bort
      state.removeWorkoutEntry(existing);
    } else {
      // Lägg till utan tid
      state.addWorkoutEntry(WorkoutEntry(
        date: date,
        workoutTypeId: type.id,
        durationMinutes: 0,
      ));
    }
  }

  void _showWorkoutDialog(BuildContext context, AppState state, WorkoutType type, DateTime date, WorkoutEntry? existing) {
    int minutes = existing?.durationMinutes ?? 30;
    final notesController = TextEditingController(text: existing?.note ?? '');
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('${type.icon} ${type.title}'),
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
                        color: AppTheme.accentWarm.withValues(alpha: 0.1),
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
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Anteckning (valfritt)',
                    hintText: 'T.ex. 5km, intervaller',
                  ),
                ),
              ],
            ),
            actions: [
              if (existing != null)
                TextButton(
                  onPressed: () {
                    state.removeWorkoutEntry(existing);
                    Navigator.pop(context);
                  },
                  child: Text('Ta bort', style: TextStyle(color: Colors.red.shade400)),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Avbryt'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (existing != null) {
                    state.removeWorkoutEntry(existing);
                  }
                  state.addWorkoutEntry(WorkoutEntry(
                    date: date,
                    workoutTypeId: type.id,
                    durationMinutes: minutes,
                    note: notesController.text.isEmpty ? null : notesController.text,
                  ));
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

  List<DateTime> _getWeekDays(DateTime date) {
    final now = date;
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
