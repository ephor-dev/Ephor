import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/catna_form/view_models/catna_form2_viewmodel.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CatnaForm2View extends StatefulWidget {
  final CatnaForm2ViewModel viewModel;
  const CatnaForm2View({super.key, required this.viewModel});

  @override
  State<CatnaForm2View> createState() => _CatnaForm2ViewState();
}

class _CatnaForm2ViewState extends State<CatnaForm2View> {

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

  @override
  Widget build(BuildContext context) {
    const double cornerRadius = 8;
    const double panelSpacing = 8;
    const double fontsizeSize1 = 14;
    const double spacing1 = 16;
    const double spacing2 = 8;
    const double spacing3 = 4;
    const double buttonSpacing = 24;

    final Map<String, int> assessmentRatings = const {
      '4(A)': 4,
      '3(P)': 3,
      '2(B)': 2,
      '1(N/L)': 1,
    };

    List<Widget> buildAssessmentItems(List<String> items) {
      return items.map((item) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: fontsizeSize1,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: spacing2),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: assessmentRatings.entries.map((entry) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(fontSize: fontsizeSize1),
                          ),
                          RadioGroup(
                            groupValue: widget.viewModel.assessmentResponse[item],
                            onChanged: (int? value) {
                              setState(() {
                                widget.viewModel.setRating(item, value);
                              });
                            },
                            child: Radio<int>(
                              value: entry.value,
                              activeColor: Theme.of(context).colorScheme.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: spacing1),
          ],
        );
      }).toList();
    }

    return Scaffold(
      backgroundColor: Color.alphaBlend(
        Theme.of(context).colorScheme.onSurface.withAlpha(50), 
        Theme.of(context).colorScheme.surfaceContainerLowest
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
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
                          'II. Rating of Competency',
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
                  width: 640,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(cornerRadius),
                    ),
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '1. KNOWLEDGE (Content, Functional, Specialized)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: fontsizeSize1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: spacing3),
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
                        ...buildAssessmentItems(widget.viewModel.knowledgeItems),
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
                        Text(
                          '2. Skills (Organizational, Functional, Self-Management)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: fontsizeSize1,
                            fontWeight: FontWeight.w600,
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
                        const SizedBox(height: spacing2),
                        ...buildAssessmentItems(widget.viewModel.skillsItems),
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
                        Text(
                          '3. Attitudes (Attitude Towards Work, Co-Worker, Customer and other Stakeholders)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: fontsizeSize1,
                            fontWeight: FontWeight.w600,
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
                        const SizedBox(height: spacing2),
                        ...buildAssessmentItems(widget.viewModel.attitudeItems),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: panelSpacing),
              Center(
                child: SizedBox(
                  height: 50, // Increased height to prevent clipping
                  width: 640,
                  // Use Align to push the button to the left
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.go(Routes.getCATNAForm1Path());
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
                        ElevatedButton(
                          onPressed: () async {
                            final validationError = widget.viewModel.validateForm();
                            if (validationError != null) {
                              _showValidationDialog(context, validationError);
                              return;
                            }

                            widget.viewModel.saveCompetencyRatings(widget.viewModel.buildCompetencyRatings());

                            final payload = <String, dynamic>{
                                if (widget.viewModel.identifyingData != null)
                                  'identifying_data': widget.viewModel.identifyingData,
                                if (widget.viewModel.competencyRatings != null)
                                  'competency_ratings':
                                      widget.viewModel.competencyRatings
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
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
}
