// ui/add_employee/view/add_employee_view.dart

import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ephor/ui/add_employee/view_model/add_employee_viewmodel.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/data/repositories/employee/abstract_employee_repository.dart'; // Repository dependency

// This is the new entry point for the Dialog.
class AddEmployeeView extends StatelessWidget {
  const AddEmployeeView({super.key});

  // Static method to show the modal with scoped dependencies
  static Future<void> show(BuildContext context) {
    // 1. Get the repository dependency from the nearest Provider scope
    final AbstractEmployeeRepository repository = context.read<AbstractEmployeeRepository>();
    
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54, // Semi-transparent gray background
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        // 2. Provide the ViewModel scoped ONLY to the dialog's lifecycle
        return ChangeNotifierProvider<AddEmployeeViewModel>(
          create: (_) {
            final viewModel = AddEmployeeViewModel(repository: repository);
            viewModel.initialize(); // Initialize the Command
            return viewModel;
          },
          child: const _AddEmployeeViewContent(), 
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget should remain minimal/unused if 'show' is the primary method
    return const SizedBox.shrink(); 
  }
}

class _AddEmployeeViewContent extends StatefulWidget {
  const _AddEmployeeViewContent();

  @override
  State<_AddEmployeeViewContent> createState() => _AddEmployeeViewContentState();
}

class _AddEmployeeViewContentState extends State<_AddEmployeeViewContent> {
  // We manage the VM lifecycle and listeners here
  late final AddEmployeeViewModel viewModel;
  
  @override
  void initState() {
    super.initState();
    viewModel = context.read<AddEmployeeViewModel>(); 
    // Set up listeners for post-command navigation/feedback
    viewModel.addEmployee.addListener(_onCommandResult); 
  }

  @override
  void dispose() {
    viewModel.addEmployee.removeListener(_onCommandResult);
    viewModel.dispose(); // Dispose controllers
    super.dispose();
  }

  void _onCommandResult() {
    // Use `if (context.mounted)` before accessing context after an await/async operation
    if (!context.mounted) return;
    
    final command = viewModel.addEmployee;
    final result = command.result;

    if (command.completed && result != null) {
      if (result case Ok(value: final employee)) {
        // Show Success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee added successfully: ${employee!.fullName}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
        command.clearResult();
      }
    } else if (command.error && result != null) {
      if (result case Error(error: final e)) {
        // Show Error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        command.clearResult();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use ListenableBuilder if only a part of the Dialog needed rebuilding,
    // but the Dialog content itself can just access the VM directly.
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          // ... (BoxShadows remain the same) ...
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000), 
              blurRadius: 24,
              offset: Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: _AddEmployeeContent(viewModel: viewModel),
      ),
    );
  }
}

// Modal content widget (no AppBar/Drawer needed)
class _AddEmployeeContent extends StatelessWidget {
  const _AddEmployeeContent({required this.viewModel});

  final AddEmployeeViewModel viewModel;

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
                        'Add Employee', // Renamed title
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

                // --- Action Buttons (Updated to use ListenableBuilder) ---
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      // ... (Styling remains the same) ...
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 12),
                    ListenableBuilder(
                      listenable: viewModel.addEmployee,
                      builder: (context, child) {
                        final bool isLoading = viewModel.addEmployee.running;
                        return FilledButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  // Gather all form data from controllers and internal VM state
                                  final params = (
                                    lastName: viewModel.lastNameController.text.trim(),
                                    firstName: viewModel.firstNameController.text.trim(),
                                    middleName: viewModel.middleNameController.text.trim(),
                                    employeeType: viewModel.employeeType,
                                    department: viewModel.noDepartment ? null : viewModel.selectedDepartment,
                                    tags: viewModel.tagsController.text,
                                    photoUrl: viewModel.photoUrl,
                                  );
                                  viewModel.addEmployee.execute(params);
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB47B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w600)),
                        );
                      },
                    ),
                  ],
                ),
                // Extra bottom padding to ensure dropdown always has space below
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}

