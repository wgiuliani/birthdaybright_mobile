// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GiftSuggestion _$GiftSuggestionFromJson(Map<String, dynamic> json) =>
    GiftSuggestion(
      id: json['id'] as String,
      suggestion: json['suggestion'] as String,
      reasoning: json['reasoning'] as String,
      price: (json['price'] as num?)?.toDouble(),
      birthdayId: json['birthdayId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$GiftSuggestionToJson(GiftSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'suggestion': instance.suggestion,
      'reasoning': instance.reasoning,
      'price': instance.price,
      'birthdayId': instance.birthdayId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
