import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/ui/add_employee/widgets/form_section.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ephor/ui/add_employee/view_model/add_employee_viewmodel.dart';
import 'package:ephor/utils/responsiveness.dart';

class AddEmployeeView extends StatefulWidget {
  final AddEmployeeViewModel viewModel;
  const AddEmployeeView({super.key, required this.viewModel});

  @override
  State<AddEmployeeView> createState() => _AddEmployeeViewState();
}

class _AddEmployeeViewState extends State<AddEmployeeView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addEmployee.addListener(_onCommandResult); 
  }

  @override
  void didUpdateWidget(covariant AddEmployeeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.addEmployee != widget.viewModel.addEmployee) {
      oldWidget.viewModel.addEmployee.removeListener(_onCommandResult);
      widget.viewModel.addEmployee.addListener(_onCommandResult);
    }
  }

  @override
  void dispose() {
    widget.viewModel.addEmployee.removeListener(_onCommandResult);
    widget.viewModel.dispose(); // Dispose controllers
    super.dispose();
  }

  void _onCommandResult() {
    if (!context.mounted) return;
    
    final command = widget.viewModel.addEmployee;
    final result = command.result;

    if (command.completed && result != null) {
      if (result case Ok(value: final employee)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee added successfully: ${employee.fullName}'),
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
                FormSection(viewModel: widget.viewModel),
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
                      listenable: widget.viewModel.addEmployee,
                      builder: (context, child) {
                        final bool isLoading = widget.viewModel.addEmployee.running;
                        return FilledButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  // Map form state to Command parameters
                                final bool requiresLogin = widget.viewModel.employeeRole == EmployeeRole.supervisor || 
                                                            widget.viewModel.employeeRole == EmployeeRole.humanResource;

                                // Only send non-null values if login is required
                                final String? email = requiresLogin ? widget.viewModel.emailController.text.trim() : null;
                                
                                  final params = (
                                    lastName: widget.viewModel.lastNameController.text.trim(),
                                    firstName: widget.viewModel.firstNameController.text.trim(),
                                    middleName: widget.viewModel.middleNameController.text.trim(),
                                    email: email,
                                    employeeRole: widget.viewModel.employeeRole,
                                    department: widget.viewModel.noDepartment ? null : widget.viewModel.selectedDepartment,
                                    tags: widget.viewModel.tagsController.text,
                                    photoUrl: widget.viewModel.photoUrl,
                                  );
                                  widget.viewModel.addEmployee.execute(params);
                                },
                            // ... (Button styling and loader remains the same) ...
                          child: isLoading
                              ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                  )
                              : const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w600)),
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
        title: const Text('Add New Employee', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
          tooltip: 'Back to Employee List',
        ),
      ),
      body: viewContent,
    );
  }
}