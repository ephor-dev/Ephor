import 'package:flutter/material.dart';

import 'add_personnel_viewmodel.dart';
import 'personnel_model.dart';

class AddPersonnelView extends StatefulWidget {
  const AddPersonnelView({super.key});

  @override
  State<AddPersonnelView> createState() => _AddPersonnelViewState();

  // Static method to show the modal
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54, // Semi-transparent gray background
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext context) => const AddPersonnelView(),
    );
  }
}

class _AddPersonnelViewState extends State<AddPersonnelView> {
  late final AddPersonnelViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = AddPersonnelViewModel();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (BuildContext context, Widget? _) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24), // Increased corner radius
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000), // Softer, more subtle shadow
                  blurRadius: 24,
                  offset: Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Color(0x0A000000), // Additional subtle shadow layer
                  blurRadius: 12,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: _AddPersonnelContent(viewModel: viewModel),
          ),
        );
      },
    );
  }
}

// Modal content widget (no AppBar/Drawer needed)
class _AddPersonnelContent extends StatelessWidget {
  const _AddPersonnelContent({required this.viewModel});

  final AddPersonnelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isNarrow = constraints.maxWidth < 700;
        final EdgeInsets cardPadding = isNarrow ? const EdgeInsets.all(24) : const EdgeInsets.fromLTRB(28, 24, 28, 24);

        return SingleChildScrollView(
          child: Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Modal header with title and close button
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Add Personnel',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormSection(viewModel: viewModel, isNarrow: isNarrow),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.viewModel, required this.isNarrow});
  final AddPersonnelViewModel viewModel;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    const double formMaxWidth = 760; // shared width for centered rows

    // Left column: Image section - Modernized
    final Widget imageCol = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image picker not implemented')));
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8CC), // Beige/peach background (original)
              borderRadius: BorderRadius.circular(16), // Increased corner radius
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Icon(Icons.person_outline, size: 56, color: Color(0xFF9E9E9E)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 160,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFFB47B), // Peach/orange accent (original)
              side: const BorderSide(color: Color(0xFFFFB47B), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image picker not implemented')));
            },
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Upload Photo', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );

    // Modern input decoration with better focus states
    final InputDecoration decoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14), // Increased corner radius
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFFB47B), width: 2), // Peach/orange accent border
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w300,
      ),
    );

    // Right column: All form fields aligned and centered
    final Widget rightColumn = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: formMaxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Name fields row - Grouped with tighter spacing
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: isNarrow
                  ? Column(
                      children: <Widget>[
                        _NameField(
                          label: 'Last Name',
                          controller: viewModel.lastNameController,
                          decoration: decoration,
                          placeholder: 'Enter last name',
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        _NameField(
                          label: 'First Name',
                          controller: viewModel.firstNameController,
                          decoration: decoration,
                          placeholder: 'Enter first name',
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        _NameField(
                          label: 'Middle Name',
                          controller: viewModel.middleNameController,
                          decoration: decoration,
                          placeholder: 'Enter middle name',
                          isOptional: true,
                        ),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        Expanded(
                          child: _NameField(
                            label: 'Last Name',
                            controller: viewModel.lastNameController,
                            decoration: decoration,
                            placeholder: 'Enter last name',
                            isRequired: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NameField(
                            label: 'First Name',
                            controller: viewModel.firstNameController,
                            decoration: decoration,
                            placeholder: 'Enter first name',
                            isRequired: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NameField(
                            label: 'Middle Name',
                            controller: viewModel.middleNameController,
                            decoration: decoration,
                            placeholder: 'Enter middle name',
                            isOptional: true,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            // Employee Type with label
            const _FieldLabel('Employee Type'),
            const SizedBox(height: 8),
            _EmployeeType(viewModel: viewModel),
            const SizedBox(height: 20),
            // Department row
            _DepartmentRow(viewModel: viewModel),
            const SizedBox(height: 20),
            // Extra Tags
            const _FieldLabel('Extra Tags'),
            const SizedBox(height: 6),
            Text(
              'Separate multiple tags with commas',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w300,
                  ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: viewModel.tagsController,
              style: const TextStyle(fontWeight: FontWeight.w300),
              decoration: decoration.copyWith(hintText: 'e.g., non-teaching, part-time'),
            ),
            const SizedBox(height: 20),
            // Action buttons - Modernized
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    final PersonnelModel? result = viewModel.confirm();
                    final String message = result == null
                        ? 'Please fill out Last Name and First Name.'
                        : 'Saved: ${result.fullName}';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB47B), // Peach/orange accent (original)
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Layout: Two columns on desktop, stacked on mobile
    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(child: imageCol),
          const SizedBox(height: 24),
          rightColumn,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        imageCol,
        const SizedBox(width: 24),
        Expanded(child: rightColumn),
      ],
    );
  }
}

class _EmployeeType extends StatelessWidget {
  const _EmployeeType({required this.viewModel});
  final AddPersonnelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFFFFB47B); // Peach/orange accent (original)
    final Color inactiveBg = const Color(0xFFF5F5F5); // Soft light grey
    
    return SegmentedButton<EmployeeType>(
      segments: <ButtonSegment<EmployeeType>>[
        ButtonSegment<EmployeeType>(
          value: EmployeeType.personnel,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.business_center, size: 18),
              SizedBox(width: 6),
              Text('Personnel', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        ButtonSegment<EmployeeType>(
          value: EmployeeType.faculty,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.school, size: 18),
              SizedBox(width: 6),
              Text('Faculty', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        ButtonSegment<EmployeeType>(
          value: EmployeeType.jobOrder,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.work_outline, size: 18),
              SizedBox(width: 6),
              Text('Job Order', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
      selected: <EmployeeType>{viewModel.employeeType},
      onSelectionChanged: (Set<EmployeeType> newSelection) {
        if (newSelection.isNotEmpty) {
          viewModel.setEmployeeType(newSelection.first);
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor; // Active: filled with accent color
          }
          return inactiveBg; // Inactive: soft light grey background
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white; // Active: white text
          }
          return Colors.black87; // Inactive: neutral text
        }),
        side: WidgetStateProperty.resolveWith<BorderSide?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return BorderSide(color: accentColor, width: 1.5);
          }
          return const BorderSide(color: Color(0xFFE0E0E0), width: 1);
        }),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      ),
    );
  }
}

class _DepartmentRow extends StatelessWidget {
  const _DepartmentRow({required this.viewModel});
  final AddPersonnelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: DropdownButtonFormField<String>(
            value: viewModel.noDepartment ? null : viewModel.selectedDepartment,
            decoration: const InputDecoration(
              labelText: 'Department',
              labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87), // High-contrast text
            items: viewModel.departments
                .map((String e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(growable: false),
            onChanged: viewModel.noDepartment ? null : viewModel.setDepartment,
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: <Widget>[
            Checkbox(
              value: viewModel.noDepartment,
              onChanged: (bool? v) => viewModel.setNoDepartment(v ?? false),
              activeColor: const Color(0xFFFFB47B), // Peach/orange accent (original)
            ),
            Text(
              'Not part of any department',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.label,
    required this.controller,
    required this.decoration,
    required this.placeholder,
    this.isRequired = false,
    this.isOptional = false,
  });

  final String label;
  final TextEditingController controller;
  final InputDecoration decoration;
  final String placeholder;
  final bool isRequired;
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    final String displayLabel = isOptional ? '$label (Optional)' : label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FieldLabel(displayLabel),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontWeight: FontWeight.w300), // Light font weight for input text
          decoration: decoration.copyWith(hintText: placeholder),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500, // Medium font weight
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
    );
  }
}


