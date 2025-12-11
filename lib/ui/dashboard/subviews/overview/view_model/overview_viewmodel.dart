import 'package:ephor/data/repositories/form/form_repository.dart';
import 'package:ephor/domain/models/overview/activity_model.dart';
import 'package:ephor/utils/format_time_stamp.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/foundation.dart';

class OverviewViewModel extends ChangeNotifier {
  final FormRepository _formRepository;
  
  // 1. Data Source for Counts
  int _trainingNeedsCount = 0;
  int get trainingNeedsCount => _trainingNeedsCount;
  
  // 2. Data Source for Lists (Activity)
  List<ActivityModel> _recentActivity = [];
  List<ActivityModel> get recentActivity => _recentActivity;

  // 3. Data Source for Detailed Analysis (The JSON Report)
  Map<String, dynamic>? _fullReport;
  Map<String, dynamic>? get fullReport => _fullReport;

  String _lastUpdate = "";
  String get lastUpdate => _lastUpdate;

  String _geminiInsights = "";
  String get geminiInsights => _geminiInsights;

  OverviewViewModel({required FormRepository formRepository}) 
      : _formRepository = formRepository {
    _subscribeToUpdates();

    _loadData();
  }

  void _subscribeToUpdates() {
    // Use a Supabase Stream to listen for changes in real-time
    _formRepository.getOverviewStatsStream().listen((stats) {
      if (stats.isEmpty) return;

      // Update basic integer counts
      _trainingNeedsCount = stats['training_needs_count'] ?? 0;

      // Update the full report JSON (used for Strategic Priorities UI)
      _fullReport = stats['full_report'];

      // Update Activity List
      // Note: Supabase returns a List<dynamic> of Maps. We must convert them to Models.
      _recentActivity = stats['recent_activity'] as List<ActivityModel>? ?? [];
      _lastUpdate = formatTimestamp(stats['updated_at']);
      _geminiInsights = stats['gemini_insights'];

      notifyListeners();
    });
  }

  void _loadData() async {
    final result = await _formRepository.getOverviewStats();

    if (result case Ok(value: Map<String, dynamic> stats)) {
      _loadStats(stats);
    }
  }

  void _loadStats(Map<String, dynamic> stats) {
    if (stats.isEmpty) return;

      // Update basic integer counts
      _trainingNeedsCount = stats['training_needs_count'] ?? 0;

      // Update the full report JSON (used for Strategic Priorities UI)
      _fullReport = stats['full_report'];

      // Update Activity List
      // Note: Supabase returns a List<dynamic> of Maps. We must convert them to Models.
      _recentActivity = stats['recent_activity'] as List<ActivityModel>? ?? [];
      _lastUpdate = formatTimestamp(stats['updated_at']);
      _geminiInsights = stats['gemini_insights'];

      notifyListeners();
  }
}