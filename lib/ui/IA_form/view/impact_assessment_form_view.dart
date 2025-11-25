import 'package:flutter/material.dart';

class ImpactAssessmentForm extends StatefulWidget {
  const ImpactAssessmentForm({super.key});

  @override
  State<ImpactAssessmentForm> createState() => _ImpactAssessmentFormState();
}

class _ImpactAssessmentFormState extends State<ImpactAssessmentForm> {
  // Existing state variables
  String? _selectedInterventionType;
  DateTime? _dateConducted;
  final TextEditingController _dateController = TextEditingController();

  // --- STATE VARIABLES FOR THE QUESTIONNAIRE ---
  // 1 = Yes, 0 = No
  int? _q1Answer;
  int? _q2Answer;
  int? _q3Answer;
  // 1-5 Scale
  int? _q4Rating;
  // -----------------------------------------------

  final List<String> _interventionTypes = [
    'Training',
    'Workshop',
    'Seminar/Webinar',
    'Conference',
    'Orientation'
  ];

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateConducted ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color.fromARGB(255, 151, 15, 15),
            colorScheme: const ColorScheme.light(
                primary: Color.fromARGB(255, 151, 15, 15)),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateConducted) {
      setState(() {
        _dateConducted = picked;
        String formattedDate =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
        _dateController.text = formattedDate;
      });
    }
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeaderBlock({required Widget child}) {
    return Container(
      width: 600,
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 8.0,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(4.0),
              ),
              gradient: LinearGradient(
                colors: [
                  Color(0xFFDE3535),
                  Color(0xFFE0B0A4),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBlock({required String title}) {
    return Container(
      width: 600,
      margin: const EdgeInsets.only(
          top: 15.0, bottom: 0.0, left: 25.0, right: 25.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            height: 2.0,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE0B0A4),
                  Color(0xFFDE3535),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormBodyBlock({required Widget child}) {
    return Container(
      width: 600,
      margin: const EdgeInsets.only(
          top: 15.0, bottom: 0.0, left: 25.0, right: 25.0),
      padding: const EdgeInsets.all(35.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCombinedSectionBlock(
      {required String title, required Widget child}) {
    return Container(
      width: 600,
      margin: const EdgeInsets.only(
          top: 15.0, bottom: 0.0, left: 25.0, right: 25.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            height: 2.0,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE0B0A4),
                  Color(0xFFDE3535),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? hint,
    bool requiredLabel = true,
    bool isDate = false,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (requiredLabel && label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        TextFormField(
          controller: controller,
          readOnly: isDate,
          onTap: isDate ? () => _selectDate(context) : null,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: isDate
                ? const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF8F3237),
                    size: 20,
                  )
                : null,
            enabledBorder: isDate
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF8F3237), width: 2.0),
                  )
                : const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
            focusedBorder: isDate
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF8F3237), width: 2.0),
                  )
                : null,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            hintText: 'Select',
          ),
          dropdownColor: Colors.white,
          itemHeight: 48.0,
          menuMaxHeight: 300,
          alignment: AlignmentDirectional.centerStart,
          initialValue: _selectedInterventionType,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 28,
          items: _interventionTypes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedInterventionType = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRadioOption(int value, int? groupValue, String label,
      Function(int?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, bottom: 5.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: RadioGroup(
              groupValue: groupValue,
              onChanged: onChanged,
              child: Radio<int>(
                value: value,
                activeColor: const Color(0xFF8F3237),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildLineTextInput(String hint) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 650,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildHeaderBlock(
                    child: const Text(
                      'Learning and Development\nIntervention Impact Assessment',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                  _buildSectionBlock(title: 'I. Identifying Data'),
                  _buildFormBodyBlock(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Personnel Name',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: _buildTextField(
                                    label: '',
                                    hint: 'Last name',
                                    requiredLabel: false)),
                            const SizedBox(width: 20),
                            Expanded(
                                child: _buildTextField(
                                    label: '',
                                    hint: 'First Name',
                                    requiredLabel: false)),
                            const SizedBox(width: 20),
                            Expanded(
                                child: _buildTextField(
                                    label: '',
                                    hint: 'Middle name',
                                    requiredLabel: false)),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: _buildTextField(
                                    label: 'College/Office', hint: '')),
                            const SizedBox(width: 30),
                            Expanded(
                                child: _buildTextField(
                                    label: 'Employment Status', hint: '')),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: _buildDropdownField(
                                    label: 'Type of Intervention Attended')),
                            const SizedBox(width: 30),
                            Expanded(
                                child: _buildTextField(
                                    label: 'Intervention Title', hint: '')),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _buildTextField(
                                label: 'Date Conducted',
                                hint: 'mm/dd/yyyy',
                                isDate: true,
                                controller: _dateController,
                              ),
                            ),
                            const SizedBox(width: 30),
                            Expanded(
                                child: _buildTextField(
                                    label: 'Venue', hint: '')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildCombinedSectionBlock(
                    title: 'II. Assessment and Impact',
                    child: const Text(
                      'Instruction: Kindly assess the impact/benefits gained by the above participant in attending the intervention.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),

                  // --- QUESTIONNAIRE FRAME (Q1-Q5) ---
                  _buildFormBodyBlock(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // QUESTION 1
                        const Text(
                          '1. Was the intervention beneficial to your personnel’s scope of work?',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _buildRadioOption(1, _q1Answer, 'Yes', (val) {
                              setState(() => _q1Answer = val);
                            }),
                            _buildRadioOption(0, _q1Answer, 'No', (val) {
                              setState(() => _q1Answer = val);
                            }),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'If "yes", please explain why it was beneficial. If "no", please try to explain why not.',
                          style: TextStyle(
                              fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 8),
                        _buildLineTextInput('Your explanation here...'),

                        const SizedBox(height: 35),

                        // QUESTION 2
                        const Text(
                          '2. Did the personnel incorporate the things they learned in the intervention into their work?',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _buildRadioOption(1, _q2Answer, 'Yes', (val) {
                              setState(() => _q2Answer = val);
                            }),
                            _buildRadioOption(0, _q2Answer, 'No', (val) {
                              setState(() => _q2Answer = val);
                            }),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'If "yes", please provide at least one concrete example. If "no", please try to explain why not.',
                          style: TextStyle(
                              fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 8),
                        _buildLineTextInput('Your explanation here...'),

                        const SizedBox(height: 35),

                        // QUESTION 3
                        const Text(
                          '3. Did you notice a significant change at your personnel’s perception, attitude or behavior as a result of the intervention?',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _buildRadioOption(1, _q3Answer, 'Yes', (val) {
                              setState(() => _q3Answer = val);
                            }),
                            _buildRadioOption(0, _q3Answer, 'No', (val) {
                              setState(() => _q3Answer = val);
                            }),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'If "yes", please provide at least one concrete example.',
                          style: TextStyle(
                              fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 8),
                        _buildLineTextInput('Your explanation here...'),

                        const SizedBox(height: 40),

                        // QUESTION 4
                        const Text(
                          '4. On a scale of 5-1, kindly rate the intervention’s overall impact to the efficiency of your personnel.',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRadioOption(5, _q4Rating, '5 - Outstanding',
                                (val) => setState(() => _q4Rating = val)),
                            _buildRadioOption(
                                4,
                                _q4Rating,
                                '4 - Very Satisfactory',
                                (val) => setState(() => _q4Rating = val)),
                            _buildRadioOption(3, _q4Rating, '3 - Satisfactory',
                                (val) => setState(() => _q4Rating = val)),
                            _buildRadioOption(2, _q4Rating, '2 - Unsatisfactory',
                                (val) => setState(() => _q4Rating = val)),
                            _buildRadioOption(1, _q4Rating, '1 - Poor',
                                (val) => setState(() => _q4Rating = val)),
                          ],
                        ),

                        const SizedBox(height: 35),

                        // QUESTION 5
                        const Text(
                          '5. Please list down other intervention/s he/she might need in the future.',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 15),
                        _buildLineTextInput('Your explanation here...'),
                      ],
                    ),
                  ),

                  // SUBMIT BUTTON 
                  Container(
                    width: 600,
                    margin: const EdgeInsets.only(
                        top: 15.0, bottom: 40.0, left: 25.0, right: 25.0),
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Success'),
                              content: const Text(
                                  'Your response has been recorded. Thank you!'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(color: Color(0xFF8F3237)),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                            0xFF8F3237),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  // -------------------------------------
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}