import 'package:ephor/data/repositories/catna/abstract_catna_repository.dart';
import 'package:ephor/data/repositories/catna/catna_repository.dart';
import 'package:flutter/foundation.dart';

class CatnaForm2ViewModel extends ChangeNotifier {

  Map<String, dynamic>? _competencyRatings;
  Map<String, dynamic>? get competencyRatings => _competencyRatings;

  // Assessment response map: item text -> rating (1-4)
  final Map<String, int?> assessmentResponse = {};

  // Item lists (constants)
  final List<String> knowledgeItems = [
    '1.1. (CK) Manifests foundation knowledge in the performance of assigned tasks in the academic area or work area.',
    '1.2. (CK) Has basic knowledge required to successfully and accurately accomplish duties and tasks.',
    '1.3. (CK) Possesses taught and learned facts and principles from academic area or work area.',
    '1.4. (FK) Manifests knowledge on quality, safety and professional regulatory standards.',
    '1.5. (FK) Has know-how in following University policies, rules and standards.',
    '1.6. (FK) Possesses understanding of how to describe and implement the rules or step to follow instructions at work.',
    '1.7. (SK) Shows knowledge competence in the field of work OR academic specialization in theory/constructs.',
    '1.8. (SK) Has knowledge and understanding on concepts for a particular work purpose OR academic discipline resulted from training or from self-initiated development',
    '1.9. (SK) Possesses specialized knowledge in contributing concepts/frameworks/methodology for work OR academic purposes.',
  ];

  final List<String> skillsItems = [
    '2.1. (OS) Uses resources appropriately and conscientiously to avoid wastage.',
    '2.2. (OS) Maintains privacy and confidentiality as required.',
    '2.3. (OS) Shows ability in integrating own work strategies and activities with the University vision, mission and goals.',
    '2.4. (FS) When conflict arises, goes to the source of conflict to achieve the best possible resolution.',
    '2.5. (FS) Communicates the right information, in the right manner, to the right people (co-workers, customers & other stakeholders) at the right time.',
    '2.6. (FS) Exhibits skills required to successfully and accurately accomplish duties and tasks in a timely manner.',
    '2.7. (SMS) Works efficiently under pressure and is able to balance multiple priorities.',
    '2.8. (SMS) Shows the initiative to develop skills and enhance knowledge for better work performance.',
    '2.9. (SMS) Practices active listening skills and follows instructions accurately.',
  ];

  final List<String> attitudeItems = [
    '3.1. (AW) Meets expectations related to attendance, punctuality, breaks and attendance to the flag raisingceremony.',
    '3.2. (AW) Demonstrates appreciation of the University strategic direction and its pursuit to the institutional goals and objectives.',
    '3.3. (AW) Promotes excellence and continuous improvement at work surpassing standards of expectations.',
    '3.4. (ACW) Shares pertinent information and knowledge to assist co-workers.',
    '3.5. (ACW) Exhibits dependability in co-worker or team while observing business decorum and aprofessional approach at work.',
    '3.6. (ACW) Engages in co-worker/team in any and other collective activities organized by the department/college/University.',
    '3.7. (ACS) Shows service-oriented attitude in attending to the needs and requirement of customers and other stakeholders.',
    '3.8. (ACS) Demonstrates flexibility when dealing with customers and other stakeholders of different demographic profiles (e.g., minority, orientation, nationality, economic condition, etc.).',
    '3.9. (ACS) Represents the University in promoting its vision, mission and strategic direction in any customer and stakeholders transaction or engagement.',
  ];

  final AbstractCATNARepository _catnaRepository;

  CatnaForm2ViewModel({required CatnaRepository catnaRepository})
    : _catnaRepository = catnaRepository {
    _initializeResponseMap();
    _restoreFromShared();
  }

  void saveCompetencyRatings(Map<String, dynamic> data) async {
    // _competencyRatings = Map<String, dynamic>.from(data);
    await _catnaRepository.keepInMemoryCompetencyRating(Map<String, dynamic>.from(data));
    notifyListeners();
  }

