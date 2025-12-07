import 'package:ephor/domain/models/form/form_definitions.dart';
import 'package:ephor/ui/catna_form/view_model/catna_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CatnaSectionView extends StatelessWidget {
  final FormSection section;
  final CatnaViewModel viewModel;

  const CatnaSectionView({
    super.key,
    required this.section,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    // --- STYLING LOGIC ---
    // If layout is 'matrix', use the style from CatnaForm2 (Tertiary colors, darker bg)
    // If layout is 'standard', use the style from CatnaForm1 (Primary colors, lighter bg)
    final bool isMatrix = section.layout == SectionLayout.matrix;
    
    final headerGradient = isMatrix
        ? [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiaryFixed]
        : [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withAlpha(50)];

    final bgColor = Theme.of(context).colorScheme.surface;
    final contentColor = isMatrix 
        ? Theme.of(context).colorScheme.surfaceContainerLowest 
        : Theme.of(context).colorScheme.surface;

    const double cornerRadius = 8;

    return ColoredBox(
      color: Color.alphaBlend(
        Theme.of(context).colorScheme.onSurface.withAlpha(50),
        Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // 1. Top Decorative Bar
              Center(
                child: Container(
                  height: 20,
                  width: 640,
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
                  width: 640,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(cornerRadius),
                      bottomRight: Radius.circular(cornerRadius),
                    ),
                    color: contentColor,
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
              const SizedBox(height: 8),

              // 3. Section Title & Description
              Center(
                child: Container(
                  width: 640,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: contentColor,
                    borderRadius: BorderRadius.circular(cornerRadius),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (section.description != null)
                        Text(
                          section.description!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 4. Dynamic Form Items
              Center(
                child: Container(
                  width: 640,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(cornerRadius),
                    color: contentColor,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: section.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildDynamicItem(context, item),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicItem(BuildContext context, FormItem item) {
    if (item.type == FormInputType.header) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.tertiaryFixed
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (item.type == FormInputType.radioMatrix) {
      return _buildRadioMatrixItem(context, item);
    }

    // Standard Fields (Text, Number, Date, Dropdown)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.type == FormInputType.number)
          TextFormField(
            controller: viewModel.getController(item.key),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: item.label,
              border: const OutlineInputBorder(),
            ),
          ),
        if (item.type == FormInputType.text)
          TextFormField(
             controller: viewModel.getController(item.key),
             decoration: InputDecoration(
              labelText: item.label,
              border: const OutlineInputBorder(),
            ),
          ),
        if (item.type == FormInputType.date)
          _buildDatePicker(context, item),

        if (item.type == FormInputType.dropdown)
          _buildDropdown(context, item),
      ],
    );
  }

  Widget _buildDropdown(BuildContext context, FormItem item) {
    // Look at the config from JSON: { "dataSource": "employees" }
    final String? source = item.config['dataSource'];
    
    // Ask ViewModel for the actual list based on that string
    final List<FormOption> options = viewModel.getOptionsFor(source);

    return DropdownButtonFormField<String>(
      initialValue: viewModel.formData[item.key], // The generated key (e.g. "personnel_name")
      isExpanded: true,
      decoration: InputDecoration(
        labelText: item.label, // "Personnel Name"
        border: const OutlineInputBorder(),
      ),
      items: options.map((opt) {
        return DropdownMenuItem<String>(
          value: opt.value.toString(),
          child: Text(opt.label),
        );
      }).toList(),
      onChanged: (val) => viewModel.updateValue(item.key, val),
    );
  }

  Widget _buildDatePicker(BuildContext context, FormItem item) {
    final controller = viewModel.getController(item.key);
    
    // Parse config dates if they exist
    DateTime minDate = DateTime(2000);
    DateTime maxDate = DateTime(2030);
    
    if (item.config['minDate'] != null) {
      minDate = DateTime.tryParse(item.config['minDate']) ?? minDate;
    }
    if (item.config['maxDate'] != null) {
      maxDate = DateTime.tryParse(item.config['maxDate']) ?? maxDate;
    }

    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: item.label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: minDate,
          lastDate: maxDate,
        );
        if (picked != null) {
          final val = "${picked.month}/${picked.day}/${picked.year}";
          viewModel.updateValue(item.key, val);
        }
      },
    );
  }

  Widget _buildRadioMatrixItem(BuildContext context, FormItem item) {
    // 4(A), 3(P), etc.
    final Map<String, int> ratingScale = {
      '4(A)': 4, '3(P)': 3, '2(B)': 2, '1(N/L)': 1
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ratingScale.entries.map((entry) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(entry.key, style: const TextStyle(fontSize: 12)),
                      Radio<int>(
                        value: entry.value,
                        activeColor: Theme.of(context).colorScheme.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        groupValue: viewModel.formData[item.key],
                        onChanged: (val) => viewModel.updateValue(item.key, val),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}