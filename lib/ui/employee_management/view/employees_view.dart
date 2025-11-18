// presentation/subviews/employee_list/view/employee_list_subview.dart (Updated)

import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/employee_management/view_model/employees_viewmodel.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class EmployeeListSubView extends StatelessWidget {
  final EmployeeListViewModel viewModel;
  
  const EmployeeListSubView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<EmployeeListViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Employee Directory'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () => context.go(Routes.getAddEmployeePath()), 
                ),
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
          SnackBar(content: Text(messageException.message), backgroundColor: Colors.red),
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
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            // 1. Picture (using placeholder/initials)
            leading: CircleAvatar(
              // In a real app, use employee.photoUrl and NetworkImage
              backgroundImage: employee.photoUrl != null ? NetworkImage(employee.photoUrl!) : null,
              child: employee.photoUrl == null ? Text(employee.fullName[0]) : null,
            ),
            // 2. Name
            title: Text(employee.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(employee.role.name),
            
            // 3. Remove Option
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
  Widget _buildEmptyState(BuildContext context) { /* ... */ return const Center(child: Text("Empty"));}
}