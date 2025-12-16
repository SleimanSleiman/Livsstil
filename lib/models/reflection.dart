import 'package:uuid/uuid.dart';

class Reflection {
  final String id;
  final DateTime date;
  final String? whatWorked;
  final String? whatWasDifficult;
  final String? nextWeekAdjustment;

  Reflection({
    String? id,
    required this.date,
    this.whatWorked,
    this.whatWasDifficult,
    this.nextWeekAdjustment,
  }) : id = id ?? const Uuid().v4();

  String get weekKey {
    // Beräkna veckonummer
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDayOfYear).inDays;
    final weekNumber = ((daysDiff + firstDayOfYear.weekday - 1) / 7).ceil();
    return '${date.year}-W$weekNumber';
  }

  Reflection copyWith({
    String? whatWorked,
    String? whatWasDifficult,
    String? nextWeekAdjustment,
  }) {
    return Reflection(
      id: id,
      date: date,
      whatWorked: whatWorked ?? this.whatWorked,
      whatWasDifficult: whatWasDifficult ?? this.whatWasDifficult,
      nextWeekAdjustment: nextWeekAdjustment ?? this.nextWeekAdjustment,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'whatWorked': whatWorked,
    'whatWasDifficult': whatWasDifficult,
    'nextWeekAdjustment': nextWeekAdjustment,
  };

  factory Reflection.fromJson(Map<String, dynamic> json) => Reflection(
    id: json['id'],
    date: DateTime.parse(json['date']),
    whatWorked: json['whatWorked'],
    whatWasDifficult: json['whatWasDifficult'],
    nextWeekAdjustment: json['nextWeekAdjustment'],
  );
}
