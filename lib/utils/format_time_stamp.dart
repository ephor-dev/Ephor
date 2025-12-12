import 'package:intl/intl.dart';

String formatTimestamp(String input) {
  // 1. Parse directly using DateTime.parse (Handles ISO 8601 automatically)
  // Input: "2025-12-10T10:53:18.240668+00:00"
  final dt = DateTime.parse(input);

  final formatted = DateFormat("hh:mm:ss a dd MMMM yyyy").format(dt);

  return formatted;
}