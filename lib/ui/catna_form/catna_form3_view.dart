import 'package:ephor/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CatnaForm3View extends StatefulWidget {
  const CatnaForm3View({super.key});

  @override
  State<CatnaForm3View> createState() => _CatnaForm3ViewState();
}

class _CatnaForm3ViewState extends State<CatnaForm3View> {
  final List<bool> _knowledgeCheckStates = List.generate(4, (index) => false);
  final List<bool> _skillCheckStates = List.generate(4, (index) => false);
  final List<bool> _attitudeCheckStates = List.generate(4, (index) => false);
  final List<bool> _categoryCheckStatesQ1 = List.generate(4, (index) => false);
  final List<bool> _categoryCheckStatesQ2 = List.generate(4, (index) => false);
  final List<bool> _categoryCheckStatesQ3 = List.generate(4, (index) => false);
  final List<bool> _categoryCheckStatesQ4 = List.generate(4, (index) => false);

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
      'Attitudinal Based'
    ];

    return Scaffold(
      backgroundColor: Colors.grey,
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
                          'III. Individual Training Plan',
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
                  height: 40,
                  width: 640,
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(cornerRadius),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'A. Training Needs',
                      style: TextStyle(
                        color: Colors.black,
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
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(cornerRadius),
                    ),
                    color: Colors.white,
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
                              color: Colors.black,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: spacing1),
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
                                        color: Colors.black,
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

                        Align(
                          alignment: AlignmentGeometry.center,
                          child: Text(
                            'SKILLS BASED TRAINING NEEDS',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w600,
                            ),
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
                                        color: Colors.black,
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

                        Align(
                          alignment: AlignmentGeometry.center,
                          child: Text(
                            'ATTITUDINAL BASED TRAINING NEEDS',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w600,
                            ),
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
                                        color: Colors.black,
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
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(cornerRadius),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Specific Training Needs',
                      style: TextStyle(
                        color: Colors.black,
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
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(cornerRadius),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            'Q1 JANUARY - MARCH',
                            style: TextStyle(
                              color: Colors.black,
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
                              color: Colors.black,
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
                              color: Colors.black,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        // MODIFIED: Replaced Row with Wrap for responsive layout
                        Wrap( 
                          spacing: spacing3, // spacing between items horizontally
                          runSpacing: spacing3, // spacing between lines vertically
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
                                    color: Colors.black,
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
                              color: Colors.black,
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
                              color: Colors.black,
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
                              color: Colors.black,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        // MODIFIED: Replaced Row with Wrap for responsive layout
                        Wrap(
                          spacing: spacing3, // spacing between items horizontally
                          runSpacing: spacing3, // spacing between lines vertically
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
                                    color: Colors.black,
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
                              color: Colors.black,
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
                              color: Colors.black,
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
                              color: Colors.black,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        // MODIFIED: Replaced Row with Wrap for responsive layout
                        Wrap(
                          spacing: spacing3, // spacing between items horizontally
                          runSpacing: spacing3, // spacing between lines vertically
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
                                    color: Colors.black,
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
                              color: Colors.black,
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
                              color: Colors.black,
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
                              color: Colors.black,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        // MODIFIED: Replaced Row with Wrap for responsive layout
                        Wrap(
                          spacing: spacing3, // spacing between items horizontally
                          runSpacing: spacing3, // spacing between lines vertically
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
                                    color: Colors.black,
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
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFDE3535),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(cornerRadius),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(color: Color(0xFFDE3535)),
                          ),
                        ),

                        const SizedBox(width: buttonSpacing),
                        ElevatedButton(
                          onPressed: () {
                            context.go(Routes.dashboard);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDE3535),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(cornerRadius),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
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