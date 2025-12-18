import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/meal_entry.dart';
import '../models/reflection.dart';
import '../models/weight_entry.dart';
import '../models/milestone.dart';

class AppState extends ChangeNotifier {
  // Identitet
  String _identityStatement = 'Jag är en person som tar hand om min hälsa';
  String get identityStatement => _identityStatement;

  // Vanor
  List<Habit> _habits = [];
  List<Habit> get habits => _habits;
  List<Habit> get activeHabits => _habits.where((h) => h.isActive).toList();

  // Vanelogg
  List<HabitEntry> _habitEntries = [];
  List<HabitEntry> get habitEntries => _habitEntries;

  // Måltidslogg
  List<MealEntry> _mealEntries = [];
  List<MealEntry> get mealEntries => _mealEntries;

  // Träningstyper
  List<WorkoutType> _workoutTypes = [];
  List<WorkoutType> get workoutTypes => _workoutTypes;
  List<WorkoutType> get activeWorkoutTypes => _workoutTypes.where((w) => w.isActive).toList();

  // Träningslogg
  List<WorkoutEntry> _workoutEntries = [];
  List<WorkoutEntry> get workoutEntries => _workoutEntries;

  // Reflektioner
  List<Reflection> _reflections = [];
  List<Reflection> get reflections => _reflections;

  // Vikt (valfritt)
  List<WeightEntry> _weightEntries = [];
  List<WeightEntry> get weightEntries => _weightEntries;

  // Milstolpar
  List<Milestone> _milestones = [];
  List<Milestone> get milestones => _milestones;

  // Streak
  int _currentStreak = 0;
  int _bestStreak = 0;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;

