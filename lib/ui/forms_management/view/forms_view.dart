// ui/my_forms/view/my_forms_view.dart

import 'package:flutter/material.dart';
import 'package:ephor/ui/forms_management/view_model/forms_view_model.dart';
import 'package:ephor/domain/models/form_creator/form_model.dart';
import 'package:ephor/utils/responsiveness.dart';
import 'package:go_router/go_router.dart';
import 'package:ephor/routing/routes.dart';

class FormsView extends StatefulWidget {
  final FormsViewModel viewModel;
  
  const FormsView({super.key, required this.viewModel});

  @override
  State<FormsView> createState() => _FormsViewState();
}

class _FormsViewState extends State<FormsView> {
  Color get primaryColor => Theme.of(context).colorScheme.primary;
  Color get primaryContainerColor => Theme.of(context).colorScheme.surfaceContainer;
  Color get onPrimaryContainerColor => Theme.of(context).colorScheme.primaryFixedDim;
  Color get surfaceColor => Theme.of(context).colorScheme.surfaceContainerLowest;
  Color get surfaceVariantColor => Theme.of(context).colorScheme.surfaceContainerLow;
  Color get onSurfaceColor => Theme.of(context).colorScheme.onSurface;
  Color get onSurfaceVariantColor => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get outlineColor => Theme.of(context).colorScheme.outline;
  Color get errorColor => Theme.of(context).colorScheme.error;
  
  @override
  void initState() {
    super.initState();
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
        icon: Icon(Icons.arrow_back, color: onSurfaceColor),
        onPressed: () => context.go(Routes.getOverviewPath()),
        tooltip: 'Back to Dashboard',
      ),
      title: Text(
        'Forms Management',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
      ),
    );
  }
  
  Widget _buildBody(BuildContext context, bool isMobile) {
    if (widget.viewModel.isLoading) {
      return Center(
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
                          // Forms List
                          ...widget.viewModel.forms.map((form) => _buildFormCard(context, form, isMobile)),
                        ],
                      ),
                    ),
                  ),
                ),
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
            Row(
              children: [
                Icon(
                  Icons.assessment_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                const SizedBox(width: 8),
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
              ],
            ),
          ],
        ),
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
  
  // ============================================
  // ACTION HANDLERS
  // ============================================
  
  void _handleEditForm(BuildContext context, FormModel form) {
    // Navigate to form editor with form ID to load existing form
    context.go(Routes.getCatnaFormEditorPath(formId: form.id));
  }
}

