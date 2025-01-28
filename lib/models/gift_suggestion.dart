import 'package:json_annotation/json_annotation.dart';

part 'gift_suggestion.g.dart';

@JsonSerializable()
class GiftSuggestion {
  final String id;
  final String suggestion;
  final String reasoning;
  final double? price;
  final String birthdayId;
  final DateTime createdAt;

  GiftSuggestion({
    required this.id,
    required this.suggestion,
    required this.reasoning,
    this.price,
    required this.birthdayId,
    required this.createdAt,
  });

  factory GiftSuggestion.fromJson(Map<String, dynamic> json) => 
      _$GiftSuggestionFromJson(json);
  
  Map<String, dynamic> toJson() => _$GiftSuggestionToJson(this);
} 