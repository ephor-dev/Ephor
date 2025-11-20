import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/ui/edit_employee/view_model/edit_employee_viewmodel.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ephor/utils/responsiveness.dart'; 

class EditEmployeeView extends StatefulWidget {
  final EditEmployeeViewModel viewModel;
  const EditEmployeeView({super.key, required this.viewModel});

  @override
  State<EditEmployeeView> createState() => _EditEmployeeViewState();
}

class _EditEmployeeViewState extends State<EditEmployeeView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.editEmployee.addListener(_onCommandResult); 
  }

  @override
  void didUpdateWidget(covariant EditEmployeeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.editEmployee != widget.viewModel.editEmployee) {
      oldWidget.viewModel.editEmployee.removeListener(_onCommandResult);
      widget.viewModel.editEmployee.addListener(_onCommandResult);
    }
  }

  @override
  void dispose() {
    widget.viewModel.editEmployee.removeListener(_onCommandResult);
    widget.viewModel.dispose();
    super.dispose();
  }

  void _onCommandResult() {
    if (!context.mounted) return;
    
    final command = widget.viewModel.editEmployee;
    final result = command.result;

    if (command.completed && result != null) {
      if (result case Ok(value: final employee)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee edited successfully: ${employee.fullName}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
        command.clearResult();
      } 
    } else if (result case Error(error: final CustomMessageException e)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      command.clearResult();
    }
  }

  // --- UI Build Logic (Flattened Content) ---

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final EdgeInsets outerPadding = isMobile ? const EdgeInsets.all(16) : const EdgeInsets.all(24);
    
    Container viewContent = Container(
      alignment: Alignment.topCenter,
      padding: outerPadding,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: isMobile ? const EdgeInsets.all(20) : const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _FormSection(viewModel: widget.viewModel),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87, side: const BorderSide(color: Color(0xFFE0E0E0)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 12),
                    
                    // Confirm Button (ListenableBuilder)
                    ListenableBuilder(
                      listenable: widget.viewModel.editEmployee,
                      builder: (context, child) {
                        final bool isLoading = widget.viewModel.editEmployee.running;
                        return FilledButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  final params = (
                                    lastName: widget.viewModel.lastNameController.text.trim(),
                                    firstName: widget.viewModel.firstNameController.text.trim(),
                                    middleName: widget.viewModel.middleNameController.text.trim(),
                                    employeeRole: widget.viewModel.employeeRole,
                                    department: widget.viewModel.noDepartment ? null : widget.viewModel.selectedDepartment,
                                    tags: widget.viewModel.tagsController.text,
                                    photoUrl: widget.viewModel.photoUrl,
                                  );
                                  widget.viewModel.editEmployee.execute(params);
                                },
                            // ... (Button styling and loader remains the same) ...
                          child: isLoading
                              ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                  )
                              : const Text('Confirm Edit', style: TextStyle(fontWeight: FontWeight.w600)),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        title: const Text('Edit Employee Information', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
          tooltip: 'Back to Previous',
        ),
      ),
      body: viewContent,
    );
  }
}

// -----------------------------------------------------------------------------
// --- SUPPORTING WIDGETS ---
// -----------------------------------------------------------------------------

// 4. Form Section (Handles responsiveness for internal layouts)
class _FormSection extends StatefulWidget {
  const _FormSection({required this.viewModel});
  final EditEmployeeViewModel viewModel;

