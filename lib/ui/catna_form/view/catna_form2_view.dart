import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/catna_form/view_model/catna_form2_viewmodel.dart';
import 'package:ephor/ui/catna_form/view_model/catna_form_shared_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CatnaForm2View extends StatelessWidget {
  const CatnaForm2View({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CatnaForm2ViewContent();
  }
}

class _CatnaForm2ViewContent extends StatelessWidget {
  const _CatnaForm2ViewContent();

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
    return Consumer<CatnaForm2ViewModel>(
      builder: (context, vm, _) {
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
                    color: Colors.black,
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
                                groupValue: vm.assessmentResponse[item],
                                onChanged: (int? value) {
                                  vm.setRating(item, value);
                                },
                                child: Radio<int>(
                                  value: entry.value,
                                  activeColor: const Color(0xFFDE3535),
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
      backgroundColor: Colors.grey,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Center(
                child: Container(
                  height: 20,
                  width: 640,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFDE3535), Color(0xFFE0B0A4)],
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
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(cornerRadius),
                      bottomRight: Radius.circular(cornerRadius),
                    ),
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Text(
                      'Competency Assessment and Training\n Needs Analysis',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
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
                            color: Colors.black,
                            fontSize: fontsizeSize1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Instructions: Read each item per SCOPE Area and assess the Personnel.',
                          style: TextStyle(
                            color: Colors.black,
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
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(cornerRadius),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '1. KNOWLEDGE (Content, Functional, Specialized)',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: fontsizeSize1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: spacing3),
                        Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFDE3535), Color(0xFFE0B0A4)],
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing2),
                        ...buildAssessmentItems(vm.knowledgeItems),
                        Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFDE3535), Color(0xFFE0B0A4)],
                            ),
                          ),
                        ),

                        const SizedBox(height: spacing2),
                        Text(
                          '2. Skills (Organizational, Functional, Self-Management)',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: fontsizeSize1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: spacing2),
                        Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFDE3535), Color(0xFFE0B0A4)],
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing2),
                        ...buildAssessmentItems(vm.skillsItems),
                        Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFDE3535), Color(0xFFE0B0A4)],
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing2),
                        Text(
                          '3. Attitudes (Attitude Towards Work, Co-Worker, Customer and other Stakeholders)',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: fontsizeSize1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: spacing2),
                        Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFDE3535), Color(0xFFE0B0A4)],
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing2),
                        ...buildAssessmentItems(vm.attitudeItems),
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
                          onPressed: () {
                            final validationError = vm.validateForm();
                            if (validationError != null) {
                              print('Form 2 Validation Error: $validationError'); // Debug log
                              _showValidationDialog(context, validationError);
                              return;
                            }

                            final sharedVm =
                                context.read<CatnaFormSharedViewModel>();

                            sharedVm.saveCompetencyRatings(vm.buildCompetencyRatings());

                            context.go(Routes.getCATNAForm3Path());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(cornerRadius),
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
      },
    );
  }
}
