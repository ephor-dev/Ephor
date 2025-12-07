import 'package:ephor/domain/models/form/form_definitions.dart';
import 'package:ephor/ui/core/ui/date_picker/date_picker.dart';
import 'package:ephor/ui/impact_assessment_form/view_model/impact_assessment_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class ImpactAssessmentSectionView extends StatelessWidget {
  final FormSection section;
  final ImpactAssessmentViewModel viewModel;

  const ImpactAssessmentSectionView({
    super.key,
    required this.section,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isImpactStyle = section.layout == SectionLayout.impact_style;

    final headerGradient = isImpactStyle
        ? [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiaryFixed]
        : [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withAlpha(50)];
    final contentColor = isImpactStyle
        ? Theme.of(context).colorScheme.surfaceContainerLowest 
        : Theme.of(context).colorScheme.surface;

    const double cornerRadius = 8;

    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: 800,
          child: Column(
            children: [
              Center(
                child: Container(
                  height: 20,
                  width: 750,
                  decoration: BoxDecoration(
                    color: contentColor,
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight,
                      colors: headerGradient,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(cornerRadius),
                      topRight: Radius.circular(cornerRadius),
                    ),
                  ),
                ),
              ),
              
              // 2. Main Title Header
              Center(
                child: Container(
                  height: 160,
                  width: 750,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(cornerRadius),
                      bottomRight: Radius.circular(cornerRadius),
                    ),
                    color: contentColor,
                  ),
                  child: Center(
                    child: Text(
                      'Learning and Development\nIntervention Impact Assessment',
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
              const SizedBox(height: 20),
              _buildSectionHeader(context),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                padding: const EdgeInsets.all(35.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(13),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (section.description != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          section.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(222),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ...section.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 25.0),
                      child: _buildDynamicItem(context, item),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Text(
              section.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(222),
              ),
            ),
          ),
          Container(
            height: 2.0,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0B0A4), Color(0xFFDE3535)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicItem(BuildContext context, FormItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            item.label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        if (item.type == FormInputType.text) _buildTextField(context, item),
        if (item.type == FormInputType.date) _buildDatePicker(context, item),
        if (item.type == FormInputType.dropdown) _buildDropdown(context, item),
        if (item.type == FormInputType.radio) _buildRadioGroup(context, item),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, FormItem item) {
    return TextFormField(
      controller: viewModel.getController(item.key),
      decoration: _impactInputDecoration(context, 'Enter details...'),
      onChanged: (val) => viewModel.updateValue(item.key, val),
    );
  }

  Widget _buildDatePicker(BuildContext context, FormItem item) {
    final controller = viewModel.getController(item.key);
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: _impactInputDecoration(
        context, 
        'mm/dd/yyyy',
        suffix: const Icon(Icons.calendar_today, color: Color(0xFF8F3237), size: 20),
      ),
      onTap: () async {
        final picked = await showEphorDatePicker(
          context,
          DateTime.now(),
          DateTime(2000),
          DateTime(2030),
          OmniDateTimePickerType.date
        );
        if (picked != null) {
          final val = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
          viewModel.updateValue(item.key, val);
        }
      },
    );
  }

  Widget _buildDropdown(BuildContext context, FormItem item) {
    // Fetches options based on dataSource string (e.g. 'offices')
    final options = viewModel.getOptionsFor(item.config['dataSource']);
    return DropdownButtonFormField<String>(
      value: viewModel.formData[item.key],
      decoration: _impactInputDecoration(context, 'Select'),
      icon: const Icon(Icons.arrow_drop_down, size: 28),
      dropdownColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      items: options.map((opt) => DropdownMenuItem(
        value: opt.value.toString(),
        child: Text(opt.label, overflow: TextOverflow.ellipsis),
      )).toList(),
      onChanged: (val) => viewModel.updateValue(item.key, val),
    );
  }

  Widget _buildRadioGroup(BuildContext context, FormItem item) {
    final options = item.options ?? [];
    bool isYesNo = options.length <= 2;

    List<Widget> radios = options.map((opt) {
      return Padding(
        padding: const EdgeInsets.only(right: 20.0, bottom: 5.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24, height: 24,
              child: Radio<dynamic>(
                value: opt.value,
                groupValue: viewModel.formData[item.key],
                activeColor: const Color(0xFF8F3237),
                onChanged: (val) => viewModel.updateValue(item.key, val),
              ),
            ),
            const SizedBox(width: 8),
            Text(opt.label),
          ],
        ),
      );
    }).toList();

    return isYesNo 
      ? Row(children: radios) 
      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: radios);
  }

  InputDecoration _impactInputDecoration(BuildContext context, String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    );
  }
}