  @override
  State<_FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<_FormSection> {

  @override
  void initState() {
    widget.viewModel.pickImage.addListener(_onImagePicked);
    widget.viewModel.clearImage.addListener(_onImageCleared);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _FormSection oldWidget) {
    if (oldWidget.viewModel.pickImage != widget.viewModel.pickImage) {
      oldWidget.viewModel.pickImage.removeListener(_onImageCleared);
      widget.viewModel.pickImage.addListener(_onImageCleared);
    }

    if (oldWidget.viewModel.clearImage != widget.viewModel.clearImage) {
      oldWidget.viewModel.clearImage.removeListener(_onImageCleared);
      widget.viewModel.clearImage.addListener(_onImageCleared);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.viewModel.pickImage.removeListener(_onImagePicked);
    widget.viewModel.clearImage.removeListener(_onImageCleared);
    super.dispose();
  }

  void _onImagePicked() {
    if (!context.mounted) return;

    final command = widget.viewModel.pickImage;
    final result = command.result;

    if (command.completed && result != null) {
      if (result case Ok(value: _)) {
        setState(() {
        });
        command.clearResult();
      }
    } else if (result case Error(error: final CustomMessageException e)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      command.clearResult();
    }
  }

  void _onImageCleared() {
    if (!context.mounted) return;

    final command = widget.viewModel.clearImage;
    final result = command.result;

    if (command.completed && result != null) {
      if (result case Ok(value: _)) {
        setState(() {
        });
        command.clearResult();
      }
    }
  }

  final InputDecoration decoration = const InputDecoration(
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: Color(0xFFE0E0E0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: Color(0xFFE0E0E0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: Color(0xFFFFB47B), width: 2)),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: TextStyle(color: Color.fromRGBO(189, 189, 189, 1), fontWeight: FontWeight.w300),
  );

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    // --- Left Column (Image Upload) ---
    final Widget imageCol = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          onTap: () => widget.viewModel.pickImage.execute(),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 200, height: 200,
            padding: widget.viewModel.localImageFile != null
              ? EdgeInsets.all(24)
              : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8CC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 2, style: BorderStyle.solid),
            ),
            child: widget.viewModel.localImageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      widget.viewModel.localImageFile!,
                      fit: BoxFit.cover,
                      width: 176,
                      height: 176,

                    ),
                  )
                : const Center(child: Icon(Icons.person_outline, size: 56, color: Color(0xFF9E9E9E))),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 130, // Adjusted width for two buttons
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFB47B), side: const BorderSide(color: Color(0xFFFFB47B), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => widget.viewModel.pickImage.execute(),
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Upload', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
            if (widget.viewModel.localImageFile != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => widget.viewModel.clearImage.execute(),
                tooltip: 'Clear image',
              ),
            ]
          ],
        )
      ],
    );

    // --- Right Column (Form Inputs) ---
    final Widget rightColumn = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: double.infinity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Name Fields (Responsive Row/Column using isMobile)
            // Name field section with necessary padding/decoration
            Container(
              padding: const EdgeInsets.all(16), 
              decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16)), 
              child: isMobile
                  ? Column( // Column layout for mobile
                      children: <Widget>[
                        _NameField(label: 'LAST NAME', controller: widget.viewModel.lastNameController, decoration: decoration, placeholder: 'Enter last name (leave blank to keep as is.)', isOptional: true),
                        const SizedBox(height: 12),
                        _NameField(label: 'FIRST NAME', controller: widget.viewModel.firstNameController, decoration: decoration, placeholder: 'Enter first name (leave blank to keep as is.)', isOptional: true),
                        const SizedBox(height: 12),
                        _NameField(label: 'MIDDLE NAME', controller: widget.viewModel.middleNameController, decoration: decoration, placeholder: 'Enter middle name (leave blank to keep as is.)', isOptional: true),
                      ],
                    )
                  : Row( // Row layout for Tablet/Desktop
                      children: <Widget>[
                        Expanded(child: _NameField(label: 'LAST NAME', controller: widget.viewModel.lastNameController, decoration: decoration, placeholder: 'Enter last name (leave blank to keep as is.)', isOptional: true)),
                        const SizedBox(width: 8),
                        Expanded(child: _NameField(label: 'FIRST NAME', controller: widget.viewModel.firstNameController, decoration: decoration, placeholder: 'Enter first name (leave blank to keep as is.)', isOptional: true)),
                        const SizedBox(width: 8),
                        Expanded(child: _NameField(label: 'MIDDLE NAME', controller: widget.viewModel.middleNameController, decoration: decoration, placeholder: 'Enter middle name (leave blank to keep as is.)', isOptional: true)),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            
            // Employee Type (Role Selection)
            Text('EMPLOYEE TYPE', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity, padding: const EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16)),
              child: _EmployeeType(viewModel: widget.viewModel),
            ),
            const SizedBox(height: 20),

            // Department (Conditionally disabled by HR role)
            Text('DEPARTMENT', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, child) {
                // Department selection is disabled if the role is Human Resource
                final bool isDepartmentDisabled = widget.viewModel.employeeRole == EmployeeRole.humanResource;
                
                return Opacity(
                  opacity: isDepartmentDisabled ? 0.5 : 1.0,
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.only(left: 16, right: 16),
                    decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16)),
                    child: IgnorePointer(
                      ignoring: isDepartmentDisabled, // Disable interaction
                      child: _DepartmentRow(viewModel: widget.viewModel),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Tags
            Text('EXTRA TAGS (COMMA SEPARATED, IF APPLICABLE)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.viewModel.tagsController, maxLines: null, minLines: 1,
              style: const TextStyle(fontWeight: FontWeight.w300, color: Colors.black),
              decoration: decoration.copyWith(
                hintText: 'i.e. non-teaching',
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Color(0xFFD4C4B0), width: 1)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Color(0xFFFFB47B), width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );

    // --- Final Layout Decision (remains the same) ---
    if (isMobile) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Center(child: imageCol), const SizedBox(height: 24), rightColumn]);
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[imageCol, const SizedBox(width: 24), Expanded(child: rightColumn)]);
  }
}


