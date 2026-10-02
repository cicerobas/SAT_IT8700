import 'dart:convert';

import 'package:sat_it8700/app/core/utils/json_reader.dart';

class TestStep {
  TestStep({
    required this.type,
    required this.description,
    required this.duration,
    required this.inputSource,
    required Map<String, int> params,
  }) : params = Map.unmodifiable(params);

  final int type;
  final String description;
  final double duration; // Em segundos
  final int inputSource; // índice
  final Map<String, int> params;

  TestStep copyWith({
    int? type,
    String? description,
    double? duration,
    int? inputSource,
    Map<String, int>? params,
  }) {
    return TestStep(
      type: type ?? this.type,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      inputSource: inputSource ?? this.inputSource,
      params: params ?? this.params,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'description': description,
      'duration': duration,
      'inputSource': inputSource,
      'params': Map<String, int>.of(params),
    };
  }

  factory TestStep.fromMap(Map<String, dynamic> map) =>
      TestStep.fromReader(JsonReader.from(map));

  factory TestStep.fromReader(JsonReader reader) {
    return TestStep(
      type: reader.integer('type'),
      description: reader.string('description'),
      duration: reader.number('duration', min: 0),
      inputSource: reader.integer('inputSource', min: 0),
      params: reader.mapOf<int>(
        'params',
        (v, p) => JsonReader.intValue(v, p, min: 0),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory TestStep.fromJson(String source) =>
      TestStep.fromReader(JsonReader.from(json.decode(source)));

  @override
  String toString() {
    return 'TestStep('
        'type: $type, '
        'description: $description, '
        'duration: $duration, '
        'inputSource: $inputSource, '
        'params: $params)';
  }
}
