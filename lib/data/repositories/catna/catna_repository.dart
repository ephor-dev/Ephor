import 'package:ephor/data/services/supabase/supabase_service.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';

/// Repository for CATNA (Competency Assessment and Training Needs Analysis)
/// assessments. Wraps low-level Supabase calls in a simple Result API.
class CatnaRepository {
  final SupabaseService _supabaseService;

  CatnaRepository({required SupabaseService supabaseService})
      : _supabaseService = supabaseService;

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
}


