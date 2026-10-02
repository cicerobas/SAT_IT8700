/// Erro de ESTRUTURA/TIPO ao ler o JSON (campo ausente, tipo errado, fora da faixa).
class ModelParseException implements Exception {
  const ModelParseException(this.path, this.message);

  final String path;
  final String message;

  @override
  String toString() => path.isEmpty ? message : '$path: $message';
}

/// Erro de CONSISTÊNCIA entre campos (cada item da lista é um problema).
class ModelValidationException implements Exception {
  const ModelValidationException(this.problems);

  final List<String> problems;

  @override
  String toString() => problems.join('\n');
}
