import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/core/ui/date_picker/date_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class CatnaForm1View extends StatefulWidget {
  const CatnaForm1View({super.key});

  @override
  State<CatnaForm1View> createState() => _CatnaForm1ViewState();
}

class _CatnaForm1ViewState extends State<CatnaForm1View> {
  DateTime? _dateStarted;
  final TextEditingController _dateStartedController = TextEditingController();

  DateTime? _dateFinished;
  final TextEditingController _dateFinishedController = TextEditingController();

  DateTime? _assessmentDate;
  final TextEditingController _assessmentDateController =
      TextEditingController();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _yearsInCurrentPositionController =
      TextEditingController();

  String? _selectedDesignation;
  String? _selectedOffice;
  String? _selectedOperatingUnit;
  String? _selectedPurpose;

  @override
  void dispose() {
    _dateStartedController.dispose();
    _dateFinishedController.dispose();
    _assessmentDateController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _yearsInCurrentPositionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({
    required BuildContext context,
    required DateTime? currentDate,
    required Function(DateTime) setDate,
    required TextEditingController controller,
  }) async {
    final DateTime? picked = await showEphorDatePicker(
      context, 
      currentDate ?? DateTime.now(), 
      DateTime(2000), 
      DateTime(2030), 
      OmniDateTimePickerType.date
    );

    if (picked != null && picked != currentDate) {
      setState(() {
        setDate(picked);
        String formattedDate =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
        controller.text = formattedDate;
      });
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
    final List<String> designationChoices = [
      'Software Engineer',
      'Product Manager',
      'UX Designer',
      'Data Scientist',
    ];
    final List<String> officeChoices = [
      'College of Engineering (CoE)',
      'College of Informatics and Computing Sciences (CICS)',
    ];
    final List<String> operatingUnitChoices = ['Alangilan', 'Pablo Borbon'];
    final List<String> purposeChoices = ['Annual Review', 'Random Assessment'];
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
                    color: Theme.of(context).colorScheme.surface,
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary, 
                        Theme.of(context).colorScheme.primary.withAlpha(50)
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
                    color: Theme.of(context).colorScheme.surface,
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
                  height: 40,
                  width: 640,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(cornerRadius),
                    ),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'I. Identifying Data',
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
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Personnel Name',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: fontsizeSize1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: spacing2),
                              Expanded(
                                child: TextField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: spacing2),
                              Expanded(
                                child: TextField(
                                  controller: _middleNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Middle Name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedDesignation,
                                      isExpanded: true,
                                      selectedItemBuilder:
                                          (BuildContext context) {
                                            return designationChoices
                                                .map<Widget>((String value) {
                                                  return Text(
                                                    value,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    softWrap: false,
                                                  );
                                                })
                                                .toList();
                                          },
                                      items: designationChoices.map((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedDesignation = value;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Position / Designation',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: spacing1),
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedOffice,
                                      isExpanded: true,
                                      selectedItemBuilder:
                                          (BuildContext context) {
                                            return officeChoices.map<Widget>((
                                              String value,
                                            ) {
                                              return Text(
                                                value,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                              );
                                            }).toList();
                                          },
                                      items: officeChoices.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedOffice = value;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Office/College',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: spacing3),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Review Period',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            fontSize: fontsizeSize1,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: spacing3),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _dateStartedController,
                                            readOnly: true,
                                            onTap: () => _selectDate(
                                              context: context,
                                              currentDate: _dateStarted,
                                              setDate: (picked) =>
                                                  _dateStarted = picked,
                                              controller:
                                                  _dateStartedController,
                                            ),
                                            decoration: const InputDecoration(
                                              labelText: 'Start Date',
                                              labelStyle: TextStyle(
                                                fontSize:
                                                    fontsizeSize1, // Adjust this value as needed
                                              ),
                                              border: OutlineInputBorder(),
                                              suffixIcon: Icon(
                                                Icons.calendar_today,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: spacing2),
                                        Expanded(
                                          child: TextField(
                                            controller: _dateFinishedController,
                                            readOnly: true,
                                            onTap: () => _selectDate(
                                              context: context,
                                              currentDate: _dateFinished,
                                              setDate: (picked) =>
                                                  _dateFinished = picked,
                                              controller:
                                                  _dateFinishedController,
                                            ),
                                            decoration: const InputDecoration(
                                              labelText: 'Finish Date',
                                              labelStyle: TextStyle(
                                                fontSize:
                                                    fontsizeSize1, // Adjust this value as needed
                                              ),
                                              border: OutlineInputBorder(),
                                              suffixIcon: Icon(
                                                Icons.calendar_today,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Column(
                                  children: [
                                    const SizedBox(height: spacing2),
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedOperatingUnit,
                                      isExpanded: true,
                                      selectedItemBuilder:
                                          (BuildContext context) {
                                            return operatingUnitChoices
                                                .map<Widget>((String value) {
                                                  return Text(
                                                    value,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    softWrap: false,
                                                  );
                                                })
                                                .toList();
                                          },
                                      items: operatingUnitChoices.map((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedOperatingUnit = value;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Operating Unit / Campus',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: spacing1),
                                    TextField(
                                      controller:
                                          _yearsInCurrentPositionController,
                                      decoration: const InputDecoration(
                                        labelText: 'Years in Current Position',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: spacing3),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Assessment Date',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            fontSize: fontsizeSize1,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: spacing3),
                                    TextField(
                                      controller: _assessmentDateController,
                                      readOnly: true,
                                      onTap: () => _selectDate(
                                        context: context,
                                        currentDate: _assessmentDate,
                                        setDate: (picked) =>
                                            _assessmentDate = picked,
                                        controller: _assessmentDateController,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'mm/dd/yyyy',
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Purpose of Assessment',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: fontsizeSize1,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: spacing3),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedPurpose,
                                isExpanded: true,
                                selectedItemBuilder: (BuildContext context) {
                                  return purposeChoices.map<Widget>((
                                    String value,
                                  ) {
                                    return Text(
                                      value,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    );
                                  }).toList();
                                },
                                items: purposeChoices.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPurpose = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Office/College',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                    child: ElevatedButton(
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
                        'Next',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
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
