import 'package:ephor/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CatnaForm2View extends StatefulWidget {
  const CatnaForm2View({super.key});

  @override
  State<CatnaForm2View> createState() => _CatnaForm2ViewState();
}

class _CatnaForm2ViewState extends State<CatnaForm2View> {
  // 1. Declare state map without 'final' keyword
  Map<String, int?> assessmentResponse = {};

  // 2. Define data lists as instance variables (can be final as they are constant data)
  final List<String> _knowledgeItems = [
    '1.1. (CK) Manifests foundation knowledge in the performance of assigned tasks in the academic area or work area.',
    '1.2. (CK) Has basic knowledge required to successfully and accurately accomplish duties and tasks.',
    '1.3. (CK) Possesses taught and learned facts and principles from academic area or work area.',
    '1.4. (FK) Manifests knowledge on quality, safety and professional regulatory standards.',
    '1.5. (FK) Has know-how in following University policies, rules and standards.',
    '1.6. (FK) Possesses understanding of how to describe and implement the rules or step to follow instructions at work.',
    '1.7. (SK) Shows knowledge competence in the field of work OR academic specialization in theory/constructs.',
    '1.8. (SK) Has knowledge and understanding on concepts for a particular work purpose OR academic discipline resulted from training or from self-initiated development',
    '1.9. (SK) Possesses specialized knowledge in contributing concepts/frameworks/methodology for work OR academic purposes.',
  ];
  final List<String> _skillsItems = [
    '2.1. (OS) Uses resources appropriately and conscientiously to avoid wastage.',
    '2.2. (OS) Maintains privacy and confidentiality as required.',
    '2.3. (OS) Shows ability in integrating own work strategies and activities with the University vision, mission and goals.',
    '2.4. (FS) When conflict arises, goes to the source of conflict to achieve the best possible resolution.',
    '2.5. (FS) Communicates the right information, in the right manner, to the right people (co-workers, customers & other stakeholders) at the right time.',
    '2.6. (FS) Exhibits skills required to successfully and accurately accomplish duties and tasks in a timely manner.',
    '2.7. (SMS) Works efficiently under pressure and is able to balance multiple priorities.',
    '2.8. (SMS) Shows the initiative to develop skills and enhance knowledge for better work performance.',
    '2.9. (SMS) Practices active listening skills and follows instructions accurately.',
  ];
  final List<String> _attitudeItems = [
    '3.1. (AW) Meets expectations related to attendance, punctuality, breaks and attendance to the flag raisingceremony.',
    '3.2. (AW) Demonstrates appreciation of the University strategic direction and its pursuit to the institutional goals and objectives.',
    '3.3. (AW) Promotes excellence and continuous improvement at work surpassing standards of expectations.',
    '3.4. (ACW) Shares pertinent information and knowledge to assist co-workers.',
    '3.5. (ACW) Exhibits dependability in co-worker or team while observing business decorum and aprofessional approach at work.',
    '3.6. (ACW) Engages in co-worker/team in any and other collective activities organized by the department/college/University.',
    '3.7. (ACS) Shows service-oriented attitude in attending to the needs and requirement of customers and other stakeholders.',
    '3.8. (ACS) Demonstrates flexibility when dealing with customers and other stakeholders of different demographic profiles (e.g., minority, orientation, nationality, economic condition, etc.).',
    '3.9. (ACS) Represents the University in promoting its vision, mission and strategic direction in any customer and stakeholders transaction or engagement.',
  ];

  @override
  void initState() {
    super.initState();
    final allItems = [..._knowledgeItems, ..._skillsItems, ..._attitudeItems];
    for (var item in allItems) {
      assessmentResponse[item] = null;
    }
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
                            groupValue: assessmentResponse[item],
                            onChanged: (int? value) {
                              setState(() {
                                assessmentResponse[item] = value;
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
                        ...buildAssessmentItems(_knowledgeItems),
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
                        ...buildAssessmentItems(_skillsItems),
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
                        ...buildAssessmentItems(_attitudeItems),
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
                            Navigator.pop(context);
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
  }
}