// 5. Segmented Button for Employee Role
class _EmployeeType extends StatefulWidget {
  const _EmployeeType({required this.viewModel});
  final EditEmployeeViewModel viewModel;

  @override
  State<_EmployeeType> createState() => _EmployeeTypeState();
}

class _EmployeeTypeState extends State<_EmployeeType> {
  // Assuming EmployeeRole is an enum defined elsewhere
  EmployeeRole _currentSelection = EmployeeRole.personnel; 
  
  @override
  void initState() {
    super.initState();
    _currentSelection = widget.viewModel.employeeRole;
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFFFFB47B); 
    final Color inactiveBg = const Color(0xFFF5F5F5);

    final bool isSelfEditing = widget.viewModel.fromUser; 
    
    return Opacity(
      opacity: isSelfEditing ? 0.5 : 1.0,
      child: IgnorePointer(
        ignoring: isSelfEditing,
        child: SizedBox(
          width: double.infinity,
          child: SegmentedButton<EmployeeRole>(
          segments: <ButtonSegment<EmployeeRole>>[
            ButtonSegment<EmployeeRole>(
              value: EmployeeRole.personnel,
              label: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.business_center, size: 18), SizedBox(width: 6), Text('Personnel', style: TextStyle(fontWeight: FontWeight.w500))]),
            ),
            ButtonSegment<EmployeeRole>(
              value: EmployeeRole.faculty,
              label: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.school, size: 18), SizedBox(width: 6), Text('Faculty', style: TextStyle(fontWeight: FontWeight.w500))]),
            ),
            ButtonSegment<EmployeeRole>(
              value: EmployeeRole.jobOrder,
              label: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.work_outline, size: 18), SizedBox(width: 6), Text('Job Order', style: TextStyle(fontWeight: FontWeight.w500))]),
            ),
            // Assuming these roles exist in your EmployeeRole enum:
            ButtonSegment<EmployeeRole>(
              value: EmployeeRole.supervisor,
              label: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.person, size: 18), SizedBox(width: 6), Text('Supervisor', style: TextStyle(fontWeight: FontWeight.w500))]),
            ),
            ButtonSegment<EmployeeRole>(
              value: EmployeeRole.humanResource,
              label: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.people, size: 18), SizedBox(width: 6), Text('HR', style: TextStyle(fontWeight: FontWeight.w500))]),
            ),
          ],
          selected: <EmployeeRole>{_currentSelection},
          onSelectionChanged: (Set<EmployeeRole> newSelection) {
            if (newSelection.isNotEmpty) {
              setState(() {
                _currentSelection = newSelection.first;
              });
              // Notify the VM, which triggers the conditional display logic
              widget.viewModel.setEmployeeRole(newSelection.first); 
            }
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              return states.contains(WidgetState.selected) ? accentColor : inactiveBg;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              return states.contains(WidgetState.selected) ? Colors.white : Colors.black87;
            }),
            side: WidgetStateProperty.resolveWith<BorderSide?>((Set<WidgetState> states) {
              return states.contains(WidgetState.selected) ? BorderSide(color: accentColor, width: 1.5) : const BorderSide(color: Color(0xFFE0E0E0), width: 1.5);
            }),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
          ),
        ),
      ),
    );
  }
}

