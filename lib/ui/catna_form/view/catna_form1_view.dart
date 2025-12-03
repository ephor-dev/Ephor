import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/catna_form/view_model/catna_form1_viewmodel.dart';
import 'package:ephor/ui/catna_form/view_model/catna_form_shared_viewmodel.dart';
import 'package:ephor/ui/core/ui/date_picker/date_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class CatnaForm1View extends StatelessWidget {
  const CatnaForm1View({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CatnaForm1ViewContent();
  }
}

class _CatnaForm1ViewContent extends StatefulWidget {
  const _CatnaForm1ViewContent();

  @override
  State<_CatnaForm1ViewContent> createState() => _CatnaForm1ViewState();
}

class _CatnaForm1ViewState extends State<_CatnaForm1ViewContent> {

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

  Future<void> _selectDate({
    required BuildContext context,
    required CatnaForm1ViewModel vm,
    required DateTime? currentDate,
    required Function(DateTime?) setDate,
  }) async {
    final DateTime? picked = await showEphorDatePicker(
      context, 
      currentDate ?? DateTime.now(), 
      DateTime(2000), 
      DateTime(2030), 
      OmniDateTimePickerType.date
    );

    if (picked != null && picked != currentDate) {
      setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CatnaForm1ViewModel>(
      builder: (context, vm, _) {
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
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(cornerRadius),
                      bottomRight: Radius.circular(cornerRadius),
                    ),
                    color: Theme.of(context).colorScheme.surface,
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
                              color: Colors.black,
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
                                  controller: vm.firstNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: spacing2),
                              Expanded(
                                child: TextField(
                                  controller: vm.lastNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: spacing2),
                              Expanded(
                                child: TextField(
                                  controller: vm.middleNameController,
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
                                      value: vm.selectedDesignation,
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
                                        vm.setSelectedDesignation(value);
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Position / Designation',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: spacing1),
                                    DropdownButtonFormField<String>(
                                      value: vm.selectedOffice,
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
                                        vm.setSelectedOffice(value);
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
                                            color: Colors.black,
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
                                            controller: vm.dateStartedController,
                                            readOnly: true,
                                            onTap: () => _selectDate(
                                              context: context,
                                              vm: vm,
                                              currentDate: vm.dateStarted,
                                              setDate: (picked) =>
                                                  vm.setDateStarted(picked),
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
                                            controller: vm.dateFinishedController,
                                            readOnly: true,
                                            onTap: () => _selectDate(
                                              context: context,
                                              vm: vm,
                                              currentDate: vm.dateFinished,
                                              setDate: (picked) =>
                                                  vm.setDateFinished(picked),
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
                                      value: vm.selectedOperatingUnit,
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
                                        vm.setSelectedOperatingUnit(value);
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Operating Unit / Campus',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: spacing1),
                                    TextField(
                                      controller:
                                          vm.yearsInCurrentPositionController,
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
                                            color: Colors.black,
                                            fontSize: fontsizeSize1,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: spacing3),
                                    TextField(
                                      controller: vm.assessmentDateController,
                                      readOnly: true,
                                      onTap: () => _selectDate(
                                        context: context,
                                        vm: vm,
                                        currentDate: vm.assessmentDate,
                                        setDate: (picked) =>
                                            vm.setAssessmentDate(picked),
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
                                  color: Colors.black,
                                  fontSize: fontsizeSize1,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: spacing3),
                              DropdownButtonFormField<String>(
                                value: vm.selectedPurpose,
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
                                  vm.setSelectedPurpose(value);
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
                            final validationError = vm.validateForm();
                            if (validationError != null) {
                              print('Form 1 Validation Error: $validationError'); // Debug log
                              _showValidationDialog(context, validationError);
                              return;
                            }

                            final sharedVm =
                                context.read<CatnaFormSharedViewModel>();

                            sharedVm.saveIdentifyingData(vm.buildIdentifyingData());

                            context.go(Routes.getCATNAForm2Path());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(cornerRadius),
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(color: Color(0xFFDE3535)),
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
      },
    );
  }
}
