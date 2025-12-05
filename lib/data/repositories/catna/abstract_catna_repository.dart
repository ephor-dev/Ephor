import 'package:flutter/foundation.dart';
import 'package:ephor/utils/results.dart';

abstract class AbstractCATNARepository extends ChangeNotifier {
  Future<Result<void>> submitAssessment(Map<String, dynamic> payload);
  Future<Result<void>> keepInMemoryIdentifyingData(Map<String, dynamic> data);
  Future<Result<void>> keepInMemoryCompetencyRating(Map<String, dynamic> data);
}