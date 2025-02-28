class CustomException implements Exception {
  final String title;
  final String message;

  const CustomException({
    required this.title,
    required this.message,
  });

  @override
  String toString() {
    return message;
  }
}
