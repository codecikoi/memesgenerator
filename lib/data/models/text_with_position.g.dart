// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_with_position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextWithPosition _$TextWithPositionFromJson(Map<String, dynamic> json) =>
    TextWithPosition(
      id: json['id'] as String,
      text: json['text'] as String,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
      fontSize: (json['font_size'] as num?)?.toDouble(),
      fontWeight: fontWeightFromJson(json['font_weight'] as int?),
      color: colorFromJson(json['color'] as String?),
    );

Map<String, dynamic> _$TextWithPositionToJson(TextWithPosition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'position': instance.position.toJson(),
      'font_size': instance.fontSize,
      'color': colorToJson(instance.color),
      'font_weight': fontWeightToJson(instance.fontWeight),
    };
