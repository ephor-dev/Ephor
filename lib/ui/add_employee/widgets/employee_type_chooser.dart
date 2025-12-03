import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/ui/add_employee/view_model/add_employee_viewmodel.dart';
import 'package:flutter/material.dart';

class EmployeeTypeChooser extends StatefulWidget {
  const EmployeeTypeChooser({super.key, required this.viewModel});
  final AddEmployeeViewModel viewModel;

  @override
  State<EmployeeTypeChooser> createState() => _EmployeeTypeChooserState();
}

class _EmployeeTypeChooserState extends State<EmployeeTypeChooser> {
  // Assuming EmployeeRole is an enum defined elsewhere
  EmployeeRole _currentSelection = EmployeeRole.personnel; 
  
  @override
  void initState() {
    super.initState();
    _currentSelection = widget.viewModel.employeeRole;
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.tertiaryFixedDim; 
    final Color inactiveBg = Theme.of(context).colorScheme.surfaceContainerLow; 
    
    return SizedBox(
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
          return states.contains(WidgetState.selected) 
            ? Theme.of(context).colorScheme.surfaceContainerLowest 
            : Theme.of(context).colorScheme.onSurface.withAlpha(222);
        }),
        side: WidgetStateProperty.resolveWith<BorderSide?>((Set<WidgetState> states) {
          return states.contains(WidgetState.selected) 
            ? BorderSide(color: accentColor, width: 1.5) 
            : BorderSide(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              width: 1.5
            );
        }),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      ),
      ),
    );
  }
}