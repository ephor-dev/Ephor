import 'package:intl/intl.dart'; // Ensure you have the intl package

List<Map<String, dynamic>> convertPayloadToAPIModel(Map<String, dynamic> payload) {
  // 1. Extract the main data blocks
  final identifyingData = payload['identifying_data'] as Map<String, dynamic>? ?? {};
  final ratings = payload['competency_ratings'] as Map<String, dynamic>? ?? {};
  final averages = ratings['averages'] as Map<String, dynamic>? ?? {};

  // 2. Helper to format dates from yyyy-MM-dd to MM/dd/yyyy
  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MM/dd/yyyy').format(date);
    } catch (e) {
      return dateStr; // Return original if parsing fails
    }
  }

  // 3. Prepare the flat row
  final row = <String, dynamic>{};

  // --- MAPPING IDENTIFYING DATA ---
  row['Name'] = identifyingData['full_name'] ?? '';
  row['Years in Current Position'] = identifyingData['years_in_current_position'] ?? '';
  row['Office/College'] = identifyingData['office'] ?? '';
  row['Supervisor Name'] = identifyingData['supervisor_name'] ?? ''; // Assuming this might exist
  // Note: Matches the typo in your CSV file "Assesment"
  row['Purpose of Assesment'] = identifyingData['purpose_of_assessment'] ?? '';
  row['Position'] = identifyingData['designation'] ?? '';
  row['Campus'] = identifyingData['operating_unit'] ?? '';

  // Combine dates for Review Period
  final start = formatDate(identifyingData['review_start_date']);
  final end = formatDate(identifyingData['review_end_date']);
  row['Review Period (mm/dd/yyyy-mm/dd/yyyy)'] = '$start - $end';

  row['Assessment Date (mm/dd/yyyy)'] = formatDate(identifyingData['assessment_date']);

  // Impact Assessment Parts

  if (payload['Training Plan'] != "") {
    row['Training Plan'] = payload['Training Plan'];
    row['Intervention Type'] = payload['Intervention Type'];
    row['Was the intervention beneficial to the personnel’s scope of work?'] = payload['Was the intervention beneficial to the personnel’s scope of work?'];
    row['Did the personnel incorporate the things they learned in the intervention into their work?'] = payload['Did the personnel incorporate the things they learned in the intervention into their work?'];
    row['Did you notice a significant change at your personnel’s perception, attitude or behavior as a result of the intervention?'] = payload['Did you notice a significant change at your personnel’s perception, attitude or behavior as a result of the intervention?'];
    row['Rate of the intervention’s overall impact to the efficiency of the personnel'] = payload['Rate of the intervention’s overall impact to the efficiency of the personnel'];
  }

  // --- MAPPING COMPETENCY RATINGS (Dynamic Bucket Logic) ---
  // We need to group questions by their code (CK, FK, SK, etc.) and sort them
  // to ensure 1.1 maps to CK1, 1.2 to CK2, etc.

  final Map<String, List<MapEntry<String, dynamic>>> buckets = {
    'CK': [], 'FK': [], 'SK': [],
    'OS': [], 'FS': [], 'SMS': [],
    'AW': [], 'ACW': [], 'ACS': []
  };

  // Helper to parse "1.1. (CK) Text..." -> extracts "CK" and "1.1"
  void processCategory(Map<String, dynamic>? categoryMap) {
    if (categoryMap == null) return;
    final regex = RegExp(r'(\d+\.\d+)\.\s*\(([A-Z]+)\)');

    categoryMap.forEach((key, value) {
      final match = regex.firstMatch(key);
      if (match != null) {
        final number = double.tryParse(match.group(1)!) ?? 0.0;
        final code = match.group(2)!;

        if (buckets.containsKey(code)) {
          buckets[code]!.add(MapEntry(key, {'val': value, 'num': number}));
        }
      }
    });
  }

  // Process all three categories
  processCategory(ratings['knowledge'] as Map<String, dynamic>?);
  processCategory(ratings['skills'] as Map<String, dynamic>?);
  processCategory(ratings['attitudes'] as Map<String, dynamic>?);

  // Sort buckets and assign to columns (e.g., CK1, CK2...)
  buckets.forEach((code, entries) {
    // Sort by the question number (1.1, 1.2, etc.)
    entries.sort((a, b) => (a.value['num'] as double).compareTo(b.value['num'] as double));

    for (int i = 0; i < entries.length; i++) {
      // Column name becomes CK1, CK2, etc.
      final columnName = '$code${i + 1}';
      row[columnName] = entries[i].value['val'];
    }
  });

  // --- MAPPING AVERAGES ---
  // Note: Keys match your CSV headers exactly (including trailing spaces)
  row['Knowledge Average Rating'] = averages['knowledge'];
  row['Skills Average Rating '] = averages['skills'];
  row['Attitude Average Rating '] = averages['attitude'];
  row['Overall (Knowledge, Skills & Attitude) Average Rating '] = averages['overall'];

  // Return as a list (since API models usually expect a list of records)
  return [row];
}