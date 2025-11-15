import 'package:flutter/material.dart';

import 'package:ephor/ui/add_personnel/add_personnel_viewmodel/add_personnel_viewmodel.dart';
import 'package:ephor/domain/models/personnel/personnel.dart';
import 'package:ephor/data/services/personnel_service.dart';

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
    // Use the shared service so added personnel appear in Remove Personnel view
    // In production, this would be injected via dependency injection
    viewModel = AddPersonnelViewModel(service: sharedPersonnelService);
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
                          label: 'LAST NAME',
                          controller: viewModel.lastNameController,
                          decoration: decoration,
                          placeholder: 'Enter last name',
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        _NameField(
                          label: 'FIRST NAME',
                          controller: viewModel.firstNameController,
                          decoration: decoration,
                          placeholder: 'Enter first name',
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        _NameField(
                          label: 'MIDDLE NAME',
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
                            label: 'LAST NAME',
                            controller: viewModel.lastNameController,
                            decoration: decoration,
                            placeholder: 'Enter last name',
                            isRequired: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _NameField(
                            label: 'FIRST NAME',
                            controller: viewModel.firstNameController,
                            decoration: decoration,
                            placeholder: 'Enter first name',
                            isRequired: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _NameField(
                            label: 'MIDDLE NAME',
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
            Text(
              'EMPLOYEE TYPE',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity, // Match the width of name fields container
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _EmployeeType(viewModel: viewModel),
            ),
            const SizedBox(height: 20),
            // Department section with label
            Text(
              'DEPARTMENT',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity, // Match the width of name fields and EmployeeType containers
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _DepartmentRow(viewModel: viewModel),
            ),
            const SizedBox(height: 20),
            // Extra Tags
            Text(
              'EXTRA TAGS (COMMA SEPARATED, IF APPLICABLE)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: viewModel.tagsController,
              maxLines: null,
              minLines: 1,
              style: const TextStyle(
                fontWeight: FontWeight.w300,
                color: Colors.black, // Black text when typing
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'i.e. non-teaching',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w300,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25), // Large pill-shaped border radius
                  borderSide: const BorderSide(color: Color(0xFFD4C4B0), width: 1), // Light brown/gray stroke
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFD4C4B0), width: 1), // Light brown/gray stroke
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFFFB47B), width: 2), // Peach/orange accent border when focused
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Match other input fields
              ),
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
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          final FormSubmissionResult result = await viewModel.submitForm();
                          
                          if (result.success && result.personnel != null) {
                            // Show success message
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Personnel added successfully: ${result.personnel!.fullName}'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              // Close the dialog
                              Navigator.of(context).pop();
                            }
                          } else {
                            // Show error message
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result.errorMessage ?? 'Failed to save personnel data'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB47B), // Peach/orange accent (original)
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            // Extra bottom padding to ensure dropdown always has space below
            const SizedBox(height: 100),
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
    
    return SizedBox(
      width: double.infinity, // Match the width of name fields container
      child: SegmentedButton<EmployeeType>(
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
          return const BorderSide(color: Color(0xFFE0E0E0), width: 1.5); // Fixed width to prevent movement
        }),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      ),
      ),
    );
  }
}

class _DepartmentRow extends StatefulWidget {
  const _DepartmentRow({required this.viewModel});
  final AddPersonnelViewModel viewModel;

  @override
  State<_DepartmentRow> createState() => _DepartmentRowState();
}

class _DepartmentRowState extends State<_DepartmentRow> {
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _closeDropdown();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (widget.viewModel.noDepartment && _isDropdownOpen) {
      _closeDropdown();
    }
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_isDropdownOpen) {
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  void _toggleDropdown() {
    if (widget.viewModel.noDepartment) return;

    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      final RenderBox? renderBox = _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final Size size = renderBox.size;
      final Offset position = renderBox.localToGlobal(Offset.zero);

      _overlayEntry = OverlayEntry(
        builder: (BuildContext context) => GestureDetector(
          onTap: () => _closeDropdown(),
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Container(color: Colors.transparent),
              ),
              Positioned(
                left: position.dx,
                top: position.dy + size.height,
                width: size.width,
                child: GestureDetector(
                  onTap: () {}, // Prevent closing when tapping inside the dropdown
                  child: Material(
                    elevation: 8,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: widget.viewModel.departments.length,
                        separatorBuilder: (BuildContext context, int index) => Container(
                          height: 1,
                          color: Colors.grey.shade200,
                          margin: const EdgeInsets.symmetric(horizontal: 0),
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final String department = widget.viewModel.departments[index];
                          final bool isSelected = widget.viewModel.selectedDepartment == department;
                          return InkWell(
                            onTap: () {
                              widget.viewModel.setDepartment(department);
                              _closeDropdown();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              color: isSelected ? const Color(0xFFF5F5F5) : Colors.white,
                              child: Row(
                                children: <Widget>[
                                  // Department name
                                  Expanded(
                                    child: Text(
                                      department,
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFFFFB47B) : Colors.black87,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  // Checkmark on the right for selected item
                                  if (isSelected)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      child: const Icon(
                                        Icons.check,
                                        color: Color(0xFFFFB47B),
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
      );

      Overlay.of(context).insert(_overlayEntry!);
      setState(() {
        _isDropdownOpen = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            key: _dropdownKey,
            onTap: _toggleDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100, // Light gray background
                borderRadius: BorderRadius.circular(18), // Pill-shaped with large radius
                border: Border.all(
                  color: _isDropdownOpen ? const Color(0xFFFFB47B) : const Color(0xFFE0E0E0),
                  width: _isDropdownOpen ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.viewModel.noDepartment
                          ? 'Select Department'
                          : (widget.viewModel.selectedDepartment ?? 'Select Department'),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: widget.viewModel.noDepartment || widget.viewModel.selectedDepartment == null
                            ? Colors.grey.shade600
                            : Colors.black,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.black87,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Checkbox(
              value: widget.viewModel.noDepartment,
              onChanged: (bool? v) {
                widget.viewModel.setNoDepartment(v ?? false);
                if (v == true) {
                  _closeDropdown();
                }
              },
              activeColor: const Color(0xFFFF6B9D), // Pink fill color
            ),
            const SizedBox(width: 4),
            Text(
              'Not part of any department.',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
            ),
            if (isRequired)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            if (isOptional)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '(OPTIONAL)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.3,
                        fontSize: 14,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.black, // Black text when typing
          ),
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

