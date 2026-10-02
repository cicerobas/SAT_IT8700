import 'package:sat_it8700/app/core/exceptions.dart';

typedef ItemParser<T> = T Function(Object? value, String path);

class JsonReader {
  JsonReader._(this._map, this.path);

  factory JsonReader.from(Object? raw, [String path = '']) {
    if (raw is! Map) throw _typeError(path, 'objeto', raw);
    return JsonReader._({
      for (final entry in raw.entries) '${entry.key}': entry.value,
    }, path);
  }

  final Map<String, dynamic> _map;
  final String path;

  // Conversores

  static String stringValue(
    Object? value,
    String path, {
    bool allowEmpty = false,
  }) {
    if (value is! String) throw _typeError(path, 'texto', value);
    if (!allowEmpty && value.trim().isEmpty) {
      throw ModelParseException(path, 'o texto não pode ficar vazio');
    }
    return value;
  }

  static int intValue(Object? value, String path, {int? min, int? max}) {
    if (value is! num || !value.isFinite || value != value.truncateToDouble()) {
      throw _typeError(path, 'número inteiro', value);
    }
    final valueAsInt = value.toInt();
    _checkRange(path, valueAsInt, min, max);
    return valueAsInt;
  }

  static double doubleValue(
    Object? value,
    String path, {
    double? min,
    double? max,
  }) {
    if (value is! num || !value.isFinite) {
      throw _typeError(path, 'número', value);
    }
    final valueAsDouble = value.toDouble();
    _checkRange(path, valueAsDouble, min, max);
    return valueAsDouble;
  }

  static List<T> listValue<T>(
    Object? value,
    String path,
    ItemParser<T> parse, {
    int minLength = 0,
  }) {
    if (value is! List) throw _typeError(path, 'lista', value);
    if (value.length < minLength) {
      throw ModelParseException(
        path,
        'precisa ter pelo menos $minLength item(ns), mas tem ${value.length}',
      );
    }
    return [
      for (var i = 0; i < value.length; i++) parse(value[i], '$path[$i]'),
    ];
  }

  // Leitura por chave

  String string(String key, {bool allowEmpty = false}) =>
      stringValue(_required(key), _at(key), allowEmpty: allowEmpty);

  int integer(String key, {int? min, int? max}) =>
      intValue(_required(key), _at(key), min: min, max: max);

  double number(String key, {double? min, double? max}) =>
      doubleValue(_required(key), _at(key), min: min, max: max);

  List<T> list<T>(String key, ItemParser<T> parse, {int minLength = 0}) =>
      listValue<T>(_required(key), _at(key), parse, minLength: minLength);

  Map<String, T> mapOf<T>(String key, ItemParser<T> parse) {
    final obj = JsonReader.from(_required(key), _at(key));
    return {
      for (final entry in obj._map.entries)
        entry.key: parse(entry.value, obj._at(entry.key)),
    };
  }

  // Internos
  String _at(String key) => path.isEmpty ? key : '$path.$key';

  Object _required(String key) {
    final value = _map[key];
    if (value == null) {
      throw ModelParseException(
        _at(key),
        _map.containsKey(key) ? 'valor nulo' : 'campo obrigatório ausente',
      );
    }
    return value;
  }

  static void _checkRange(String path, num value, num? min, num? max) {
    if (min != null && value < min) {
      throw ModelParseException(
        path,
        'valor $value é menor que o mínimo ($min)',
      );
    }
    if (max != null && value > max) {
      throw ModelParseException(
        path,
        'valor $value é maior que o máximo ($max)',
      );
    }
  }

  static ModelParseException _typeError(
    String path,
    String expected,
    Object? value,
  ) => ModelParseException(
    path,
    'esperado $expected, mas veio ${_describe(value)}',
  );

  static String _describe(Object? value) {
    if (value == null) return 'nulo';
    if (value is String) {
      final short = value.length > 15 ? '${value.substring(0, 15)}...' : value;
      return 'texto "$short"';
    }
    if (value is bool) return 'booleano ($value)';
    if (value is num) return 'número ($value)';
    if (value is List) return 'lista';
    if (value is Map) return 'objeto';
    return value.runtimeType.toString();
  }
}
