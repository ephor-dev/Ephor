import 'package:ephor/data/repositories/catna/abstract_catna_repository.dart';
import 'package:ephor/data/services/supabase/supabase_service.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';

/// Repository for CATNA (Competency Assessment and Training Needs Analysis)
/// assessments. Wraps low-level Supabase calls in a simple Result API.
class CatnaRepository extends AbstractCATNARepository {
  final SupabaseService _supabaseService;
  Map<String, dynamic> identifyingData = {};
  Map<String, dynamic> competencyRatings = {};

  CatnaRepository({required SupabaseService supabaseService})
      : _supabaseService = supabaseService;

  @override
  Future<Result<void>> submitAssessment(Map<String, dynamic> payload) async {
    try {
      await _supabaseService.insertCatnaAssessment(payload);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to submit CATNA assessment: $e'),
      );
    }
  }
  
  @override
  Result<void> keepInMemoryIdentifyingData(Map<String, dynamic> data) {
    try {
      identifyingData = data;
      return Result.ok(null);
    } on Error {
      return Result.error(CustomMessageException("Can't save identifying data."));
    }
  }
  
  @override
  Result<void> keepInMemoryCompetencyRating(Map<String, dynamic> data) {
    try {
      competencyRatings = data;
      return Result.ok(null);
    } on Error {
      return Result.error(CustomMessageException("Can't save identifying data."));
    }
  }
}