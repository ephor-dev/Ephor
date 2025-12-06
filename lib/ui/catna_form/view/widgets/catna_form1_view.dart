import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/ui/catna_form/view_model/catna_viewmodel.dart';
import 'package:ephor/ui/core/ui/date_picker/date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class CatnaForm1View extends StatefulWidget {
  final CatnaViewModel viewModel;
  const CatnaForm1View({super.key, required this.viewModel});

  @override
  State<CatnaForm1View> createState() => _CatnaForm1ViewState();
}

class _CatnaForm1ViewState extends State<CatnaForm1View> {

  Future<void> _selectDate({
    required BuildContext context,
    required DateTime? currentDate,
    required Function(DateTime) setDate
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
    final List<String> operatingUnitChoices = [
      'Alangilan (Batangas City)',
      'Balayan',
      'ARASOF Nasugbu',
      'Lemery',
      'Lipa',
      'LIMA',
      'Lobo',
      'Mabini',
      'JPLPC Malvar',
      'Pablo Borbon (Batangas City)',
      'Rosario',
      'San Juan',
    ];
    final List<String> officeChoices = [
      'Integrated School',
      'College of Accountancy, Business, Economics, and International Hospitality Management (CABEIHM)',
      'College of Health Sciences',
      'College of Arts and Sciences',
      'College of Law',
      'College of Teacher Education',
      'College of Criminal Justice Education',
      'College of Medicine',
      'College of Engineering',
      'College of Architecture, Fine Arts and Design',
      'College of Industrial Technology',
      'College of Informatics and Computing Sciences',
      'College of Agriculture and Forestry',
      'College of Fisheries and Aquatic Sciences',
      'College of Hospitality Management',
      'College of Business Administration and Accounting Management',
      'College of Marketing Management',
      'College of Management Accounting',
      'College of Technical-Vocational Teacher Education',
      'College of Civil Technology',
      'College of Drafting Technology',
      'College of Electronics Technology',
      'College of Information Technology',
      'College of Development Communication',
    ];
    final List<String> purposeChoices = ['Annual Review', 'Random Assessment'];
    final departmentEmployees = widget.viewModel.departmentEmployees;

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
                          child: DropdownButtonFormField<String>(
                            initialValue: widget.viewModel.selectedEmployeeName,
                            isExpanded: true,
                            selectedItemBuilder: (BuildContext context) {
                              return departmentEmployees.map<Widget>((
                                EmployeeModel employee,
                              ) {
                                return Text(
                                  employee.fullName,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                );
                              }).toList();
                            },
                            items: departmentEmployees.map((EmployeeModel employee) {
                              return DropdownMenuItem<String>(
                                value: employee.fullName,
                                child: Text(employee.fullName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              widget.viewModel.setEmployeeName(value);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Personnel Name',
                              border: OutlineInputBorder(),
                            ),
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
                                      initialValue: widget.viewModel.selectedDesignation,
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
                                        widget.viewModel.setSelectedDesignation(value);
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Position / Designation',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: spacing1),
                                    DropdownButtonFormField<String>(
                                      initialValue: widget.viewModel.selectedOffice,
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
                                        widget.viewModel.setSelectedOffice(value);
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
                                            controller: widget.viewModel.dateStartedController,
                                            readOnly: true,
                                            onTap: () => _selectDate(
                                              context: context,
                                              currentDate: widget.viewModel.dateStarted,
                                              setDate: (picked) =>
                                                  widget.viewModel.setDateStarted(picked),
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
                                            controller: widget.viewModel.dateFinishedController,
                                            readOnly: true,
                                            onTap: () => _selectDate(
                                              context: context,
                                              currentDate: widget.viewModel.dateFinished,
                                              setDate: (picked) =>
                                                  widget.viewModel.setDateFinished(picked),
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
                                      initialValue: widget.viewModel.selectedOperatingUnit,
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
                                        widget.viewModel.setSelectedOperatingUnit(value);
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Operating Unit / Campus',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: spacing1),
                                    TextField(
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      controller:
                                          widget.viewModel.yearsInCurrentPositionController,
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
                                      controller: widget.viewModel.assessmentDateController,
                                      readOnly: true,
                                      onTap: () => _selectDate(
                                        context: context,
                                        currentDate: widget.viewModel.assessmentDate,
                                        setDate: (picked) =>
                                            widget.viewModel.setAssessmentDate(picked),
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
                                initialValue: widget.viewModel.selectedPurpose,
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
                                  widget.viewModel.setSelectedPurpose(value);
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Purpose of Assessment',
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
            ],
          ),
        ),
      ),
    );
  }
}

List<String> designationChoices = [
  'University President',
  'Chancellor',
  'Vice Chancellor for Academic Affairs',
  'Vice Chancellor for Research Development and Extension Services',
  'Vice Chancellor for Administration and Finance',
  'Vice Chancellor for Development and External Affairs',
  'Vice President for Academic Affairs',
  'Vice President for Research, Development and Extension Services',
  'Vice President for Administration and Finance',
  'Vice President for Development and External Affairs',
  'Secretary of the University and of the Board of Regents',
  'Director, Legal Affairs',
  'Director, Internal Audit Services',
  'Director, Presidential Project Management',
  'Director, Knowledge, Innovation, Science and Technology (KIST) Park Center',
  'Director, Adaptive Capacity Building and Technology Innovation for Occupational Hazards and Natural Disasters (ACTION) Center',
  'Director, Center for Innovation in Engineering Education (CIEE)',
  'Director, Public Relations Sustainability Development Officer, Center for Sustainable Development',
  'Director, Culture and Arts',
  'Director, Sports Development',
  'Director, Student Affairs and Services',
  'Director, Center for Transformative Learning',
  'Director, Quality Assurance Management',
  'Director, Curriculum and Instruction',
  'Director, Instructional Material Development Center',
  'Director, Mentorship',
  'Director, Research',
  'Director, Research Management',
  'Director, Extension Services',
  'Director, Science, Technology, Engineering and Environment Research (STEER) Hub',
  'Director, Administration Services',
  'Director, Finance Services',
  'Director, Project Management',
  'Director, Health Services',
  'Director, ICT Services',
  'Director, External Affairs',
  'Director, Auxiliary Services',
  'Director, Institutional Planning and Development',
  'OIC – Director for Project Management',
  'Assistant Director, Scholarship',
  'Assistant Director, Testing and Admission',
  'Assistant Director, Services for Students with Special Needs and Persons with Disabilities',
  'Assistant Director, Industry, Energy and Emerging Technology Research',
  'Assistant Director, Agriculture, Aquatic and Natural Resources Research',
  'Assistant Director, Integrated Basic and Applied Research',
  'Assistant Director, Disaster Risk Management and Health Research',
  'Assistant Director, Research Integrity and Assurance',
  'Assistant Director, Research Publication Management',
  'Assistant Director, Knowledge and Technology Transfer Management',
  'Assistant Director, Community Development',
  'Assistant Director, Extension Monitoring and Impact Assessment',
  'Assistant Director, Gender and Development Advocacies',
  'Assistant Director, Human Resource Management',
  'Assistant Director, Procurement',
  'Assistant Director, Property and Supply',
  'Assistant Director, Records Management',
  'Assistant Director, General Services',
  'Assistant Director, Accounting',
  'Assistant Director, Budget',
  'Assistant Director, Cashiering and Disbursement Officer',
  'Assistant Director, Cashiering',
  'Assistant Director, Network and Systems Administration',
  'Assistant Director, ICT Special Projects/ICT Operations',
  'Assistant Director, Management Information System',
  'Assistant Director, Strategic Planning and Performance Measures',
  'Assistant Director, Local Partnership',
  'Disbursing Officer',
  'ISO Focal Person',
  'ISO Lead Auditor',
  'ISO Document Controller',
  'Head, Center for Technopreneurship and Innovation',
  'Head, Electronic Systems Research Center',
  'Head, GIS Applications Development Center',
  'Head, Digital Transformation Center',
  'Head, Manufacturing Research Center',
  'Head, Material Testing and Calibration Center',
  'Head, Analytical Research Center',
  'Head, Food Innovation Center',
  'Head, Social Innovation Research Center',
  'Head, Verde Island Passage Center for Oceanographic Research and Aquatic Life Sciences (VIP CORALS) – Lobo',
  'Head, Verde Island Passage Center for Oceanographic Research and Aquatic Life Sciences (VIP CORALS) – Nasugbu',
  'Head, Internal Audit',
  'Head, Quality Assurance Management',
  'Head, Sustainable Development',
  'Head, General Education',
  'Head, Expanded Tertiary Education Equivalency and Accreditation Program (ETEEAP)',
  'Head, Registration Services',
  'Head, Library Services',
  'Head, Health Services',
  'Head, Testing and Admission',
  'Head, Research, Development and Extension Services',
  'Head, Academic Affairs',
  'Head, Administration and Finance',
  'Head, Development and External Affairs',
  'Head, Administrative Services',
  'Head, Research and Extension',
  'Head, Research and Extension Office',
  'Head, Research Development and Extension Services',
  'Campus Director',
  'Campus Director and Head, Research, Development and Extension Services',
  'Dean (various colleges, e.g., College of Arts and Sciences, College of Accountancy, Business, Economics and International Hospitality Management, College of Teacher Education, College of Health Sciences, College of Law, College of Medicine, College of Criminal Justice Education, College of Industrial Technology, College of Informatics and Computing Sciences)',
  'Associate Dean (various colleges)',
  'Associate Dean & Department Chairman',
  'Department Chairman',
  'Department Chair',
  'Head Teacher III, Integrated School',
  'Head Teacher I, Integrated School-Grade School Department',
  'Head Teacher I, Integrated School- High School Department',
  'Instructor I',
  'Instructor II',
  'Instructor III',
  'Assistant Professor I',
  'Assistant Professor II',
  'Assistant Professor III',
  'Assistant Professor IV',
  'Associate Professor I',
  'Associate Professor III',
  'Associate Professor IV',
  'Associate Professor V',
  'Professor I',
  'Professor V',
  'Professor VI',
  'Teacher I',
  'Lecturer I',
  'Lecturer II',
  'Lecturer III',
  'Lecturer IV',
  'Senior Lecturer I',
];
