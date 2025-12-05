import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/catna_form/view_models/catna_form3_viewmodel.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CatnaForm3View extends StatefulWidget {
  final CatnaForm3ViewModel viewModel;
  const CatnaForm3View({super.key, required this.viewModel});

  @override
  State<CatnaForm3View> createState() => _CatnaForm3ViewState();
}

class _CatnaForm3ViewState extends State<CatnaForm3View> {
  final List<bool> _knowledgeCheckStates = List.generate(4, (index) => false);
  final List<bool> _skillCheckStates = List.generate(4, (index) => false);
  final List<bool> _attitudeCheckStates = List.generate(4, (index) => false);
  final List<bool> _categoryCheckStatesQ1   = List.generate(4, (index) => false);
  final List<bool> _categoryCheckStatesQ2 = List.generate(4, (index) => false);
  final List<bool> _categoryCheckStatesQ3 = List.generate(4, (index) => false);
  final List<bool> _categoryCheckStatesQ4 = List.generate(4, (index) => false);

  int _selectedYear = DateTime.now().year;
  final List<int> _years = List<int>.generate(
    10,
    (index) => DateTime.now().year - 5 + index,
  );

  @override
  Widget build(BuildContext context) {
    const double cornerRadius = 8;
    const double panelSpacing = 8;
    const double fontsizeSize1 = 14;
    const double spacing1 = 16;
    const double spacing2 = 8;
    const double spacing3 = 4;
    const double buttonSpacing = 24;

    final List<String> knowledgeTrainingItems = [
      'Needs orientation seminar on content-based knowledge',
      'Needs conceptual training on specialized topics related to academic programs',
      'Needs training on functional know-how relating to administration services',
      'Needs other learning and development intervention (e.g. coaching, counselling, mentoring, job rotation, etc.)',
    ];

    final List<String> skillTrainingItems = [
      'Needs practical/work-based skill trainings related to academic programs',
      'Needs practical/work-based skill trainings related to organizational effectiveness (e.g. teamwork, problem-solving, conflict resolution, etc.)',
      'Needs practical/work-based skill training related to effective personal management (e.g. time & stress management, communication, etc.)',
      'Needs other learning and development intervention (e.g. coaching, counselling, mentoring, job rotation, etc.)',
    ];

    final List<String> attitudeTrainingItems = [
      'Needs conceptual and/or work-based trainings related to further development of attitude and work effectiveness',
      'Needs conceptual and/or work-based trainings related to further development of attitude and work relationship',
      'Needs conceptual and/or work-based trainings related to further development of attitude and customer service',
      'Needs other learning and development intervention (e.g. coaching, counselling, mentoring, job rotation, etc.)',
    ];

    final List<String> categoryItems = [
      'Mandatory',
      'Knowledge Based',
      'Skill Based',
      'Attitudinal Based',
    ];

    return Scaffold(
      backgroundColor: Color.alphaBlend(
        Theme.of(context).colorScheme.onSurface.withAlpha(50), 
        Theme.of(context).colorScheme.surfaceContainerLowest
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  height: 20,
                  width: 640,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary, 
                        Theme.of(context).colorScheme.tertiaryFixed
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(cornerRadius),
                      topRight: Radius.circular(cornerRadius),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  height: 160,
                  width: 640,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(cornerRadius),
                      bottomRight: Radius.circular(cornerRadius),
                    ),
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  ),
                  child: Center(
                    child: Text(
                      'Competency Assessment and Training\n Needs Analysis',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: panelSpacing),
              Center(
                child: Container(
                  width: 640,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.all(
                      Radius.circular(cornerRadius),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'III. Individual Training Plan',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: fontsizeSize1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Instructions: Read each item per SCOPE Area and assess the Personnel.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: fontsizeSize1,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: panelSpacing),
              Center(
                child: Container(
                  height: 40,
                  width: 640,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(cornerRadius),
                    ),
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'A. Training Needs',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: fontsizeSize1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: panelSpacing),
              Center(
                child: Container(
                  width: 640,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(cornerRadius),
                    ),
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: panelSpacing),
                        Align(
                          alignment: AlignmentGeometry.center,
                          child: Text(
                            'KNOWLEDGE BASED TRAINING NEEDS',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing1),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLowest,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary, 
                                Theme.of(context).colorScheme.tertiaryFixed
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing2),
                        ...List.generate(knowledgeTrainingItems.length, (
                          index,
                        ) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _knowledgeCheckStates[index],
                                    onChanged: (v) {
                                      setState(() {
                                        _knowledgeCheckStates[index] = v!;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      knowledgeTrainingItems[index],
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: fontsizeSize1,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: spacing2),
                            ],
                          );
                        }),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLowest,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary, 
                                Theme.of(context).colorScheme.tertiaryFixed
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing2),
                        Align(
                          alignment: AlignmentGeometry.center,
                          child: Text(
                            'SKILLS BASED TRAINING NEEDS',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing2),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLowest,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary, 
                                Theme.of(context).colorScheme.tertiaryFixed
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing1),
                        ...List.generate(skillTrainingItems.length, (index) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _skillCheckStates[index],
                                    onChanged: (v) {
                                      setState(() {
                                        _skillCheckStates[index] = v!;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      skillTrainingItems[index],
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: fontsizeSize1,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: spacing2),
                            ],
                          );
                        }),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLowest,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary, 
                                Theme.of(context).colorScheme.tertiaryFixed
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing2),
                        Align(
                          alignment: AlignmentGeometry.center,
                          child: Text(
                            'ATTITUDINAL BASED TRAINING NEEDS',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing2),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLowest,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary, 
                                Theme.of(context).colorScheme.tertiaryFixed
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing1),
                        ...List.generate(attitudeTrainingItems.length, (
                          index,
                        ) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _attitudeCheckStates[index],
                                    onChanged: (v) {
                                      setState(() {
                                        _attitudeCheckStates[index] = v!;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      attitudeTrainingItems[index],
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: fontsizeSize1,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: spacing2),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: panelSpacing),

              Center(
                child: Container(
                  height: 40,
                  width: 640,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(cornerRadius),
                    ),
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Specific Training Needs',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: fontsizeSize1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: panelSpacing),
              Center(
                child: Container(
                  width: 640,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(cornerRadius),
                    ),
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(height: spacing2),
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: SizedBox(
                              width: 160,
                              child: DropdownButtonFormField<int>(
                                initialValue: _selectedYear,
                                decoration: const InputDecoration(
                                  labelText: 'Timeline Year',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 0,
                                  ),
                                ),
                                items: _years.map((int year) {
                                  return DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    _selectedYear = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing2),
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            'Q1 JANUARY - MARCH',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: spacing2),
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            'Training Title/Topic',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: spacing2),
                        const TextField(
                          decoration: InputDecoration(
                            labelText: 'Training Title / Topic',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(width: spacing1),
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            'Category',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: spacing3,
                          runSpacing: spacing3,
                          children: List.generate(categoryItems.length, (
                            index,
                          ) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _categoryCheckStatesQ1[index],
                                  onChanged: (v) {
                                    setState(() {
                                      _categoryCheckStatesQ1[index] = v!;
                                    });
                                  },
                                ),
                                Text(
                                  categoryItems[index],
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: fontsizeSize1,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                        const SizedBox(height: spacing2),
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            'Q2 APRIL - JUNE',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: spacing2),
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            'Training Title/Topic',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: spacing2),
                        const TextField(
                          decoration: InputDecoration(
                            labelText: 'Training Title / Topic',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(width: spacing1),
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            'Category',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: spacing3,
                          runSpacing: spacing3,
                          children: List.generate(categoryItems.length, (
                            index,
                          ) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _categoryCheckStatesQ2[index],
                                  onChanged: (v) {
                                    setState(() {
                                      _categoryCheckStatesQ2[index] = v!;
                                    });
                                  },
                                ),
                                Text(
                                  categoryItems[index],
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: fontsizeSize1,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                        const SizedBox(height: spacing2),
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            'Q3 JULY - SEPTEMBER',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: spacing2),
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            'Training Title/Topic',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: spacing2),
                        const TextField(
                          decoration: InputDecoration(
                            labelText: 'Training Title / Topic',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(width: spacing1),
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            'Category',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: spacing3,
                          runSpacing: spacing3,
                          children: List.generate(categoryItems.length, (
                            index,
                          ) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _categoryCheckStatesQ3[index],
                                  onChanged: (v) {
                                    setState(() {
                                      _categoryCheckStatesQ3[index] = v!;
                                    });
                                  },
                                ),
                                Text(
                                  categoryItems[index],
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: fontsizeSize1,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                        const SizedBox(height: spacing2),
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            'Q4 OCTOBER - DECEMBER',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: spacing2),
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            'Training Title/Topic',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: spacing1),
                        const TextField(
                          decoration: InputDecoration(
                            labelText: 'Training Title / Topic',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(width: spacing1),
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            'Category',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: spacing3,
                          runSpacing: spacing3,
                          children: List.generate(categoryItems.length, (
                            index,
                          ) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _categoryCheckStatesQ4[index],
                                  onChanged: (v) {
                                    setState(() {
                                      _categoryCheckStatesQ4[index] = v!;
                                    });
                                  },
                                ),
                                Text(
                                  categoryItems[index],
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: fontsizeSize1,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: panelSpacing),
              Center(
                child: SizedBox(
                  height: 50,
                  width: 640,
                  // The Align is fine here for aligning the Row, but the content inside the Row needs space.
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.go(Routes.getCATNAForm2Path());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(cornerRadius),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        const SizedBox(width: buttonSpacing),
                        if (widget.viewModel.canSubmitAssessment)
                          ElevatedButton(
                            onPressed: () async {
                              // Build training_needs JSON
                              final trainingNeeds = <String, dynamic>{
                                'knowledge': [
                                  for (var i = 0; i < knowledgeTrainingItems.length; i++)
                                    if (_knowledgeCheckStates[i]) knowledgeTrainingItems[i],
                                ],
                                'skills': [
                                  for (var i = 0; i < skillTrainingItems.length; i++)
                                    if (_skillCheckStates[i]) skillTrainingItems[i],
                                ],
                                'attitudes': [
                                  for (var i = 0; i < attitudeTrainingItems.length; i++)
                                    if (_attitudeCheckStates[i]) attitudeTrainingItems[i],
                                ],
                              };

                              // Build quarter_plans JSON (titles are not yet captured in the UI)
                              Map<String, dynamic> buildQuarterPlan(
                                List<bool> categoryStates,
                              ) {
                                return {
                                  'title': null,
                                  'categories': {
                                    'mandatory': categoryStates[0],
                                    'knowledge_based': categoryStates[1],
                                    'skill_based': categoryStates[2],
                                    'attitudinal_based': categoryStates[3],
                                  },
                                };
                              }

                              final quarterPlans = <String, dynamic>{
                                'q1': buildQuarterPlan(_categoryCheckStatesQ1),
                                'q2': buildQuarterPlan(_categoryCheckStatesQ2),
                                'q3': buildQuarterPlan(_categoryCheckStatesQ3),
                                'q4': buildQuarterPlan(_categoryCheckStatesQ4),
                              };

                              // Validate all form data before submission
                              final validationError = widget.viewModel.validateAllForms(
                                identifyingData: widget.viewModel.identifyingData,
                                competencyRatings: widget.viewModel.competencyRatings,
                                trainingNeeds: trainingNeeds,
                                quarterPlans: quarterPlans,
                              );

                              if (validationError != null) {
                                print('Form 3 Validation Error: $validationError'); // Debug log
                                _showValidationDialog(context, validationError);
                                return;
                              }

                              final payload = <String, dynamic>{
                                if (widget.viewModel.identifyingData != null)
                                  'identifying_data': widget.viewModel.identifyingData,
                                if (widget.viewModel.competencyRatings != null)
                                  'competency_ratings':
                                      widget.viewModel.competencyRatings,
                                'training_needs': trainingNeeds,
                                'quarter_plans': quarterPlans,
                              };

                              final Result<void> result =
                                  await widget.viewModel.submitCatna(payload);

                              if (!mounted) return;

                              switch (result) {
                                case Ok():
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'CATNA training needs submitted successfully.',
                                      ),
                                    ),
                                  );
                                  context.go(Routes.dashboard);
                                case Error(error: final e):
                                  final message = e is CustomMessageException
                                      ? e.message
                                      : 'Failed to submit CATNA training needs.';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(cornerRadius),
                              ),
                            ),
                            child: Text(
                              'Submit',
                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showValidationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Validation Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
