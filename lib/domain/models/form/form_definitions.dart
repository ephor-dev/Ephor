import 'dart:convert';

enum FormInputType { text, number, date, dropdown, radioMatrix, radio, header, unknown }
enum SectionLayout { standard, matrix, impactStyle } 

class FormOption {
  final String label;
  final dynamic value;
  FormOption({required this.label, required this.value});

  factory FormOption.fromJson(Map<String, dynamic> json) {
    return FormOption(
      label: json['label'].toString(),
      value: json['value'],
    );
  }
}

class FormItem {
  final String key;
  final String label;
  final FormInputType type;
  final bool required;
  final int orderIndex;
  final Map<String, dynamic> config;
  final List<FormOption>? options;

  FormItem({
    required this.key,
    required this.label,
    required this.type,
    this.required = true,
    this.orderIndex = 0,
    this.config = const {},
    this.options,
  });

  factory FormItem.fromJson(Map<String, dynamic> json) {
    // 1. Generate a valid key
    final String qText = json['question_text'] ?? 'unknown_field';
    final String generatedKey = qText.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    
    // 2. Parse Type safely
    FormInputType parseType(String? t) {
      switch (t?.toLowerCase()) {
        case 'text': return FormInputType.text;
        case 'number': return FormInputType.number;
        case 'date': return FormInputType.date;
        case 'dropdown': return FormInputType.dropdown;
        case 'radiomatrix': return FormInputType.radioMatrix;
        case 'header': return FormInputType.header;
        case 'radio': return FormInputType.radio;
        default: return FormInputType.unknown;
      }
    }

    // 3. THE FIX: Safe Options Parsing Helper
    List<FormOption>? parseOptions(dynamic value) {
      if (value == null) return null;
      
      List<dynamic> rawList = [];

      // If DB sends a String (JSON encoded), decode it first
      if (value is String) {
        if (value.isEmpty) return [];
        try {
          rawList = jsonDecode(value);
        } catch (e) {
          print('Error decoding options in FormItem: $e');
          return [];
        }
      } 
      // If DB sends a List (Raw JSON), use it directly
      else if (value is List) {
        rawList = value;
      }

      // Convert the raw list into FormOption objects
      return rawList.map((e) => FormOption.fromJson(e as Map<String, dynamic>)).toList();
    }

    return FormItem(
      key: generatedKey, 
      label: qText,
      type: parseType(json['type']),
      required: json['is_required'] ?? false,
      orderIndex: json['order_index'] ?? 0,
      config: json['config'] ?? {},
      
      // USE THE HELPER HERE
      options: parseOptions(json['options']), 
    );
  }
}

class FormSection {
  final String title;
  final String? description;
  final SectionLayout layout;
  final List<FormItem> items;

  FormSection({
    required this.title,
    this.description,
    required this.layout,
    required this.items,
  });

  factory FormSection.fromJson(Map<String, dynamic> json) {
    // Determine layout based on title/content logic if DB doesn't have a layout column
    // For now, we default to standard. You can add logic: if title contains "Rating", use matrix.
    SectionLayout detectedLayout = SectionLayout.standard;
    if (json['layout'] == 'impact_style') {
      detectedLayout = SectionLayout.impactStyle;
    } else if (json['title'].toString().contains('Rating')) {
      detectedLayout = SectionLayout.matrix;
    }

    // MAP "questions" to "items"
    var questionsList = json['questions'] as List? ?? [];
    
    // Sort items by order_index just in case DB sends them out of order
    var parsedItems = questionsList.map((e) => FormItem.fromJson(e)).toList();
    parsedItems.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return FormSection(
      title: json['title'] ?? '',
      description: json['description'],
      layout: detectedLayout,
      items: parsedItems,
    );
  }
}