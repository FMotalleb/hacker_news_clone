class ParserException implements Exception {
  ParserException(
    this.message,
  );
  final String message;
  @override
  String toString() {
    return 'ParserException: $message';
  }
}
