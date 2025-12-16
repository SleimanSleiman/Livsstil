import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  final String icon;
  final String title;
  final String description;
  final String? myVersion;  // Personlig anpassning
  final bool isActive;
  final int sortOrder;
  final bool trackTime;  // Om tid ska loggas för denna vana

  Habit({
    String? id,
    required this.icon,
    required this.title,
    required this.description,
    this.myVersion,
    this.isActive = true,
    this.sortOrder = 0,
    this.trackTime = false,
  }) : id = id ?? const Uuid().v4();

  Habit copyWith({
    String? icon,
    String? title,
    String? description,
    String? myVersion,
    bool? isActive,
    int? sortOrder,
    bool? trackTime,
  }) {
    return Habit(
      id: id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
      myVersion: myVersion ?? this.myVersion,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      trackTime: trackTime ?? this.trackTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'icon': icon,
    'title': title,
    'description': description,
    'myVersion': myVersion,
    'isActive': isActive,
    'sortOrder': sortOrder,
    'trackTime': trackTime,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'],
    icon: json['icon'],
    title: json['title'],
    description: json['description'],
    myVersion: json['myVersion'],
    isActive: json['isActive'] ?? true,
    sortOrder: json['sortOrder'] ?? 0,
    trackTime: json['trackTime'] ?? false,
  );

  // Fördefinierade vanor
  static List<Habit> defaultHabits = [
    Habit(
      id: 'movement',
      icon: '🚶‍♂️',
      title: 'Rört på mig',
      description: 'Minst 10 minuter',
      myVersion: 'Promenad, stretch eller städning',
    ),
    Habit(
      id: 'mindful_eating',
      icon: '🥗',
      title: 'Åt medvetet',
      description: 'En måltid med närvaro',
    ),
    Habit(
      id: 'water',
      icon: '💧',
      title: 'Drack vatten',
      description: 'Regelbundet under dagen',
    ),
    Habit(
      id: 'sleep',
      icon: '🛏️',
      title: 'Lade mig i tid',
      description: 'En rimlig tid för vila',
    ),
    Habit(
      id: 'recovery',
      icon: '🧘',
      title: 'Tog en paus',
      description: 'Återhämtning under dagen',
      isActive: false,
    ),
  ];
}

class HabitEntry {
  final String habitId;
  final DateTime date;
  final bool completed;
  final int? durationMinutes;  // Tid i minuter

  HabitEntry({
    required this.habitId,
    required this.date,
    required this.completed,
    this.durationMinutes,
  });

  String get dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  HabitEntry copyWith({
    bool? completed,
    int? durationMinutes,
  }) {
    return HabitEntry(
      habitId: habitId,
      date: date,
      completed: completed ?? this.completed,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
    'habitId': habitId,
    'date': date.toIso8601String(),
    'completed': completed,
    'durationMinutes': durationMinutes,
  };

  factory HabitEntry.fromJson(Map<String, dynamic> json) => HabitEntry(
    habitId: json['habitId'],
    date: DateTime.parse(json['date']),
    completed: json['completed'],
    durationMinutes: json['durationMinutes'],
  );
}

// Träningslogg
class WorkoutEntry {
  final String id;
  final DateTime date;
  final String workoutTypeId;  // Referens till WorkoutType
  final int durationMinutes;
  final String? note;

  WorkoutEntry({
    String? id,
    required this.date,
    required this.workoutTypeId,
    required this.durationMinutes,
    this.note,
  }) : id = id ?? const Uuid().v4();

  String get dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'workoutTypeId': workoutTypeId,
    'durationMinutes': durationMinutes,
    'note': note,
  };

  factory WorkoutEntry.fromJson(Map<String, dynamic> json) => WorkoutEntry(
    id: json['id'],
    date: DateTime.parse(json['date']),
    workoutTypeId: json['workoutTypeId'] ?? json['type'] ?? '',
    durationMinutes: json['durationMinutes'],
    note: json['note'],
  );
}

// Träningstyp (liknande Habit)
class WorkoutType {
  final String id;
  final String icon;
  final String title;
  final bool isActive;
  final int sortOrder;

  WorkoutType({
    String? id,
    required this.icon,
    required this.title,
    this.isActive = true,
    this.sortOrder = 0,
  }) : id = id ?? const Uuid().v4();

  WorkoutType copyWith({
    String? icon,
    String? title,
    bool? isActive,
    int? sortOrder,
  }) {
    return WorkoutType(
      id: id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'icon': icon,
    'title': title,
    'isActive': isActive,
    'sortOrder': sortOrder,
  };

  factory WorkoutType.fromJson(Map<String, dynamic> json) => WorkoutType(
    id: json['id'],
    icon: json['icon'],
    title: json['title'],
    isActive: json['isActive'] ?? true,
    sortOrder: json['sortOrder'] ?? 0,
  );

  static List<WorkoutType> defaultWorkoutTypes = [
    WorkoutType(id: 'walk', icon: '🚶', title: 'Promenad'),
    WorkoutType(id: 'run', icon: '🏃', title: 'Löpning'),
    WorkoutType(id: 'bike', icon: '🚴', title: 'Cykling'),
    WorkoutType(id: 'swim', icon: '🏊', title: 'Simning'),
    WorkoutType(id: 'strength', icon: '💪', title: 'Styrketräning'),
    WorkoutType(id: 'yoga', icon: '🧘', title: 'Yoga', isActive: false),
    WorkoutType(id: 'dance', icon: '💃', title: 'Dans', isActive: false),
    WorkoutType(id: 'other', icon: '🏅', title: 'Annat', isActive: false),
  ];
}
