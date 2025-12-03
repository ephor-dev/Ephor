import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/data/repositories/catna/catna_repository.dart';
import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for CATNA Form 3 (Individual Training Plan) and final submission.
///
class CatnaForm3ViewModel extends ChangeNotifier {
  final CatnaRepository _catnaRepository;
  final AuthRepository _authRepository;

  CatnaForm3ViewModel({
    required CatnaRepository catnaRepository,
    required AuthRepository authRepository,
  })  : _catnaRepository = catnaRepository,
        _authRepository = authRepository;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  /// Check if the current user has permission to submit CATNA assessments
  bool get canSubmitAssessment {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) return false;
    return currentUser.role == EmployeeRole.humanResource ||
           currentUser.role == EmployeeRole.supervisor;
  }

  /// Validates that all required data from all forms is present.
  String? validateAllForms({
    required Map<String, dynamic>? identifyingData,
    required Map<String, dynamic>? competencyRatings,
    required Map<String, dynamic> trainingNeeds,
    required Map<String, dynamic> quarterPlans,
  }) {
    // Validate Form 1 data
    if (identifyingData == null ||
        identifyingData['first_name']?.toString().trim().isEmpty == true ||
        identifyingData['last_name']?.toString().trim().isEmpty == true ||
        identifyingData['designation'] == null ||
        identifyingData['office'] == null ||
        identifyingData['operating_unit'] == null ||
        identifyingData['years_in_current_position'] == null ||
        identifyingData['review_start_date'] == null ||
        identifyingData['review_end_date'] == null ||
        identifyingData['assessment_date'] == null ||
        identifyingData['purpose_of_assessment'] == null) {
      return 'All fields in Form 1 must be filled before submitting';
    }

    // Validate Form 2 data - ALL items must be rated
    if (competencyRatings == null) {
      return 'All competency ratings in Form 2 must be completed before submitting';
    }

    final knowledgeRatings = competencyRatings['knowledge'] as Map<String, dynamic>? ?? {};
    final skillsRatings = competencyRatings['skills'] as Map<String, dynamic>? ?? {};
    final attitudeRatings = competencyRatings['attitudes'] as Map<String, dynamic>? ?? {};

    // Each category should have exactly 9 items rated (all competency items)
    const expectedItemsPerCategory = 9;
    if (knowledgeRatings.length < expectedItemsPerCategory ||
        skillsRatings.length < expectedItemsPerCategory ||
        attitudeRatings.length < expectedItemsPerCategory) {
      return 'All competency items in Form 2 must be rated before submitting. Each category requires $expectedItemsPerCategory ratings.';
    }

    // Validate Form 3 data - Training Needs (require at least one selection per category)
    final knowledgeNeeds = trainingNeeds['knowledge'] as List<dynamic>? ?? [];
    final skillsNeeds = trainingNeeds['skills'] as List<dynamic>? ?? [];
    final attitudeNeeds = trainingNeeds['attitudes'] as List<dynamic>? ?? [];

    if (knowledgeNeeds.isEmpty || skillsNeeds.isEmpty || attitudeNeeds.isEmpty) {
      final missingCategories = <String>[];
      if (knowledgeNeeds.isEmpty) missingCategories.add('Knowledge');
      if (skillsNeeds.isEmpty) missingCategories.add('Skills');
      if (attitudeNeeds.isEmpty) missingCategories.add('Attitude');

      return 'Training needs must be selected for all categories in Form 3 before submitting. Missing: ${missingCategories.join(', ')}';
    }

    // Validate Form 3 data - Quarter Plans (require at least one category per quarter)
    int quartersWithPlans = 0;
    for (final quarter in ['q1', 'q2', 'q3', 'q4']) {
      final quarterData = quarterPlans[quarter] as Map<String, dynamic>?;
      if (quarterData != null) {
        final categories = quarterData['categories'] as Map<String, dynamic>? ?? {};
        if (categories['mandatory'] == true ||
            categories['knowledge_based'] == true ||
            categories['skill_based'] == true ||
            categories['attitudinal_based'] == true) {
          quartersWithPlans++;
        }
      }
    }

    if (quartersWithPlans < 2) {
      return 'At least 2 quarters must have training plans configured in Form 3 before submitting. Currently configured: $quartersWithPlans quarter(s).';
    }

    return null; // All validations passed
  }

  /// Expects a payload shaped like:
  /// {
  ///   'employee_code': 'current-user-employee-code',
  ///   'identifying_data': {...},
  ///   'competency_ratings': {...},
  ///   'training_needs': {...},
  ///   'quarter_plans': {...},
  /// }
  Future<Result<void>> submitCatna(Map<String, dynamic> payload) async {
    if (_isSubmitting) {
      return const Result.ok(null);
    }

    _isSubmitting = true;
    notifyListeners();

    // Check user authentication
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      _isSubmitting = false;
      notifyListeners();
      return Result.error(CustomMessageException('User authentication required. Please log in again.'));
    }

    // Check role-based permissions for CATNA submission
    if (!canSubmitAssessment) {
      _isSubmitting = false;
      notifyListeners();
      return Result.error(CustomMessageException(
        'You do not have permission to submit CATNA assessments. Only HR and Supervisors can submit assessments.'
      ));
    }

    payload['employee_code'] = currentUser.employeeCode;

    final result = await _catnaRepository.submitAssessment(payload);

    _isSubmitting = false;
    notifyListeners();

    return result;
  }
}
