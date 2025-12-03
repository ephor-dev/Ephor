import 'package:flutter/foundation.dart';

/// Shared CATNA form state across Forms 1 and 2.
///
/// This ViewModel stores the JSON that will later be merged with Form 3 data
/// and sent to Supabase via `CatnaForm3ViewModel`.
class CatnaFormSharedViewModel extends ChangeNotifier {
  Map<String, dynamic>? _identifyingData;
  Map<String, dynamic>? _competencyRatings;

  Map<String, dynamic>? get identifyingData => _identifyingData;
  Map<String, dynamic>? get competencyRatings => _competencyRatings;

  void saveIdentifyingData(Map<String, dynamic> data) {
    _identifyingData = Map<String, dynamic>.from(data);
    notifyListeners();
  }

  void saveCompetencyRatings(Map<String, dynamic> data) {
    _competencyRatings = Map<String, dynamic>.from(data);
    notifyListeners();
  }
}


