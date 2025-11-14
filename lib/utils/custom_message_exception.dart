class CustomMessageException implements Exception {
  final String message;

  CustomMessageException(this.message);
  
  @override
  String toString() {
    return 'Exception: $message';
  }
}