import 'package:collection/collection.dart';

// Constants map
const Map<String, String> trainingMap = {
  "CK": "Orientation seminar on content-based knowledge (CK)",
  "FK": "Training on functional know-how (administration services - FK)",
  "SK": "Conceptual training on specialized topics (academic programs - SK)",
  "OS": "Practical/work-based skill trainings (organizational effectiveness - OS)",
  "FS": "Practical/work-based skill trainings (organizational effectiveness - FS)",
  "SMS": "Practical/work-based skill training (effective personal management - SMS)",
  "AW": "Trainings related to further development of attitude and work effectiveness (AW)",
  "ACW": "Trainings related to further development of attitude and work relationship (ACW)",
  "ACS": "Trainings related to further development of attitude and customer service (ACS)"
};

class CatnaCalculator {
  final List<String> components = trainingMap.keys.toList();

  List<Map<String, dynamic>> calculateIndividualMeans(List<Map<String, dynamic>> rawData) {
    return rawData.map((row) {
      var newRow = Map<String, dynamic>.from(row);
      for (var comp in components) {
        var compValues = row.entries
            .where((e) => e.key.startsWith(comp) && e.value is num)
            .map((e) => e.value as num);
        
        newRow["${comp}_Avg"] = compValues.isNotEmpty ? compValues.average : 0.0;
      }
      return newRow;
    }).toList();
  }

  List<Map<String, dynamic>> getOverallTop3(List<Map<String, dynamic>> data) {
    Map<String, List<double>> componentScores = {};
    for (var row in data) {
      for (var comp in components) {
        if (row.containsKey("${comp}_Avg")) {
          componentScores.putIfAbsent(comp, () => []).add(row["${comp}_Avg"]);
        }
      }
    }

    var sortedStats = componentScores.entries.map((e) {
      return {"key": e.key, "score": e.value.average};
    }).toList()
      ..sort((a, b) => (a['score'] as double).compareTo(b['score'] as double));

    return sortedStats.take(3).mapIndexed((index, e) {
      return {
        "Rank": index + 1,
        "Focus_Area_Component": e['key'],
        "Training_Recommendation": trainingMap[e['key']],
        "Mean_Score": double.parse((e['score'] as double).toStringAsFixed(2))
      };
    }).toList();
  }

  /// FIXED: Formats Focus strings for the UI, keeps Rating as Double
  List<Map<String, dynamic>> getGroupMeanPlans(List<Map<String, dynamic>> data, String groupCol) {
    var groups = groupBy(data, (row) => row[groupCol]);
    List<Map<String, dynamic>> results = [];

    groups.forEach((groupName, rows) {
      if (groupName == null) return;
      
      List<Map<String, dynamic>> groupCompScores = [];
      for (var comp in components) {
        var values = rows.map((r) => r["${comp}_Avg"] as double? ?? 0.0);
        groupCompScores.add({"comp": comp, "score": values.average});
      }

      groupCompScores.sort((a, b) => (a['score'] as double).compareTo(b['score'] as double));

      if (groupCompScores.length >= 3) {
        var top1 = groupCompScores[0];
        var top2 = groupCompScores[1];
        var top3 = groupCompScores[2];
        var overallRating = groupCompScores.map((e) => e['score'] as double).average;

        results.add({
          "Group_Name": groupName,
          // ENSURE DOUBLE: This matches GroupStatCard's `rating` type (double?)
          "Overall_Group_Rating": double.parse(overallRating.toStringAsFixed(2)), 
          
          // ENSURE STRING: This matches GroupStatCard's `primaryFocus` type (String?)
          "Primary_Focus_1": "${trainingMap[top1['comp']]} (${(top1['score'] as double).toStringAsFixed(2)})",
          "Secondary_Focus_2": "${trainingMap[top2['comp']]} (${(top2['score'] as double).toStringAsFixed(2)})",
          "Tertiary_Focus_3": "${trainingMap[top3['comp']]} (${(top3['score'] as double).toStringAsFixed(2)})",
        });
      }
    });

    return results;
  }

List<Map<String, dynamic>> getIndividualTrainingPlans(List<Map<String, dynamic>> data) {
    List<Map<String, dynamic>> plans = [];
    for (var row in data) {
      String? lowestComp;
      double minScore = 999.0;
      for (var comp in components) {
        var score = row["${comp}_Avg"];
        if (score is num && score < minScore) {
          minScore = score.toDouble();
          lowestComp = comp;
        }
      }
      if (lowestComp != null) {
        plans.add({
          "Name": row["Name"] ?? "N/A",
          "Position": row["Position"] ?? "N/A",
          "Office_College": row["Office/College"] ?? "N/A",
          "Overall_Rating": _calculateOverallRating(row), 
          "Lowest_Component": lowestComp,
          "Training_Recommendation": trainingMap[lowestComp] ?? "Unknown",
        });
      }
    }
    return plans;
  }

  double _calculateOverallRating(Map<String, dynamic> row) {
    List<double> scores = [];
    for (var comp in components) {
      if (row["${comp}_Avg"] is num) scores.add(row["${comp}_Avg"] as double);
    }
    return scores.isEmpty ? 0.0 : double.parse(scores.average.toStringAsFixed(2));
  }
}