// 6. Custom Dropdown/Checkbox row for department selection
class _DepartmentRow extends StatefulWidget {
  const _DepartmentRow({required this.viewModel});
  final EditEmployeeViewModel viewModel;

  @override
  State<_DepartmentRow> createState() => _DepartmentRowState();
}

class _DepartmentRowState extends State<_DepartmentRow> {
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
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
                Positioned.fill(child: Container(color: Colors.transparent)),
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
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE0E0E0))),
                        child: ListView.separated(
                          shrinkWrap: true, padding: EdgeInsets.zero,
                          itemCount: widget.viewModel.departments.length,
                          separatorBuilder: (BuildContext context, int index) => Container(
                            height: 1, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 0),
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
                                      child: Text(department, style: TextStyle(
                                        color: isSelected ? const Color(0xFFFFB47B) : Colors.black87,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        fontSize: 15,
                                      )),
                                    ),
                                    if (isSelected)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: const Icon(Icons.check, color: Color(0xFFFFB47B), size: 20),
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

    List<Widget> contents = <Widget>[
      Expanded(
        child: GestureDetector(
          key: _dropdownKey,
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100, borderRadius: BorderRadius.circular(18),
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
                    widget.viewModel.noDepartment ? 'Select Department' : (widget.viewModel.selectedDepartment ?? 'Select Department'),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: widget.viewModel.noDepartment || widget.viewModel.selectedDepartment == null ? Colors.grey.shade600 : Colors.black,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.black87, size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      // Use ListenableBuilder here to update when the ViewModel state changes
      ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          return Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Checkbox(
                  value: widget.viewModel.noDepartment,
                  onChanged: (bool? v) {
                    widget.viewModel.setNoDepartment(v ?? false);
                    if (v == true && _isDropdownOpen) {
                      _closeDropdown();
                    }
                  },
                  activeColor: const Color(0xFFFF6B9D),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Not part of any department.', 
                  style: TextStyle(
                    color: Colors.black87, 
                    fontWeight: FontWeight.w400, 
                    fontSize: 14
                  )
                ),
              ],
            ),
          );
        }
      ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center,
      children: contents
    );
  }
}

// 7. Standard Text Input Field
class _NameField extends StatelessWidget {
  const _NameField({
    required this.label, required this.controller, required this.decoration,
    required this.placeholder, this.isOptional = false,
  });

  final String label; final TextEditingController controller; final InputDecoration decoration;
  final String placeholder; final bool isOptional;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87, letterSpacing: 0.5)),
            if (isOptional)
              Padding(padding: const EdgeInsets.only(left: 4), child: Text('(OPTIONAL)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400, color: Colors.grey.shade600, letterSpacing: 0.3, fontSize: 14))),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(controller: controller, style: const TextStyle(fontWeight: FontWeight.w300, color: Colors.black), decoration: decoration.copyWith(hintText: placeholder)),
      ],
    );
  }
}