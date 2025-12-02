import 'dart:io';

import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/ui/add_employee/view_model/add_employee_viewmodel.dart';
import 'package:ephor/ui/add_employee/widgets/department_row.dart';
import 'package:ephor/ui/add_employee/widgets/employee_type_chooser.dart';
import 'package:ephor/ui/add_employee/widgets/name_field.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/responsiveness.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FormSection extends StatefulWidget {
  const FormSection({super.key, required this.viewModel});
  final AddEmployeeViewModel viewModel;

  @override
  State<FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<FormSection> {
  @override
  void initState() {
    widget.viewModel.pickImage.addListener(_onImagePicked);
    widget.viewModel.clearImage.addListener(_onImageCleared);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FormSection oldWidget) {
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
                    child: kIsWeb
                      ? Image.network(
                          widget.viewModel.localImageFile!.path,
                          fit: BoxFit.cover,
                          width: 176,
                          height: 176,
                        )
                      : Image.file(
                          File(widget.viewModel.localImageFile!.path),
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
                        NameField(label: 'LAST NAME', controller: widget.viewModel.lastNameController, decoration: decoration, placeholder: 'Enter last name', isRequired: true),
                        const SizedBox(height: 12),
                        NameField(label: 'FIRST NAME', controller: widget.viewModel.firstNameController, decoration: decoration, placeholder: 'Enter first name', isRequired: true),
                        const SizedBox(height: 12),
                        NameField(label: 'MIDDLE NAME', controller: widget.viewModel.middleNameController, decoration: decoration, placeholder: 'Enter middle name', isOptional: true),
                      ],
                    )
                  : Row( // Row layout for Tablet/Desktop
                      children: <Widget>[
                        Expanded(child: NameField(label: 'LAST NAME', controller: widget.viewModel.lastNameController, decoration: decoration, placeholder: 'Enter last name', isRequired: true)),
                        const SizedBox(width: 8),
                        Expanded(child: NameField(label: 'FIRST NAME', controller: widget.viewModel.firstNameController, decoration: decoration, placeholder: 'Enter first name', isRequired: true)),
                        const SizedBox(width: 8),
                        Expanded(child: NameField(label: 'MIDDLE NAME', controller: widget.viewModel.middleNameController, decoration: decoration, placeholder: 'Enter middle name', isOptional: true)),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            
            // Employee Type (Role Selection)
            Text('EMPLOYEE TYPE', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity, 
              padding: const EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16)),
              child: EmployeeTypeChooser(viewModel: widget.viewModel),
            ),
            const SizedBox(height: 20),
            
            // 🔑 CONDITIONAL LOGIN FIELDS CONTAINER
            ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, child) {
                // Recalculate requiresLogin inside the builder to ensure updates
                final bool needsLogin = widget.viewModel.employeeRole == EmployeeRole.supervisor || 
                                        widget.viewModel.employeeRole == EmployeeRole.humanResource;
                
                if (!needsLogin) {
                  // Show a placeholder message when fields are hidden
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Note: Login is not required for this employee role (Email field is hidden).',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                }
                
                return Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Field
                      NameField(
                        label: 'EMAIL ADDRESS', 
                        controller: widget.viewModel.emailController,
                         decoration: decoration, 
                         placeholder: 'Enter employee email', 
                         isRequired: true,
                         isEmail: true,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),

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
                      child: DepartmentRow(viewModel: widget.viewModel),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Tags
            Text('EXTRA TAGS (COMMA SEPARATED, IF APPLICABLE)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: TextFormField(
                controller: widget.viewModel.tagsController, maxLines: null, minLines: 1,
                style: const TextStyle(fontWeight: FontWeight.w300, color: Colors.black),
                decoration: decoration.copyWith(
                  hintText: 'i.e. non-teaching',
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Color(0xFFD4C4B0), width: 1)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Color(0xFFFFB47B), width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
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