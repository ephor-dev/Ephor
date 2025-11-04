import 'package:flutter/material.dart';

import 'add_personnel_viewmodel.dart';
import 'personnel_model.dart';

class AddPersonnelView extends StatefulWidget {
  const AddPersonnelView({super.key});

  @override
  State<AddPersonnelView> createState() => _AddPersonnelViewState();
}

class _AddPersonnelViewState extends State<AddPersonnelView> {
  late final AddPersonnelViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = AddPersonnelViewModel();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (BuildContext context, Widget? _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: viewModel.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB47B), brightness: Brightness.light),
            scaffoldBackgroundColor: const Color(0xFFF8F8F8),
            cardTheme: const CardThemeData(
              color: Colors.white,
              elevation: 8,
              surfaceTintColor: Colors.transparent,
              shadowColor: Color(0x1A000000),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0x22000000)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFF333333)),
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB47B), brightness: Brightness.dark),
            scaffoldBackgroundColor: const Color(0xFF1E1E1E),
          ),
          home: _AddPersonnelScaffold(viewModel: viewModel),
        );
      },
    );
  }
}

class _AddPersonnelScaffold extends StatelessWidget {
  const _AddPersonnelScaffold({required this.viewModel});

  final AddPersonnelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: theme.scaffoldBackgroundColor,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.red.shade600,
                  child: const Icon(Icons.approval_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                const Text('EPHOR'),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1))],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Row(
                      children: <Widget>[
                        Icon(Icons.search, size: 20, color: Colors.black54),
                        SizedBox(width: 6),
                        Expanded(child: Text('Search...', style: TextStyle(color: Colors.black54))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.info_outline),
                const SizedBox(width: 12),
                const Icon(Icons.notifications_none),
                const SizedBox(width: 12),
                const Icon(Icons.person_outline),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Toggle theme',
                  onPressed: viewModel.toggleThemeMode,
                  icon: const Icon(Icons.dark_mode_outlined),
                ),
              ],
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isNarrow = constraints.maxWidth < 700;
          final EdgeInsets cardPadding = isNarrow ? const EdgeInsets.all(24) : const EdgeInsets.fromLTRB(28, 24, 28, 24);
          final double maxCardWidth = 860;
          const double formMaxWidth = 760; // shared width for centered rows

          // Step 1: Card container with rounded corners, padding, and scrollable content
          final Widget card = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxCardWidth),
              child: Card(
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Modal header - title only, no dark mode toggle
                      Text(
                        'Add Personnel',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      // Step 3: Add spacing below header
                      const SizedBox(height: 16),
                      _FormSection(viewModel: viewModel, isNarrow: isNarrow),
                    ],
                  ),
                ),
              ),
            ),
          );

          return isNarrow
              ? SingleChildScrollView(padding: const EdgeInsets.all(16), child: card)
              : Center(child: card);
        },
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.viewModel, required this.isNarrow});
  final AddPersonnelViewModel viewModel;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    const double formMaxWidth = 760; // shared width for centered rows

    // Left column: Image section
    final Widget imageCol = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE8CC),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: const Center(child: Icon(Icons.person_outline, size: 64, color: Colors.black54)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 140,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFFB47B)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image picker not implemented')));
            },
            child: const Text('Choose Image', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );

    final InputDecoration decoration = const InputDecoration();

    // Right column: All form fields aligned and centered
    final Widget rightColumn = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: formMaxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Name fields row
            isNarrow
                ? Column(
                    children: <Widget>[
                      _NameField(
                        label: 'LAST NAME',
                        controller: viewModel.lastNameController,
                        decoration: decoration,
                        hintText: '',
                      ),
                      const SizedBox(height: 12),
                      _NameField(
                        label: 'FIRST NAME',
                        controller: viewModel.firstNameController,
                        decoration: decoration,
                        hintText: '',
                      ),
                      const SizedBox(height: 12),
                      _NameField(
                        label: 'MIDDLE NAME',
                        controller: viewModel.middleNameController,
                        decoration: decoration,
                        hintText: '',
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
                          hintText: '',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NameField(
                          label: 'FIRST NAME',
                          controller: viewModel.firstNameController,
                          decoration: decoration,
                          hintText: '',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NameField(
                          label: 'MIDDLE NAME',
                          controller: viewModel.middleNameController,
                          decoration: decoration,
                          hintText: '',
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 16),
            // Employee Type with label
            const _FieldLabel('EMPLOYEE TYPE'),
            const SizedBox(height: 6),
            _EmployeeType(viewModel: viewModel),
            const SizedBox(height: 16),
            // Department row
            _DepartmentRow(viewModel: viewModel),
            const SizedBox(height: 12),
            // Extra Tags
            const _FieldLabel('EXTRA TAGS (COMMA SEPARATED, IF APPLICABLE)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: viewModel.tagsController,
              decoration: const InputDecoration(hintText: 'i.e. non-teaching'),
            ),
            const SizedBox(height: 20),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    final PersonnelModel? result = viewModel.confirm();
                    final String message = result == null
                        ? 'Please fill out Last Name and First Name.'
                        : 'Saved: ${result.fullName}';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                  },
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFB47B)),
                  child: const Text('Confirm'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.black54),
                  child: const Text('Cancel'),
                ),
              ],
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

class _EmployeeType extends StatelessWidget {
  const _EmployeeType({required this.viewModel});
  final AddPersonnelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final List<bool> selected = <bool>[
      viewModel.employeeType == EmployeeType.personnel,
      viewModel.employeeType == EmployeeType.faculty,
      viewModel.employeeType == EmployeeType.jobOrder,
    ];
    return ToggleButtons(
      isSelected: selected,
      onPressed: (int index) {
        switch (index) {
          case 0:
            viewModel.setEmployeeType(EmployeeType.personnel);
            break;
          case 1:
            viewModel.setEmployeeType(EmployeeType.faculty);
            break;
          case 2:
            viewModel.setEmployeeType(EmployeeType.jobOrder);
            break;
        }
      },
      borderRadius: BorderRadius.circular(24),
      constraints: const BoxConstraints(minHeight: 40, minWidth: 140),
      borderColor: const Color(0x22000000),
      selectedBorderColor: const Color(0x22000000),
      fillColor: const Color(0xFFFFB47B),
      selectedColor: Colors.black87,
      color: Colors.black87,
      children: const <Widget>[
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Personnel')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Faculty')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Job Order')),
      ],
    );
  }
}

class _DepartmentRow extends StatelessWidget {
  const _DepartmentRow({required this.viewModel});
  final AddPersonnelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: DropdownButtonFormField<String>(
            value: viewModel.noDepartment ? null : viewModel.selectedDepartment,
            decoration: const InputDecoration(labelText: 'DEPARTMENT'),
            items: viewModel.departments
                .map((String e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(growable: false),
            onChanged: viewModel.noDepartment ? null : viewModel.setDepartment,
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: <Widget>[
            Checkbox(value: viewModel.noDepartment, onChanged: (bool? v) => viewModel.setNoDepartment(v ?? false)),
            const Text('Not part of any department.'),
          ],
        ),
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.label,
    required this.controller,
    required this.decoration,
    required this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final InputDecoration decoration;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: decoration.copyWith(hintText: hintText),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 0.6,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.65),
          ),
    );
  }
}


