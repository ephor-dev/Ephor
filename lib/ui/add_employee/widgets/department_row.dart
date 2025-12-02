import 'package:ephor/ui/add_employee/view_model/add_employee_viewmodel.dart';
import 'package:flutter/material.dart';

class DepartmentRow extends StatefulWidget {
  const DepartmentRow({super.key, required this.viewModel});
  final AddEmployeeViewModel viewModel;

  @override
  State<DepartmentRow> createState() => _DepartmentRowState();
}

class _DepartmentRowState extends State<DepartmentRow> {
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
      final double screenHeight = MediaQuery.of(context).size.height;
      const double dropdownMaxHeight = 300; // From your constraints
      const double safeMargin = 16; // Margin to keep it away from screen edges

      // 1. Calculate space available below and above the input field
      final double spaceBelow = screenHeight - (position.dy + size.height) - safeMargin;
      final double spaceAbove = position.dy - safeMargin;

      // 2. Determine final dropdown height
      // Use the maximum possible height, limited by the available space
      double dropdownHeight;
      bool showAbove;

      if (spaceBelow >= dropdownMaxHeight || spaceBelow >= spaceAbove) {
        // Enough space below, or more space below than above
        showAbove = false;
        dropdownHeight = dropdownMaxHeight;
      } else {
        // Not enough space below, so show above
        showAbove = true;
        dropdownHeight = spaceAbove > dropdownMaxHeight ? dropdownMaxHeight : spaceAbove;
      }

      // 3. Calculate the final vertical position (top)
      double top;
      if (showAbove) {
        // Position above the input
        top = position.dy - dropdownHeight;
      } else {
        // Position below the input (original behavior)
        top = position.dy + size.height;
      }

      _overlayEntry = OverlayEntry(
        builder: (BuildContext context) => GestureDetector(
          onTap: () => _closeDropdown(),
          behavior: HitTestBehavior.translucent,
          child: Stack(
              children: <Widget>[
                Positioned.fill(child: Container(color: Colors.transparent)),
                Positioned(
                  left: position.dx,
                  // **UPDATED: Use the calculated 'top' position**
                  top: top, 
                  width: size.width,
                  child: GestureDetector(
                    onTap: () {},
                    child: Material(
                      elevation: 8,
                      child: Container(
                        // **UPDATED: Use the calculated 'dropdownHeight'**
                        constraints: BoxConstraints(maxHeight: dropdownHeight), 
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE0E0E0))),
                        child: ListView.separated(
                          shrinkWrap: true, padding: EdgeInsets.zero,
                          itemCount: widget.viewModel.departments.length,
                          separatorBuilder: (BuildContext context, int index) => Container(
                            height: 1, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 0),
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            // ... (Item Builder logic remains the same)
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