import 'package:ephor/ui/catna_form/view_model/catna_viewmodel.dart';
import 'package:flutter/material.dart';

class CatnaForm2View extends StatefulWidget {
  final CatnaViewModel viewModel;
  const CatnaForm2View({super.key, required this.viewModel});

  @override
  State<CatnaForm2View> createState() => _CatnaForm2ViewState();
}

class _CatnaForm2ViewState extends State<CatnaForm2View> {

  @override
  Widget build(BuildContext context) {
    const double cornerRadius = 8;
    const double panelSpacing = 8;
    const double fontsizeSize1 = 14;
    const double spacing1 = 16;
    const double spacing2 = 8;
    const double spacing3 = 4;

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
            ],
          ),
        ),
      ),
    );
  }
}
