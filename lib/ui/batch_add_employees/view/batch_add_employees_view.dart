import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/ui/batch_add_employees/view_model/batch_add_employees_viewmodel.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:go_router/go_router.dart';

class BatchAddEmployeesView extends StatefulWidget {
  final BatchAddEmployeesViewModel viewModel;
  const BatchAddEmployeesView({
    super.key,
    required this.viewModel
  });

  @override
  State<StatefulWidget> createState() => _BatchAddEmployeesViewState();
}

class _BatchAddEmployeesViewState extends State<BatchAddEmployeesView> {
  List<EmployeeModel> _employeeList = List.empty();

  @override
  void initState() {
    widget.viewModel.pickCSV.addListener(_onCommandResult);
    widget.viewModel.loadCSV.addListener(_onCSVLoaded);
    widget.viewModel.addEmployees.addListener(_onEmployeesAdded);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BatchAddEmployeesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.pickCSV != widget.viewModel.pickCSV) {
      oldWidget.viewModel.pickCSV.removeListener(_onCommandResult);
      widget.viewModel.pickCSV.addListener(_onCommandResult);
    }

    if (oldWidget.viewModel.loadCSV != widget.viewModel.loadCSV) {
      oldWidget.viewModel.loadCSV.removeListener(_onCSVLoaded);
      widget.viewModel.loadCSV.addListener(_onCSVLoaded);
    }

    if (oldWidget.viewModel.addEmployees != widget.viewModel.addEmployees) {
      oldWidget.viewModel.addEmployees.removeListener(_onEmployeesAdded);
      widget.viewModel.addEmployees.addListener(_onEmployeesAdded);
    }
  }

  @override
  void dispose() {
    widget.viewModel.pickCSV.removeListener(_onCommandResult);
    widget.viewModel.loadCSV.removeListener(_onCSVLoaded);
    widget.viewModel.addEmployees.removeListener(_onEmployeesAdded);
    super.dispose();
  }

  void _onCommandResult() {
    if (!context.mounted) return;
    
    final command = widget.viewModel.pickCSV;
    final result = command.result;

    if (command.completed && result != null) {
      if (result case Ok(value: final String csv)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded csv file successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        widget.viewModel.loadCSV.execute(csv);
        command.clearResult();
      } 
    } else if (result case Error(error: final CustomMessageException e)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
      command.clearResult();
    }
  }

  void _onCSVLoaded () {
    if (!context.mounted) return;
    
    final command = widget.viewModel.loadCSV;
    final result = command.result;

    if (command.completed && result != null) {
      if (result case Ok(value: final employeeList)) {
        setState(() {
          _employeeList = employeeList;
        });
        command.clearResult();
      } 
    } else if (result case Error(error: final CustomMessageException e)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
      command.clearResult();
    }
  }

  void _onEmployeesAdded() {
    if (!context.mounted) return;
    
    final command = widget.viewModel.addEmployees;
    final result = command.result;

    if (command.completed && result != null) {
      if (result case Ok(value: _)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully Added Employees'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        command.clearResult();
        context.pop();
      } 
    } else if (result case Error(error: final CustomMessageException e)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
      command.clearResult();
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget viewContent = Padding(
      padding: const EdgeInsets.all(16.0), // Padding around the content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Import Buttons Row (Fixed height) ---
          Row(
            children: [
              const Text("Add Employees: "),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => widget.viewModel.pickCSV.execute(), 
                child: const Text("Import from CSV"),
              ),
              if (_employeeList.isNotEmpty) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
                  onPressed: () {
                    setState(() {
                      _employeeList = List.empty();
                    });
                  },
                  tooltip: 'Clear',
                ),
              ]
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),
          
          // --- 2. DataTable2 (Wrapped in Expanded to fill remaining space) ---
          Expanded(
            child: ListenableBuilder(
              listenable: widget.viewModel.loadCSV,
              builder: (context, child) {
                if (widget.viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator(),);
                }

                if (_employeeList.isEmpty) {
                  return const Center(
                    child: Text("No data imported yet."),
                  );
                }

                return DataTable2(
                  minWidth: 800, // Increased for desktop/web use case
                  columnSpacing: 16,
                  horizontalMargin: 16,
                  dataRowHeight: 50,
                  headingRowHeight: 40,
                  empty: const Center(child: Text('No user data to display.')),
                  
                  // Define Columns
                  columns: const [
                    DataColumn2(label: Text('Last Name'), size: ColumnSize.S),
                    DataColumn2(label: Text('First Name'), size: ColumnSize.S),
                    DataColumn2(label: Text('Middle Name'), size: ColumnSize.S),
                    DataColumn2(label: Text('Department'), size: ColumnSize.M),
                    DataColumn2(label: Text('Role'), size: ColumnSize.M),
                    DataColumn2(label: Text('Email'), size: ColumnSize.M)
                  ],
                  
                  // Define Rows
                  rows: _employeeList.map((employee) {
                    return DataRow(
                      cells: [
                        DataCell(Text(employee.lastName)),
                        DataCell(Text(employee.firstName)),
                        DataCell(Text(employee.middleName ?? '')),
                        DataCell(Text(employee.department)),
                        DataCell(Text(employee.role.displayName)),
                        DataCell(Text(employee.email))
                      ],
                    );
                  }).toList()
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // --- 3. Action Buttons (Optional footer) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  widget.viewModel.addEmployees.execute(_employeeList);
                },
                child: const Text('Add Employees'),
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest, 
        elevation: 1.0,
        title: Text(
          'Batch Add Employees', 
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface
          )
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            color: Theme.of(context).colorScheme.onSurface
          ),
          onPressed: () => context.pop(),
          tooltip: 'Back to Employee List',
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          if (widget.viewModel.isLoading) {
            final employeeCount = _employeeList.length;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text('${widget.viewModel.addProgress}/$employeeCount Employees Added. Please wait.')
                ],
              ),
            );
          }

          return viewContent;
        }
      ), // Now the content correctly uses the available body space
    );
  }
}