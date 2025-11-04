import 'package:flutter/material.dart';

import 'hr_service.dart';
import 'hr_viewmodel.dart';

class HRView extends StatefulWidget {
  const HRView({super.key});

  @override
  State<HRView> createState() => _HRViewState();
}

class _HRViewState extends State<HRView> {
  late final HRViewModel _viewModel;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = HRViewModel(service: HRInMemoryService());
    _viewModel.load();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    final String first = _firstNameController.text;
    final String last = _lastNameController.text;
    final String pos = _positionController.text;
    if (first.trim().isEmpty || last.trim().isEmpty || pos.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    await _viewModel.addPersonnel(firstName: first, lastName: last, position: pos);
    _firstNameController.clear();
    _lastNameController.clear();
    _positionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HR - Personnel')),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (BuildContext context, Widget? _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'First name'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Last name'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _positionController,
                        decoration: const InputDecoration(labelText: 'Position'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _handleAdd,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          itemCount: _viewModel.personnel.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (BuildContext context, int index) {
                            final item = _viewModel.personnel[index];
                            return Dismissible(
                              key: ValueKey<String>(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) async {
                                await _viewModel.removePersonnel(item.id);
                              },
                              child: ListTile(
                                title: Text(item.fullName),
                                subtitle: Text(item.position),
                                trailing: Text(
                                  _formatDate(item.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}


