import 'package:flutter/material.dart';

import 'package:ephor/domain/models/personnel/personnel.dart';
import 'package:ephor/data/services/personnel_service.dart';
import 'package:ephor/ui/remove_personnel/remove_personnel_viewmodel/remove_personnel_viewmodel.dart';

/// View for displaying and removing personnel
class RemovePersonnelView extends StatefulWidget {
  const RemovePersonnelView({super.key});

  /// Static method to show the modal
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54, // Semi-transparent gray background
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext context) => const RemovePersonnelView(),
    );
  }

  @override
  State<RemovePersonnelView> createState() => _RemovePersonnelViewState();
}

class _RemovePersonnelViewState extends State<RemovePersonnelView> {
  late final RemovePersonnelViewModel viewModel;

  @override
  void initState() {
    super.initState();
    // Use the shared service so it shows personnel added via Add Personnel view
    // In production, this would be injected via dependency injection
    viewModel = RemovePersonnelViewModel(service: sharedPersonnelService);
    viewModel.load();
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
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: _RemovePersonnelContent(viewModel: viewModel),
          ),
        );
      },
    );
  }
}

class _RemovePersonnelContent extends StatelessWidget {
  const _RemovePersonnelContent({required this.viewModel});

  final RemovePersonnelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Enhanced Header with better alignment and padding
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 20, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Left-aligned title with larger font
              Expanded(
                child: Text(
                  'Remove Personnel',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              // Close button with consistent padding
              IconButton(
                icon: const Icon(Icons.close, size: 24),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        // Content with consistent padding
        Expanded(
          child: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.personnel.isEmpty
                  ? _EmptyState()
                  : _PersonnelList(viewModel: viewModel),
        ),
        // Error message
        if (viewModel.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Row(
              children: <Widget>[
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    viewModel.errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No personnel found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add personnel using the "Add Personnel" feature',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }
}

class _PersonnelList extends StatelessWidget {
  const _PersonnelList({required this.viewModel});

  final RemovePersonnelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      itemCount: viewModel.personnel.length,
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
      itemBuilder: (BuildContext context, int index) {
        final PersonnelModel personnel = viewModel.personnel[index];
        return _PersonnelCard(
          personnel: personnel,
          isRemoving: viewModel.isRemoving(personnel.id),
          onRemove: () async {
            final bool confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Confirm Removal'),
                    content: Text('Are you sure you want to remove ${personnel.fullName}?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                ) ??
                false;
            if (confirmed && context.mounted) {
              final bool success = await viewModel.removePersonnel(personnel.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${personnel.fullName} removed successfully'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage ?? 'Failed to remove personnel'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}

class _PersonnelCard extends StatelessWidget {
  const _PersonnelCard({
    required this.personnel,
    required this.isRemoving,
    required this.onRemove,
  });

  final PersonnelModel personnel;
  final bool isRemoving;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Use custom shadow instead
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Enhanced Profile picture/icon - larger with peach background
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8CC), // Peach/orange background matching Add Personnel
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: personnel.photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          personnel.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Color(0xFF9E9E9E),
                              size: 32,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Color(0xFF9E9E9E),
                        size: 32,
                      ),
              ),
              const SizedBox(width: 20),
              // Personnel info - enhanced with better spacing and overflow handling
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Name with overflow handling
                    Text(
                      personnel.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Employee type and department with better layout
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: <Widget>[
                        _InfoChip(
                          icon: Icons.business_center,
                          label: _getEmployeeTypeLabel(personnel.employeeType),
                        ),
                        if (personnel.department != null)
                          _InfoChip(
                            icon: Icons.domain,
                            label: personnel.department!,
                          ),
                      ],
                    ),
                    // Extra tags with better styling
                    if (personnel.extraTags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: personnel.extraTags.map((String tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Enhanced Remove button with better styling
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isRemoving ? null : onRemove,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isRemoving ? Colors.grey.shade200 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isRemoving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          )
                        : const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEmployeeTypeLabel(EmployeeType type) {
    switch (type) {
      case EmployeeType.personnel:
        return 'Personnel';
      case EmployeeType.faculty:
        return 'Faculty';
      case EmployeeType.jobOrder:
        return 'Job Order';
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