  void _initializeResponseMap() {
    final allItems = [...knowledgeItems, ...skillsItems, ...attitudeItems];
    for (var item in allItems) {
      assessmentResponse[item] = null;
    }
  }

  /// Sets a rating for a specific item.
  void setRating(String item, int? rating) {
    assessmentResponse[item] = rating;
    notifyListeners();
  }

  /// Restores form state from the shared view model if data exists.
  void _restoreFromShared() {
    final saved = competencyRatings;
    if (saved == null) return;

    // Restore knowledge ratings
    final knowledge = saved['knowledge'] as Map<String, dynamic>?;
    if (knowledge != null) {
      for (final entry in knowledge.entries) {
        if (entry.value is int) {
          assessmentResponse[entry.key] = entry.value as int;
        }
      }
    }

    // Restore skills ratings
    final skills = saved['skills'] as Map<String, dynamic>?;
    if (skills != null) {
      for (final entry in skills.entries) {
        if (entry.value is int) {
          assessmentResponse[entry.key] = entry.value as int;
        }
      }
    }

    // Restore attitudes ratings
    final attitudes = saved['attitudes'] as Map<String, dynamic>?;
    if (attitudes != null) {
      for (final entry in attitudes.entries) {
        if (entry.value is int) {
          assessmentResponse[entry.key] = entry.value as int;
        }
      }
    }

    notifyListeners();
  }

  /// Extracts ratings for a specific category (knowledge/skills/attitudes).
  Map<String, int> extractRatings(List<String> items) {
    final map = <String, int>{};
    for (final item in items) {
      final value = assessmentResponse[item];
      if (value != null) {
        map[item] = value;
      }
    }
    return map;
  }

  /// Computes the average rating for a list of items.
  double computeAverage(List<String> items) {
    final values = <int>[];
    for (final item in items) {
      final value = assessmentResponse[item];
      if (value != null) {
        values.add(value);
      }
    }
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Validates that ALL competency ratings are filled.
  String? validateForm() {
    // Require ALL items in each category to be rated
    final totalKnowledgeItems = knowledgeItems.length;
    final totalSkillsItems = skillsItems.length;
    final totalAttitudeItems = attitudeItems.length;

    final knowledgeRated = knowledgeItems.where((item) => assessmentResponse[item] != null).length;
    final skillsRated = skillsItems.where((item) => assessmentResponse[item] != null).length;
    final attitudeRated = attitudeItems.where((item) => assessmentResponse[item] != null).length;

    // Check if all items in each category are rated
    if (knowledgeRated < totalKnowledgeItems) {
      final remaining = totalKnowledgeItems - knowledgeRated;
      return 'All knowledge competency items must be rated before proceeding. $remaining item(s) remaining.';
    }

    if (skillsRated < totalSkillsItems) {
      final remaining = totalSkillsItems - skillsRated;
      return 'All skills competency items must be rated before proceeding. $remaining item(s) remaining.';
    }

    if (attitudeRated < totalAttitudeItems) {
      final remaining = totalAttitudeItems - attitudeRated;
      return 'All attitude competency items must be rated before proceeding. $remaining item(s) remaining.';
    }

    return null; // All validations passed
  }

  /// Builds the competency ratings JSON map for saving to shared view model.
  Map<String, dynamic> buildCompetencyRatings() {
    final knowledgeRatings = extractRatings(knowledgeItems);
    final skillsRatings = extractRatings(skillsItems);
    final attitudeRatings = extractRatings(attitudeItems);

    final knowledgeAvg = computeAverage(knowledgeItems);
    final skillsAvg = computeAverage(skillsItems);
    final attitudeAvg = computeAverage(attitudeItems);
    final overallAvg = (knowledgeAvg + skillsAvg + attitudeAvg) / 3;

    return {
      'knowledge': knowledgeRatings,
      'skills': skillsRatings,
      'attitudes': attitudeRatings,
      'averages': {
        'knowledge': knowledgeAvg,
        'skills': skillsAvg,
        'attitude': attitudeAvg,
        'overall': overallAvg,
      },
    };
  }
}