// The main responsive form container
class _FormSection extends StatelessWidget {
  const _FormSection({required this.viewModel, required this.isNarrow});
  final AddEmployeeViewModel viewModel;
  final bool isNarrow;

  // Modern input decoration setup (Copied from original code for consistency)
  final InputDecoration decoration = const InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xFFFFB47B), width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: TextStyle(
      color: Color.fromRGBO(189, 189, 189, 1),
      fontWeight: FontWeight.w300,
    ),
  );

  @override
  Widget build(BuildContext context) {
    const double formMaxWidth = 760;

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
              color: const Color(0xFFFFE8CC),
              borderRadius: BorderRadius.circular(16),
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
              foregroundColor: const Color(0xFFFFB47B),
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

    // Right column: All form fields aligned and centered
    final Widget rightColumn = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: formMaxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Name fields row
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
            // Employee Type section
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
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _EmployeeType(viewModel: viewModel),
            ),
            const SizedBox(height: 20),
            // Department section
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
              width: double.infinity,
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
                color: Colors.black,
              ),
              decoration: decoration.copyWith(
                hintText: 'i.e. non-teaching',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFD4C4B0), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFFFB47B), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
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

// Custom Dropdown/Checkbox row for department selection
class _DepartmentRow extends StatefulWidget {
  const _DepartmentRow({required this.viewModel});
  final AddEmployeeViewModel viewModel;

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
  }

  // NOTE: The ViewModel does not need to be a ChangeNotifier 
  // if you manage its state updates via its methods and use local State/ListenableBuilder/etc.

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
                  onTap: () {},
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
    // Rebuilding this widget ensures the selected text and checkbox state are fresh
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
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
                  // Update VM, then trigger local state change
                  widget.viewModel.setNoDepartment(v ?? false);
                  setState(() {
                    if (v == true && _isDropdownOpen) {
                      _closeDropdown();
                    }
                  });
                },
                activeColor: const Color(0xFFFF6B9D),
              ),
              const SizedBox(width: 4),
              const Text(
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

// Standard text input field with custom label logic
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
            color: Colors.black,
          ),
          decoration: decoration.copyWith(hintText: placeholder),
        ),
      ],
    );
  }
}
// All supporting classes (_FormSection, _EmployeeType, _DepartmentRow, _NameField) 
// need minimal updates to their text/references (e.g., changing 'personnel' text to 'employee').
// I will include one example (_EmployeeType) with its updated logic.

class _EmployeeType extends StatefulWidget { // Changed to StatefulWidget to handle local selection rebuilds
  const _EmployeeType({required this.viewModel});
  final AddEmployeeViewModel viewModel;

  @override
  State<_EmployeeType> createState() => _EmployeeTypeState();
}

class _EmployeeTypeState extends State<_EmployeeType> {
  // Use local state to rebuild ONLY the segmented button, not the entire _AddEmployeeContent
  EmployeeType _currentSelection = EmployeeType.personnel; 
  
  @override
  void initState() {
    super.initState();
    _currentSelection = widget.viewModel.employeeType;
  }

  @override
  Widget build(BuildContext context) {
    // final Color accentColor = const Color(0xFFFFB47B); 
    // final Color inactiveBg = const Color(0xFFF5F5F5); 
    
    return SizedBox(
      width: double.infinity,
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
      selected: <EmployeeType>{_currentSelection}, // Use local state
      onSelectionChanged: (Set<EmployeeType> newSelection) {
        if (newSelection.isNotEmpty) {
          setState(() {
            _currentSelection = newSelection.first; // Update local state for rebuild
          });
          widget.viewModel.setEmployeeType(newSelection.first); // Update ViewModel state
        }
      },
      // ... (Styling remains the same) ...
      ),
    );
  }
}

// ... (Other supporting classes like _FormSection, _DepartmentRow, _NameField remain structurally similar) ...