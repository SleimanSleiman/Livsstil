import 'package:uuid/uuid.dart';

enum MealRating { none, bronze, silver, gold }

enum EatingReason { hunger, habit, emotion, social }

class MealEntry {
  final String id;
  final DateTime timestamp;
  final String? name;  // Namn på måltiden
  final String? imagePath;  // Sökväg till bild
  final int? hungerBefore;  // 1-10
  final int? satietyAfter;  // 1-10
  final EatingReason? eatingReason;
  final MealRating rating;
  final String? note;

  MealEntry({
    String? id,
    required this.timestamp,
    this.name,
    this.imagePath,
    this.hungerBefore,
    this.satietyAfter,
    this.eatingReason,
    this.rating = MealRating.none,
    this.note,
  }) : id = id ?? const Uuid().v4();

  String get dateKey => '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';

  MealEntry copyWith({
    String? name,
    String? imagePath,
    int? hungerBefore,
    int? satietyAfter,
    EatingReason? eatingReason,
    MealRating? rating,
    String? note,
  }) {
    return MealEntry(
      id: id,
      timestamp: timestamp,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      hungerBefore: hungerBefore ?? this.hungerBefore,
      satietyAfter: satietyAfter ?? this.satietyAfter,
      eatingReason: eatingReason ?? this.eatingReason,
      rating: rating ?? this.rating,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'name': name,
    'imagePath': imagePath,
    'hungerBefore': hungerBefore,
    'satietyAfter': satietyAfter,
    'eatingReason': eatingReason?.index,
    'rating': rating.index,
    'note': note,
  };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    name: json['name'],
    imagePath: json['imagePath'],
    hungerBefore: json['hungerBefore'],
    satietyAfter: json['satietyAfter'],
    eatingReason: json['eatingReason'] != null 
        ? EatingReason.values[json['eatingReason']] 
        : null,
    rating: MealRating.values[json['rating'] ?? 0],
    note: json['note'],
  );

  // Hjälptext för hungerskala
  static String hungerDescription(int level) {
    switch (level) {
      case 1:
      case 2:
        return 'Obehagligt hungrig';
      case 3:
      case 4:
        return 'Tydligt hungrig';
      case 5:
        return 'Neutral';
      case 6:
      case 7:
        return 'Lite sugen';
      case 8:
      case 9:
      case 10:
        return 'Inte hungrig';
      default:
        return '';
    }
  }

  // Hjälptext för mättnadsskala
  static String satietyDescription(int level) {
    switch (level) {
      case 1:
      case 2:
        return 'Fortfarande hungrig';
      case 3:
      case 4:
        return 'Inte tillräckligt';
      case 5:
      case 6:
        return 'Lagom mätt';
      case 7:
      case 8:
        return 'Mätt';
      case 9:
      case 10:
        return 'Obehagligt mätt';
      default:
        return '';
    }
  }

  static String eatingReasonText(EatingReason reason) {
    switch (reason) {
      case EatingReason.hunger:
        return 'Hunger';
      case EatingReason.habit:
        return 'Vana';
      case EatingReason.emotion:
        return 'Känsla';
      case EatingReason.social:
        return 'Socialt';
    }
  }

  static String ratingText(MealRating rating) {
    switch (rating) {
      case MealRating.none:
        return 'Inget betyg';
      case MealRating.bronze:
        return 'Det var okej';
      case MealRating.silver:
        return 'Bra val';
      case MealRating.gold:
        return 'Kändes riktigt bra';
    }
  }

  static String ratingEmoji(MealRating rating) {
    switch (rating) {
      case MealRating.none:
        return '';
      case MealRating.bronze:
        return '🥉';
      case MealRating.silver:
        return '🥈';
      case MealRating.gold:
        return '🥇';
    }
  }
}