  // Tema
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _saveThemeMode();
  }

  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
  }

  // Initialisering
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Ladda tema
    final themeIndex = prefs.getInt('themeMode');
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    // Ladda identitet
    _identityStatement = prefs.getString('identity') ?? _identityStatement;

    // Ladda vanor
    final habitsJson = prefs.getString('habits');
    if (habitsJson != null) {
      final List<dynamic> habitsList = jsonDecode(habitsJson);
      _habits = habitsList.map((h) => Habit.fromJson(h)).toList();
    } else {
      _habits = Habit.defaultHabits;
    }

    // Ladda träningstyper
    final workoutTypesJson = prefs.getString('workoutTypes');
    if (workoutTypesJson != null) {
      final List<dynamic> typesList = jsonDecode(workoutTypesJson);
      _workoutTypes = typesList.map((t) => WorkoutType.fromJson(t)).toList();
    } else {
      _workoutTypes = WorkoutType.defaultWorkoutTypes;
    }

    // Ladda vanelogg
    final habitEntriesJson = prefs.getString('habitEntries');
    if (habitEntriesJson != null) {
      final List<dynamic> entriesList = jsonDecode(habitEntriesJson);
      _habitEntries = entriesList.map((e) => HabitEntry.fromJson(e)).toList();
    }

    // Ladda måltider
    final mealEntriesJson = prefs.getString('mealEntries');
    if (mealEntriesJson != null) {
      final List<dynamic> mealsList = jsonDecode(mealEntriesJson);
      _mealEntries = mealsList.map((m) => MealEntry.fromJson(m)).toList();
    }

    // Ladda träning
    final workoutEntriesJson = prefs.getString('workoutEntries');
    if (workoutEntriesJson != null) {
      final List<dynamic> workoutsList = jsonDecode(workoutEntriesJson);
      _workoutEntries = workoutsList.map((w) => WorkoutEntry.fromJson(w)).toList();
    }

    // Ladda reflektioner
    final reflectionsJson = prefs.getString('reflections');
    if (reflectionsJson != null) {
      final List<dynamic> reflectionsList = jsonDecode(reflectionsJson);
      _reflections = reflectionsList.map((r) => Reflection.fromJson(r)).toList();
    }

    // Ladda vikt
    final weightJson = prefs.getString('weightEntries');
    if (weightJson != null) {
      final List<dynamic> weightList = jsonDecode(weightJson);
      _weightEntries = weightList.map((w) => WeightEntry.fromJson(w)).toList();
    }

    // Ladda milstolpar
    final milestonesJson = prefs.getString('milestones');
    if (milestonesJson != null) {
      final List<dynamic> milestonesList = jsonDecode(milestonesJson);
      _milestones = milestonesList.map((m) => Milestone.fromJson(m)).toList();
    } else {
      _milestones = Milestone.defaultMilestones;
    }

    // Ladda streak
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    _bestStreak = prefs.getInt('bestStreak') ?? 0;

    _calculateStreak();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('identity', _identityStatement);
    await prefs.setString('habits', jsonEncode(_habits.map((h) => h.toJson()).toList()));
    await prefs.setString('workoutTypes', jsonEncode(_workoutTypes.map((t) => t.toJson()).toList()));
    await prefs.setString('habitEntries', jsonEncode(_habitEntries.map((e) => e.toJson()).toList()));
    await prefs.setString('mealEntries', jsonEncode(_mealEntries.map((m) => m.toJson()).toList()));
    await prefs.setString('workoutEntries', jsonEncode(_workoutEntries.map((w) => w.toJson()).toList()));
    await prefs.setString('reflections', jsonEncode(_reflections.map((r) => r.toJson()).toList()));
    await prefs.setString('weightEntries', jsonEncode(_weightEntries.map((w) => w.toJson()).toList()));
    await prefs.setString('milestones', jsonEncode(_milestones.map((m) => m.toJson()).toList()));
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setInt('bestStreak', _bestStreak);
  }

  // Identitet
  void updateIdentity(String statement) {
    _identityStatement = statement;
    _saveData();
    notifyListeners();
  }

  // Träningstyper
  void toggleWorkoutTypeActive(String typeId) {
    final index = _workoutTypes.indexWhere((t) => t.id == typeId);
    if (index != -1) {
      final activeCount = activeWorkoutTypes.length;
      final isCurrentlyActive = _workoutTypes[index].isActive;
      
      if (!isCurrentlyActive && activeCount >= 5) {
        return; // Max 5 aktiva
      }

      _workoutTypes[index] = _workoutTypes[index].copyWith(isActive: !isCurrentlyActive);
      _saveData();
      notifyListeners();
    }
  }

  void addWorkoutType(WorkoutType type) {
    _workoutTypes.add(type);
    _saveData();
    notifyListeners();
  }

  void deleteWorkoutType(String typeId) {
    _workoutTypes.removeWhere((t) => t.id == typeId);
    _saveData();
    notifyListeners();
  }

  WorkoutType? getWorkoutTypeById(String id) {
    try {
      return _workoutTypes.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Vanor
  void toggleHabitActive(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      // Kontrollera att max 5 är aktiva
      final activeCount = activeHabits.length;
      final isCurrentlyActive = _habits[index].isActive;
      
      if (!isCurrentlyActive && activeCount >= 5) {
        return; // Max 5 aktiva vanor
      }

      _habits[index] = _habits[index].copyWith(isActive: !isCurrentlyActive);
      _saveData();
      notifyListeners();
    }
  }

  void updateHabit(Habit habit) {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      _saveData();
      notifyListeners();
    }
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    _saveData();
    notifyListeners();
  }

  void deleteHabit(String habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    _saveData();
    notifyListeners();
  }

  // Vanelogg
  void toggleHabitEntry(String habitId, DateTime date, {int? durationMinutes}) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final existingIndex = _habitEntries.indexWhere(
      (e) => e.habitId == habitId && e.dateKey == dateKey
    );

    if (existingIndex != -1) {
      // Ta bort om den finns
      _habitEntries.removeAt(existingIndex);
    } else {
      // Lägg till som gjord
      _habitEntries.add(HabitEntry(
        habitId: habitId,
        date: date,
        completed: true,
        durationMinutes: durationMinutes,
      ));
    }

    _calculateStreak();
    _checkMilestones();
    _saveData();
    notifyListeners();
  }

  void updateHabitEntryDuration(String habitId, DateTime date, int durationMinutes) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final existingIndex = _habitEntries.indexWhere(
      (e) => e.habitId == habitId && e.dateKey == dateKey
    );

    if (existingIndex != -1) {
      _habitEntries[existingIndex] = _habitEntries[existingIndex].copyWith(
        durationMinutes: durationMinutes,
      );
      _saveData();
      notifyListeners();
    }
  }

  HabitEntry? getHabitEntry(String habitId, DateTime date) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      return _habitEntries.firstWhere(
        (e) => e.habitId == habitId && e.dateKey == dateKey
      );
    } catch (e) {
      return null;
    }
  }

  bool isHabitCompleted(String habitId, DateTime date) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _habitEntries.any(
      (e) => e.habitId == habitId && e.dateKey == dateKey && e.completed
    );
  }

  // Måltider
  void addMealEntry(MealEntry entry) {
    _mealEntries.add(entry);
    _checkMilestones();
    _saveData();
    notifyListeners();
  }

  void updateMealEntry(MealEntry entry) {
    final index = _mealEntries.indexWhere((m) => m.id == entry.id);
    if (index != -1) {
      _mealEntries[index] = entry;
      _saveData();
      notifyListeners();
    }
  }

  void deleteMealEntry(String id) {
    _mealEntries.removeWhere((m) => m.id == id);
    _saveData();
    notifyListeners();
  }

  MealEntry? getMealById(String id) {
    try {
      return _mealEntries.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  List<MealEntry> getMealsForDate(DateTime date) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _mealEntries.where((m) => m.dateKey == dateKey).toList();
  }

  List<MealEntry> getMealsForWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return _mealEntries.where((m) {
      return m.timestamp.isAfter(monday.subtract(const Duration(days: 1))) &&
             m.timestamp.isBefore(sunday.add(const Duration(days: 1)));
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<MealEntry> getMealsForMonth(int year, int month) {
    return _mealEntries.where((m) {
      return m.timestamp.year == year && m.timestamp.month == month;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Träning
  void addWorkoutEntry(WorkoutEntry entry) {
    _workoutEntries.add(entry);
    _saveData();
    notifyListeners();
  }

  void removeWorkoutEntry(WorkoutEntry entry) {
    _workoutEntries.removeWhere((w) => w.id == entry.id);
    _saveData();
    notifyListeners();
  }

  void deleteWorkoutEntry(String id) {
    _workoutEntries.removeWhere((w) => w.id == id);
    _saveData();
    notifyListeners();
  }

  List<WorkoutEntry> getWorkoutsForDate(DateTime date) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _workoutEntries.where((w) => w.dateKey == dateKey).toList();
  }

  List<WorkoutEntry> getWorkoutsForWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return _workoutEntries.where((w) {
      return w.date.isAfter(monday.subtract(const Duration(days: 1))) &&
             w.date.isBefore(sunday.add(const Duration(days: 1)));
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  // Reflektioner
  void saveReflection(Reflection reflection) {
    final existingIndex = _reflections.indexWhere((r) => r.weekKey == reflection.weekKey);
    if (existingIndex != -1) {
      _reflections[existingIndex] = reflection;
    } else {
      _reflections.add(reflection);
    }
    _saveData();
    notifyListeners();
  }

  Reflection? getReflectionForWeek(DateTime date) {
    final reflection = Reflection(date: date);
    return _reflections.firstWhere(
      (r) => r.weekKey == reflection.weekKey,
      orElse: () => reflection,
    );
  }

  // Vikt
  void addWeightEntry(WeightEntry entry) {
    _weightEntries.add(entry);
    _saveData();
    notifyListeners();
  }

  WeightEntry? getLatestWeightEntry() {
    if (_weightEntries.isEmpty) return null;
    _weightEntries.sort((a, b) => b.date.compareTo(a.date));
    return _weightEntries.first;
  }

  // Streak beräkning
  void _calculateStreak() {
    if (activeHabits.isEmpty) {
      _currentStreak = 0;
      return;
    }

    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    // Börja från igår om dagens vanor inte är ifyllda
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final todayEntries = _habitEntries.where((e) => e.dateKey == todayKey).toList();
    
    if (todayEntries.isEmpty) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final dateKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      final dayEntries = _habitEntries.where((e) => e.dateKey == dateKey && e.completed).toList();
      
      // Räkna som en dag om minst en vana är gjord
      if (dayEntries.isNotEmpty) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    _currentStreak = streak;
    if (_currentStreak > _bestStreak) {
      _bestStreak = _currentStreak;
    }
  }

  // Milstolpar
  void _checkMilestones() {
    // Räkna totala dagar med aktivitet
    final uniqueDays = _habitEntries
        .where((e) => e.completed)
        .map((e) => e.dateKey)
        .toSet()
        .length;

    // Räkna promenader (rörelse-vanan)
    final walkCount = _habitEntries
        .where((e) => e.habitId == 'movement' && e.completed)
        .length;

    // Räkna medvetna måltider
    final mealCount = _habitEntries
        .where((e) => e.habitId == 'mindful_eating' && e.completed)
        .length;

    for (int i = 0; i < _milestones.length; i++) {
      final milestone = _milestones[i];
      if (milestone.achieved) continue;

      int currentCount = 0;
      switch (milestone.id) {
        case 'first_week':
        case 'thirty_days':
        case 'ninety_days':
          currentCount = uniqueDays;
          break;
        case 'hundred_walks':
          currentCount = walkCount;
          break;
        case 'fifty_meals':
          currentCount = mealCount;
          break;
      }

      if (currentCount >= milestone.targetCount) {
        _milestones[i] = milestone.copyWith(
          achieved: true,
          achievedDate: DateTime.now(),
        );
      }
    }
  }

  // Statistik för månadsöversikt
  Map<String, int> getMonthlyHabitStats(int year, int month) {
    final Map<String, int> stats = {};
    
    for (final habit in activeHabits) {
      final count = _habitEntries.where((e) {
        final entryDate = e.date;
        return e.habitId == habit.id &&
               e.completed &&
               entryDate.year == year &&
               entryDate.month == month;
      }).length;
      stats[habit.id] = count;
    }
    
    return stats;
  }

  int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  double getMonthlyIdentityPercentage(int year, int month) {
    final daysInMonth = getDaysInMonth(year, month);
    final uniqueDays = _habitEntries
        .where((e) {
          final entryDate = e.date;
          return e.completed &&
                 entryDate.year == year &&
                 entryDate.month == month;
        })
        .map((e) => e.dateKey)
        .toSet()
        .length;
    
    return (uniqueDays / daysInMonth) * 100;
  }

  // Insikter
  List<String> generateInsights() {
    final insights = <String>[];
    
    if (_mealEntries.isEmpty) {
      return ['Registrera måltider för att få insikter'];
    }

    // Genomsnittlig hunger före måltid
    final hungerValues = _mealEntries
        .where((m) => m.hungerBefore != null)
        .map((m) => m.hungerBefore!)
        .toList();
    
    if (hungerValues.isNotEmpty) {
      final avgHunger = hungerValues.reduce((a, b) => a + b) / hungerValues.length;
      if (avgHunger <= 4) {
        insights.add('De flesta måltider startade vid tydlig hunger (${avgHunger.toStringAsFixed(1)})');
      } else if (avgHunger <= 6) {
        insights.add('Du åt ofta vid lätt hunger eller neutral känsla');
      } else {
        insights.add('Du började ofta äta utan tydlig hunger');
      }
    }

    // Genomsnittlig mättnad efter måltid
    final satietyValues = _mealEntries
        .where((m) => m.satietyAfter != null)
        .map((m) => m.satietyAfter!)
        .toList();
    
    if (satietyValues.isNotEmpty) {
      final avgSatiety = satietyValues.reduce((a, b) => a + b) / satietyValues.length;
      if (avgSatiety >= 5 && avgSatiety <= 7) {
        insights.add('Du hamnade ofta runt lagom mätt');
      }
    }

    // Måltidsbetyg
    final ratedMeals = _mealEntries.where((m) => m.rating != MealRating.none).toList();
    if (ratedMeals.isNotEmpty) {
      final goldCount = ratedMeals.where((m) => m.rating == MealRating.gold).length;
      final percentage = (goldCount / ratedMeals.length * 100).round();
      if (percentage > 30) {
        insights.add('$percentage% av dina betygsatta måltider kändes riktigt bra');
      }
    }

    if (insights.isEmpty) {
      insights.add('Fortsätt registrera för att se mönster');
    }

    return insights;
  }
}
