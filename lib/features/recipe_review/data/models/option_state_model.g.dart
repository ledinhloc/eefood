// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionStateModel _$OptionStateModelFromJson(Map<String, dynamic> json) =>
    OptionStateModel(
      optionId: (json['optionId'] as num?)?.toInt(),
      content: json['content'] as String?,
      count: (json['count'] as num?)?.toInt(),
      percent: (json['percent'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$OptionStateModelToJson(OptionStateModel instance) =>
    <String, dynamic>{
      'optionId': instance.optionId,
      'content': instance.content,
      'count': instance.count,
      'percent': instance.percent,
    };
