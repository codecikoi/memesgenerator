import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:memesgenerator/data/models/position.dart';

part 'text_with_position.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TextWithPosition extends Equatable {
  final String id;
  final String text;
  final Position position;
  final double? fontSize;

  @JsonKey(toJson: colorToJson, fromJson: colorFromJson)
  final Color? color;

  const TextWithPosition({
    required this.id,
    required this.text,
    required this.position,
    this.fontSize,
    this.color,
  });

  factory TextWithPosition.fromJson(final Map<String, dynamic> json) =>
      _$TextWithPositionFromJson(json);

  Map<String, dynamic> toJson() => _$TextWithPositionToJson(this);

  @override
  List<Object?> get props => [position, text, id, fontSize, color];
}

String? colorToJson(final Color? color) {
  return color == null ? null : color.value.toRadixString(16);
}

Color? colorFromJson(final String? colorString) {
  if (colorString == null) return null;
  final intColor = int.tryParse(colorString, radix: 16);
  return intColor == null ? null : Color(intColor);
}
