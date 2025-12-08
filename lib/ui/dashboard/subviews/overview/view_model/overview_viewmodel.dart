import 'package:ephor/data/repositories/form/form_repository.dart';
import 'package:ephor/domain/models/overview/activity_model.dart';
import 'package:flutter/foundation.dart';

class OverviewViewModel extends ChangeNotifier {
  final FormRepository _formRepository;
  
  // Real data holders
  int _trainingNeedsCount = 0;
  int get trainingNeedsCount => _trainingNeedsCount;
  
  List<ActivityModel> _recentActivity = [];
  List<ActivityModel> get recentActivity => _recentActivity;

  OverviewViewModel({required FormRepository formRepository}) 
      : _formRepository = formRepository {
    _subscribeToUpdates();
  }

  void _subscribeToUpdates() {
    // Use a Supabase Stream to listen for changes in real-time
    // This way, when the background task finishes 3 mins later,
    // this view will automatically update without pulling to refresh.
    _formRepository.getOverviewStatsStream().listen((stats) {
      _trainingNeedsCount = stats['training_needs_count'];
      _recentActivity = stats['recent_activity'];
      notifyListeners();
    });
  }
}