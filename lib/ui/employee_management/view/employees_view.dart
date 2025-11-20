// presentation/subviews/employee_list/view/employee_list_subview.dart (Updated)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/employee_management/view_model/employees_viewmodel.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class EmployeeListSubView extends StatefulWidget {
  final EmployeeListViewModel viewModel;
  
  const EmployeeListSubView({super.key, required this.viewModel});

  @override
  State<EmployeeListSubView> createState() => _EmployeeListSubViewState();
}

class _EmployeeListSubViewState extends State<EmployeeListSubView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadEmployees.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant EmployeeListSubView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.loadEmployees != widget.viewModel.loadEmployees) {
      oldWidget.viewModel.loadEmployees.removeListener(_onResult);
      widget.viewModel.loadEmployees.addListener(_onResult);
    }
  }

  @override
  void dispose() {
    widget.viewModel.loadEmployees.removeListener(_onResult);
    super.dispose();
  }

  Map<String?, String> textEquivalents = {
    'humanResource': "Human Resource",
    'supervisor': "Supervisor",
    'personnel': 'University Personnel',
    'faculty': 'Faculty Member',
    'jobOrder': 'Job-Order Employee',
    null: 'Not Applicable'
  };

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Consumer<EmployeeListViewModel>(
        builder: (context, viewModel, child) {
          final bool canAddUsers = viewModel.currentUserRole == EmployeeRole.humanResource;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Employees',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              actions: [
                canAddUsers
                ? IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () => context.go(Routes.getAddEmployeePath()), 
                )
                : const SizedBox.shrink(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: viewModel.isLoading ? null : () => viewModel.loadEmployees.execute(),
                ),
              ],
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.employees.isEmpty
                    ? _buildEmptyState(context)
                    : _buildEmployeeList(context, viewModel), // Pass context and vm
          );
        },
      ),
    );
  }

  // Helper method to build the employee list
  Widget _buildEmployeeList(BuildContext context, EmployeeListViewModel viewModel) {
    // Listener for command results (handling success/error messages)
    viewModel.deleteEmployee.addListener(() {
      if (viewModel.deleteEmployee.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee removed successfully!'), backgroundColor: Colors.green),
        );
        viewModel.deleteEmployee.clearResult();
      }
      if (viewModel.deleteEmployee.error) {
        Error error = viewModel.deleteEmployee.result as Error;
        CustomMessageException messageException = error.error as CustomMessageException;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              messageException.message
            ), 
            backgroundColor: Theme.of(context).colorScheme.errorContainer
          ),
        );
        viewModel.deleteEmployee.clearResult();
      }
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: viewModel.employees.length,
      itemBuilder: (context, index) {
        final employee = viewModel.employees[index];
        return Card(
          elevation: 0.2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: CachedNetworkImage(
              imageUrl: employee.photoUrl ?? 'Error',
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => CircleAvatar(
                child: Text(employee.fullName[0]),
              ),
              imageBuilder: (context, imageProvider) {
                return CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                  backgroundImage: imageProvider,
                );
              },
            ),
            title: Text(employee.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(textEquivalents[employee.role.name]!),
            trailing: IconButton(
              icon: viewModel.deleteEmployee.running
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Remove Employee',
              onPressed: viewModel.deleteEmployee.running
                  ? null 
                  : () => _confirmDelete(context, viewModel, employee),
            ),
            onTap: () {
              // Action on tapping the list tile
            },
          ),
        );
      },
    );
  }

  // Helper to show confirmation dialog
  void _confirmDelete(BuildContext context, EmployeeListViewModel vm, EmployeeModel employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to remove ${employee.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              vm.deleteEmployee.execute(employee.id); // Execute the command
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  // ... (Other helper methods like _buildEmptyState remain the same) ...
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined, 
            size: 80, 
            color: Theme.of(context).colorScheme.primary
          ),
          SizedBox(height: 16),
          Text('No Employees', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('The list might still be loading. Please wait.'),
        ],
      ),
    );
  }
  
  void _onResult() {
    if (widget.viewModel.loadEmployees.completed) {
      widget.viewModel.loadEmployees.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully Loaded employees."),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (widget.viewModel.loadEmployees.error) {
      widget.viewModel.loadEmployees.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading employees."),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
  }
}