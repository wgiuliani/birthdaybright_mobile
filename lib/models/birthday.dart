import 'package:json_annotation/json_annotation.dart';

part 'birthday.g.dart';

@JsonSerializable()
class Birthday {
  final String id;
  final String name;
  final DateTime date;
  final String? notes;
  final List<String> interests;
  final String relationship;
  final String? gender;
  final double? budget;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Birthday({
    required this.id,
    required this.name,
    required this.date,
    this.notes,
    required this.interests,
    required this.relationship,
    this.gender,
    this.budget,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Birthday.fromJson(Map<String, dynamic> json) => _$BirthdayFromJson(json);
  Map<String, dynamic> toJson() => _$BirthdayToJson(this);

  int get daysUntilBirthday {
    final today = DateTime.now();
    final nextBirthday = DateTime(
      today.year,
      date.month,
      date.day,
    );

    if (nextBirthday.isBefore(today)) {
      return DateTime(
        today.year + 1,
        date.month,
        date.day,
      ).difference(today).inDays;
    }

    return nextBirthday.difference(today).inDays;
  }

  int get age {
    final today = DateTime.now();
    var age = today.year - date.year;
    final monthDiff = today.month - date.month;
    
    if (monthDiff < 0 || (monthDiff == 0 && today.day < date.day)) {
      age--;
    }
    
    return age;
  }
} 