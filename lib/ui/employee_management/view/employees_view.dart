// presentation/subviews/employee_list/view/employee_list_subview.dart (Updated)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/core/ui/employee_info_popover/employee_info_popover.dart';
import 'package:ephor/ui/core/ui/svg_icon/svg_icon.dart';
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
  String sortMethodKey = 'name_ascending';
  bool _multiSelect = false;
  List<EmployeeModel> deleteableEmployees = [];

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadEmployees.addListener(_onResult);
    widget.viewModel.deleteEmployee.addListener(_onSingleDeleteFinished);
    widget.viewModel.deleteBatchEmployees.addListener(_onBatchDeleteFinished);
  }

  @override
  void didUpdateWidget(covariant EmployeeListSubView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.loadEmployees != widget.viewModel.loadEmployees) {
      oldWidget.viewModel.loadEmployees.removeListener(_onResult);
      widget.viewModel.loadEmployees.addListener(_onResult);
    }

    if (oldWidget.viewModel.deleteEmployee != widget.viewModel.deleteEmployee) {
      oldWidget.viewModel.deleteEmployee.removeListener(_onSingleDeleteFinished);
      widget.viewModel.deleteEmployee.addListener(_onSingleDeleteFinished);
    }

    if (oldWidget.viewModel.deleteBatchEmployees != widget.viewModel.deleteBatchEmployees) {
      oldWidget.viewModel.deleteBatchEmployees.removeListener(_onBatchDeleteFinished);
      widget.viewModel.deleteBatchEmployees.addListener(_onBatchDeleteFinished);
    }
  }

  @override
  void dispose() {
    widget.viewModel.loadEmployees.removeListener(_onResult);
    widget.viewModel.deleteEmployee.removeListener(_onSingleDeleteFinished);
    widget.viewModel.deleteBatchEmployees.removeListener(_onBatchDeleteFinished);
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

  void _onSingleDeleteFinished() {
    if (widget.viewModel.deleteEmployee.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee removed successfully!'), backgroundColor: Colors.green),
      );
      widget.viewModel.deleteEmployee.clearResult();
    }
    if (widget.viewModel.deleteEmployee.error) {
      Error error = widget.viewModel.deleteEmployee.result as Error;
      CustomMessageException messageException = error.error as CustomMessageException;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            messageException.message
          ), 
          backgroundColor: Theme.of(context).colorScheme.errorContainer
        ),
      );
      widget.viewModel.deleteEmployee.clearResult();
    }
  }

  void _onBatchDeleteFinished() {
    if (widget.viewModel.deleteBatchEmployees.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employees removed successfully!'), backgroundColor: Colors.green),
      );
      widget.viewModel.deleteBatchEmployees.clearResult();
    }
    if (widget.viewModel.deleteBatchEmployees.error) {
      Error error = widget.viewModel.deleteBatchEmployees.result as Error;
      CustomMessageException messageException = error.error as CustomMessageException;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            messageException.message
          ), 
          backgroundColor: Theme.of(context).colorScheme.errorContainer
        ),
      );
      widget.viewModel.deleteBatchEmployees.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Consumer<EmployeeListViewModel>(
        builder: (context, viewModel, child) {
          final bool isUserHR = viewModel.currentUser?.role == EmployeeRole.humanResource;
          final String? department = viewModel.currentUser?.department;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                isUserHR ? 'Employees' : department != null ? '$department Employees' : 'Employees',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              actionsPadding: EdgeInsets.only(right: 8),
              actions: [
                if (_multiSelect) IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    tooltip: 'Delete selected Employees',
                    onPressed: viewModel.deleteEmployee.running
                      ? null
                      : deleteableEmployees.isNotEmpty
                        ? () => _confirmDelete(context, viewModel, deleteableEmployees)
                        : null, 
                ),
                if (isUserHR) IconButton(
                    icon: const Icon(Icons.person_add),
                    tooltip: 'Add a User',
                    onPressed: () => context.go(Routes.getAddEmployeePath()), 
                ),
                if (isUserHR) IconButton(
                    icon: const SvgIcon(
                      'assets/images/batch_add.svg',
                      size: 24,
                    ),
                    tooltip: 'Add Multiple Users',
                    onPressed: () => context.go(Routes.getBatchAddEmployeePath()), 
                ),
                if (isUserHR) IconButton(
                    icon: _multiSelect
                      ? Icon (
                          Icons.cancel_outlined,
                          color: Theme.of(context).colorScheme.error,
                        )
                      : const SvgIcon(
                          'assets/images/batch_delete.svg',
                          size: 24,
                        ),
                    tooltip: 'Batch Delete Users',
                    onPressed: () {
                      setState(() {
                        _multiSelect = !_multiSelect;
                      });
                    }, 
                ),
                PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  tooltip: 'Sort Employee List',
                  child: Icon(Icons.sort),
                  // Menu Items 
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'name_ascending',
                      child: Row(children: [Icon(Icons.arrow_upward, color: Colors.black87), SizedBox(width: 8), Text('Names (Ascending)')]),
                    ),
                    const PopupMenuItem<String>(
                      value: 'name_descending',
                      child: Row(children: [Icon(Icons.arrow_downward, color: Colors.black87), SizedBox(width: 8), Text('Names (Descending)')]),
                    ),
                    const PopupMenuItem<String>(
                      value: 'role_ascending',
                      child: Row(children: [Icon(Icons.keyboard_arrow_up, color: Colors.black87), SizedBox(width: 8), Text('Roles (Ascending)')]),
                    ),
                    const PopupMenuItem<String>(
                      value: 'role_descending',
                      child: Row(children: [Icon(Icons.keyboard_arrow_down, color: Colors.black87), SizedBox(width: 8), Text('Roles (Descending)')]),
                    ),
                  ],
                  onSelected: (String result) {
                    setState(() {
                      sortMethodKey = result;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh the List',
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

    final bool canEditUsers = viewModel.currentUser?.role == EmployeeRole.humanResource;
    List<EmployeeModel> employeeList = viewModel.employees;

    switch(sortMethodKey) {
      case 'name_ascending':
        employeeList.sort((a, b) => 
          a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        break;
      case 'name_descending':
        employeeList.sort((a, b) => 
          b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()));
        break;
      case 'role_ascending':
        employeeList.sort((a, b) {
          int roleComparison = a.role.index.compareTo(b.role.index);
          if (roleComparison != 0) return roleComparison;
          
          // Tie-breaker: If roles are same, sort by Name A-Z
          return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
        });
        break;
      case 'role_descending':
        employeeList.sort((a, b) {
          int roleComparison = b.role.index.compareTo(a.role.index);
          if (roleComparison != 0) return roleComparison;
          
          // Tie-breaker: If roles are same, still sort by Name A-Z (easier to read)
          return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
        });
        break;
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: employeeList.length,
      itemBuilder: (context, index) {
        final employee = employeeList[index];

        if (viewModel.currentUser?.role == EmployeeRole.supervisor && (
          employee.role == EmployeeRole.humanResource 
          || employee.department != viewModel.currentUser?.department)) {
          return const SizedBox.shrink();
        }

        // 1. Define the Fallback Avatar (Used if URL is invalid OR if network fails)
        final Widget fallbackAvatar = CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            employee.fullName.isNotEmpty ? employee.fullName[0] : '?',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
        );

        // 2. Check if the URL is valid (Not null AND starts with http/https)
        final bool hasValidUrl = employee.photoUrl != null && 
                                employee.photoUrl!.startsWith('http');

        return Card(
          elevation: 0.25,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: GestureDetector(
            child: ListTile(
              leading: _multiSelect
                ? Checkbox(
                    value: deleteableEmployees.contains(employee), 
                    onChanged: (value) {
                      setState(() {
                        if (value != null && value) {
                          deleteableEmployees.add(employee);
                        } else {
                          deleteableEmployees.remove(employee);
                        }
                      });
                    }
                  )
                : hasValidUrl
                  ? CachedNetworkImage(
                      imageUrl: employee.photoUrl!,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => fallbackAvatar,
                      imageBuilder: (context, imageProvider) {
                        return CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                          backgroundImage: imageProvider,
                        );
                      },
                    )
                  : fallbackAvatar,
              title: Text(
                employee.fullName, 
                style: const TextStyle(fontWeight: FontWeight.w600)
              ),
              subtitle: Text(textEquivalents[employee.role.name] ?? employee.role.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  if (canEditUsers)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit Employee',
                      onPressed: viewModel.deleteEmployee.running
                          ? null
                          : () => context.goNamed(
                                'edit_employee',
                                queryParameters: {
                                  'fromUser': 'false',
                                  'code': employee.employeeCode
                                },
                              ),
                    ),
                  IconButton(
                    icon: viewModel.deleteEmployee.running
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Remove Employee',
                    onPressed: viewModel.deleteEmployee.running
                        ? null
                        : () => _confirmDelete(context, viewModel, [employee]),
                  ),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: EmployeeInfoPopover(employee: employee),
                      constraints: BoxConstraints.tight(const Size(350, 500)),
                      contentPadding: EdgeInsets.zero,
                      titlePadding: EdgeInsets.zero,
                      iconPadding: EdgeInsets.zero,
                      actionsPadding: EdgeInsets.zero,
                      insetPadding: EdgeInsets.zero,
                      backgroundColor: const Color(0x00000000),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Helper to show confirmation dialog
  void _confirmDelete(BuildContext context, EmployeeListViewModel vm, List<EmployeeModel> employeesForDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: employeesForDelete.length == 1
          ? Text('Are you sure you want to remove ${employeesForDelete.first.fullName}?')
          : Text('Are you sure you want to remove ${employeesForDelete.first.fullName}, and ${employeesForDelete.length - 1} others?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              if (employeesForDelete.length == 1) {
                await vm.deleteEmployee.execute(employeesForDelete.first);
              } else {
                await vm.deleteBatchEmployees.execute(employeesForDelete);
              }

              setState(() {
                // 3. Clear the selection list after deletion
                deleteableEmployees.clear(); 
                _multiSelect = false; // Optional: exit selection mode
              });
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