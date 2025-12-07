import 'package:flutter/foundation.dart';
import 'package:ephor/utils/results.dart';

abstract class AbstractCATNARepository extends ChangeNotifier {
  Future<Result<void>> submitAssessment(Map<String, dynamic> payload);
}