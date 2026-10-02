import 'dart:convert';

import 'package:sat_it8700/app/core/exceptions.dart';
import 'package:sat_it8700/app/core/utils/json_reader.dart';
import 'package:sat_it8700/app/data/models/test_step.dart';

typedef ParamsMap = Map<String, List<double>>;

class TestTemplate {
  TestTemplate({
    required this.group,
    required this.model,
    required this.customer,
    required this.inputType,
    required List<int> inputSources,
    required this.channelCount,
    required List<String> channelLabels,
    required ParamsMap params,
    required List<TestStep> steps,
  }) : inputSources = List.unmodifiable(inputSources),
       channelLabels = List.unmodifiable(channelLabels),
       params = Map.unmodifiable({
         for (final entry in params.entries)
           entry.key: List<double>.unmodifiable(entry.value),
       }),
       steps = List.unmodifiable(steps);

  final String group;
  final String model;
  final String customer;
  final String inputType;
  final List<int> inputSources;
  final int channelCount;
  final List<String> channelLabels;
  final ParamsMap params;
  final List<TestStep> steps;

  static const _stepParamSource = <String, String>{
    'VL': 'V',
    'VH': 'V',
    'V': 'V',
    'I': 'I',
    'IL': 'I',
    'IH': 'I',
  };

  /// Devolve todos os problemas encontrados (lista vazia = template ok).
  List<String> validate() {
    final problems = <String>[];

    if (inputType != "CC" && inputType != "CA") {
      problems.add("inputType inválido, valores permitidos: [CC, CA]");
    }

    if (channelLabels.length != channelCount) {
      problems.add(
        'channelCount ($channelCount) não bate com a quantidade de '
        'channelLabels (${channelLabels.length})',
      );
    }

    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final stepAt = 'steps[$i]';

      if (step.inputSource >= inputSources.length) {
        problems.add(
          '$stepAt.inputSource: índice ${step.inputSource} inválido '
          '(inputSources tem ${inputSources.length} itens, '
          'índices de 0 a ${inputSources.length - 1})',
        );
      }

      for (final param in step.params.entries) {
        final sourceKey = _stepParamSource[param.key];
        if (sourceKey == null) continue;

        final values = params[sourceKey];
        if (values == null) {
          problems.add(
            '$stepAt.params.${param.key}: o template não define params.$sourceKey',
          );
        } else if (param.value >= values.length) {
          problems.add(
            '$stepAt.params.${param.key}: índice ${param.value} fora de params.$sourceKey '
            '(${values.length} valores, índices de 0 a ${values.length - 1})',
          );
        }
      }
    }

    return problems;
  }

  TestTemplate copyWith({
    String? group,
    String? model,
    String? customer,
    String? inputType,
    List<int>? inputSources,
    int? channelCount,
    List<String>? channelLabels,
    ParamsMap? params,
    List<TestStep>? steps,
  }) {
    return TestTemplate(
      group: group ?? this.group,
      model: model ?? this.model,
      customer: customer ?? this.customer,
      inputType: inputType ?? this.inputType,
      inputSources: inputSources ?? this.inputSources,
      channelCount: channelCount ?? this.channelCount,
      channelLabels: channelLabels ?? this.channelLabels,
      params: params ?? this.params,
      steps: steps ?? this.steps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'group': group,
      'model': model,
      'customer': customer,
      'inputType': inputType,
      'inputSources': List<int>.of(inputSources),
      'channelCount': channelCount,
      'channelLabels': List<String>.of(channelLabels),
      'params': {
        for (final e in params.entries) e.key: List<double>.of(e.value),
      },
      'steps': steps.map((x) => x.toMap()).toList(),
    };
  }

  /// Só estrutura e tipos (lança [ModelParseException]). Não roda [validate].
  factory TestTemplate.fromMap(Map<String, dynamic> map) {
    final reader = JsonReader.from(map);

    return TestTemplate(
      group: reader.string('group'),
      model: reader.string('model'),
      customer: reader.string('customer', allowEmpty: true),
      inputType: reader.string('inputType'),
      inputSources: reader.list<int>(
        'inputSources',
        JsonReader.intValue,
        minLength: 1,
      ),
      channelCount: reader.integer('channelCount', min: 1),
      channelLabels: reader.list<String>(
        'channelLabels',
        JsonReader.stringValue,
      ),
      params: reader.mapOf<List<double>>(
        'params',
        (v, p) => JsonReader.listValue<double>(
          v,
          p,
          JsonReader.doubleValue,
          minLength: 1,
        ),
      ),
      steps: reader.list<TestStep>(
        'steps',
        (v, p) => TestStep.fromReader(JsonReader.from(v, p)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  /// Lê o texto do arquivo. Pode lançar:
  /// - [ModelParseException]: JSON inválido, campo ausente, tipo errado...
  /// - [ModelValidationException]: campos ok, mas inconsistentes entre si
  ///   (só se [strict] for true).
  factory TestTemplate.fromJson(String source, {bool strict = true}) {
    final text = source.startsWith('\uFEFF') ? source.substring(1) : source;

    final Object? decoded;
    try {
      decoded = json.decode(text);
    } on FormatException catch (e) {
      final offset = e.offset?.clamp(0, text.length);
      final line = offset == null
          ? null
          : '\n'.allMatches(text.substring(0, offset)).length + 1;
      throw ModelParseException(
        '',
        'JSON inválido${line == null ? '' : ' (linha $line)'}: ${e.message}',
      );
    }

    if (decoded is! Map) {
      throw const ModelParseException(
        '',
        'o arquivo deve conter um objeto JSON na raiz',
      );
    }

    final template = TestTemplate.fromMap(Map<String, dynamic>.from(decoded));

    if (strict) {
      final problems = template.validate();
      if (problems.isNotEmpty) throw ModelValidationException(problems);
    }
    return template;
  }

  @override
  String toString() {
    return 'TestTemplate('
        'group: $group, '
        'model: $model, '
        'customer: $customer, '
        'inputType: $inputType, '
        'inputSources: $inputSources, '
        'channelCount: $channelCount, '
        'channelLabels: $channelLabels, '
        'params: $params, '
        'steps: $steps)';
  }
}
