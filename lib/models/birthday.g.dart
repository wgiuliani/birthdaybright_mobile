// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'birthday.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Birthday _$BirthdayFromJson(Map<String, dynamic> json) => Birthday(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      interests:
          (json['interests'] as List<dynamic>).map((e) => e as String).toList(),
      relationship: json['relationship'] as String,
      gender: json['gender'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BirthdayToJson(Birthday instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'date': instance.date.toIso8601String(),
      'notes': instance.notes,
      'interests': instance.interests,
      'relationship': instance.relationship,
      'gender': instance.gender,
      'budget': instance.budget,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
