// ui/my_forms/view/my_forms_view.dart

import 'package:flutter/material.dart';
import 'package:ephor/ui/my_forms/view_model/my_forms_view_model.dart';
import 'package:ephor/domain/models/form/form_model.dart';
import 'package:ephor/utils/responsiveness.dart';
import 'package:ephor/utils/results.dart';
import 'package:go_router/go_router.dart';
import 'package:ephor/routing/routes.dart';

class MyFormsView extends StatefulWidget {
  final MyFormsViewModel viewModel;
  
  const MyFormsView({super.key, required this.viewModel});

  @override
  State<MyFormsView> createState() => _MyFormsViewState();
}

class _MyFormsViewState extends State<MyFormsView> {
  // Material 3 Color Scheme - Red Theme (matching app theme)
  static const Color primaryColor = Color(0xFFAC312B);
  static const Color primaryContainerColor = Color(0xFFFFDAD6);
  static const Color onPrimaryContainerColor = Color(0xFF8B1A11);
  static const Color surfaceColor = Color(0xFFFFFBFE);
  static const Color surfaceVariantColor = Color(0xFFF5F5F5);
  static const Color onSurfaceColor = Color(0xFF1C1B1F);
  static const Color onSurfaceVariantColor = Color(0xFF49454F);
  static const Color outlineColor = Color(0xFF79747E);
  static const Color errorColor = Color(0xFFB3261E);
  
  @override
  void initState() {
    super.initState();
    // Load forms when screen opens
    widget.viewModel.loadForms();
  }
  
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: surfaceVariantColor,
          appBar: _buildAppBar(context),
          body: _buildBody(context, isMobile),
          floatingActionButton: _buildCreateFormButton(context),
        );
      },
    );
  }
  
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: onSurfaceColor),
        onPressed: () => context.pop(),
        tooltip: 'Back',
      ),
      title: Text(
        'My Forms',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: onSurfaceColor),
          onPressed: widget.viewModel.refresh,
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
  
  Widget _buildBody(BuildContext context, bool isMobile) {
    if (widget.viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }
    
    // Wrap all states in RefreshIndicator
    return RefreshIndicator(
      onRefresh: widget.viewModel.refresh,
      color: primaryColor,
      child: widget.viewModel.hasError
          ? _buildErrorState(context)
          : !widget.viewModel.hasForms
              ? _buildEmptyState(context)
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? double.infinity : 1000,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Stats Card
                          _buildStatsCard(context, isMobile),
                          const SizedBox(height: 24),
                          
                          // Forms List
                          ...widget.viewModel.forms.map((form) => _buildFormCard(context, form, isMobile)),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
  
  Widget _buildStatsCard(BuildContext context, bool isMobile) {
    final totalForms = widget.viewModel.forms.length;
    final publishedCount = widget.viewModel.publishedForms.length;
    final draftCount = widget.viewModel.draftForms.length;
    
    return Card(
      elevation: 1,
      color: primaryContainerColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(Icons.description, totalForms.toString(), 'Total Forms'),
            Container(width: 1, height: 40, color: onPrimaryContainerColor.withValues(alpha: onPrimaryContainerColor.a * 0.2)),
            _buildStatItem(Icons.cloud_done, publishedCount.toString(), 'Published'),
            Container(width: 1, height: 40, color: onPrimaryContainerColor.withValues(alpha: onPrimaryContainerColor.a * 0.2)),
            _buildStatItem(Icons.edit_document, draftCount.toString(), 'Drafts'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: onPrimaryContainerColor, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: onPrimaryContainerColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: onPrimaryContainerColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFormCard(BuildContext context, FormModel form, bool isMobile) {
    String formatDate(DateTime date) {
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inDays == 0) {
        return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        return '${date.month}/${date.day}/${date.year}';
      }
    }
    
    return Card(
      elevation: 2,
      color: surfaceColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: outlineColor.withValues(alpha: outlineColor.a * 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title and Status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        form.title.isEmpty ? 'Untitled Form' : form.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        form.description.isEmpty ? 'No description' : form.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: onSurfaceVariantColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildStatusBadge(form),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Info Row
              Row(
              children: [
                Icon(Icons.update, size: 16, color: onSurfaceVariantColor),
                const SizedBox(width: 8),
                Text(
                  'Updated: ${formatDate(form.updatedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: onSurfaceVariantColor,
                  ),
                ),
                const Spacer(),
                if (form.isPublished) ...[
                  Icon(Icons.people, size: 16, color: onSurfaceVariantColor),
                  const SizedBox(width: 4),
                  Text(
                    '${form.responseCount} responses',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: onSurfaceVariantColor,
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Edit Button
                OutlinedButton.icon(
                  onPressed: () => _handleEditForm(context, form),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor.withValues(alpha: primaryColor.a * 0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                
                // View Responses Button (only for published forms)
                if (form.isPublished)
                  FilledButton.icon(
                    onPressed: () => _handleViewResponses(context, form),
                    icon: const Icon(Icons.bar_chart, size: 16),
                    label: const Text('View Responses'),
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                
                // Delete Button
                OutlinedButton.icon(
                  onPressed: () => _handleDeleteForm(context, form),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: errorColor,
                    side: BorderSide(color: errorColor.withValues(alpha: errorColor.a * 0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(FormModel form) {
    final isPublished = form.isPublished;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isPublished ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPublished ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublished ? Icons.cloud_done : Icons.edit_document,
            size: 16,
            color: isPublished ? Colors.green.shade700 : Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            isPublished ? 'Published' : 'Draft',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPublished ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 80,
                  color: onSurfaceVariantColor.withValues(alpha: onSurfaceVariantColor.a * 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Forms Yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first form to get started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: onSurfaceVariantColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => _handleCreateForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Form'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: errorColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Something Went Wrong',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.viewModel.error ?? 'Unknown error',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: onSurfaceVariantColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: widget.viewModel.refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCreateFormButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _handleCreateForm(context),
      icon: const Icon(Icons.add),
      label: const Text('Create Form'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    );
  }
  
  // ============================================
  // ACTION HANDLERS
  // ============================================
  
  void _handleCreateForm(BuildContext context) {
    context.go(Routes.getCatnaFormCreatorPath());
  }
  
  void _handleEditForm(BuildContext context, FormModel form) {
    // Navigate to form editor with form ID to load existing form
    context.go(Routes.getCatnaFormCreatorPath(formId: form.id));
  }
  
  void _handleViewResponses(BuildContext context, FormModel form) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View responses for "${form.title}" - Coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _handleDeleteForm(BuildContext context, FormModel form) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: errorColor),
            const SizedBox(width: 12),
            const Text('Delete Form?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${form.title}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (form.responseCount > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This form has ${form.responseCount} responses. All data will be lost.',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed != true || !context.mounted) return;
    
    // Delete form
    final result = await widget.viewModel.deleteForm(form.id);
    
    if (!context.mounted) return;
    
    switch (result) {
      case Ok<void>():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
      case Error<void>(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: ${error.toString()}'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}

