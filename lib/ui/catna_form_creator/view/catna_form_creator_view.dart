import 'package:flutter/material.dart';
import 'package:ephor/ui/catna_form_creator/view_model/catna_form_creator_view_model.dart';
import 'package:ephor/utils/responsiveness.dart';
import 'package:go_router/go_router.dart';

class CatnaFormCreatorView extends StatefulWidget {
  final CatnaFormCreatorViewModel viewModel;
  
  const CatnaFormCreatorView({super.key, required this.viewModel});

  @override
  State<CatnaFormCreatorView> createState() => _CatnaFormCreatorViewState();
}

class _CatnaFormCreatorViewState extends State<CatnaFormCreatorView> {
  // Material 3 Color Scheme - Red Theme
  static const Color primaryColor = Color(0xFFAC312B); // Primary Red (matches app theme)
  static const Color primaryContainerColor = Color(0xFFFFDAD6); // Light Red Container
  static const Color onPrimaryContainerColor = Color(0xFF8B1A11); // Dark Red
  static const Color surfaceColor = Color(0xFFFFFBFE);
  static const Color surfaceVariantColor = Color(0xFFF5F5F5);
  static const Color onSurfaceColor = Color(0xFF1C1B1F);
  static const Color onSurfaceVariantColor = Color(0xFF49454F);
  static const Color outlineColor = Color(0xFF79747E);
  static const Color errorColor = Color(0xFFB3261E);

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    
    return Scaffold(
      backgroundColor: surfaceVariantColor,
      appBar: _buildAppBar(context),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0), // 16 = 8*2, 24 = 8*3
      child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 900,
                ),
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Form Title Card
                    _buildFormTitleCard(context, isMobile),
                    const SizedBox(height: 24),
                    
                    // Sections
                    ...List.generate(
                      widget.viewModel.sections.length,
                      (index) => _buildSectionCard(context, index, isMobile),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Add Section Button
                    _buildAddSectionButton(context),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
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
        tooltip: 'Back to Dashboard',
      ),
      title: Text(
        'CATNA Form Creator',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
      ),
      actions: [
        // View Responses Button
        TextButton.icon(
          onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('View Responses - Coming soon!')),
            );
          },
          icon: const Icon(Icons.bar_chart_rounded, size: 24),
          label: const Text('View Responses'),
          style: TextButton.styleFrom(
            foregroundColor: onSurfaceColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        const SizedBox(width: 8),
        
        // Publish Button
        FilledButton.icon(
          onPressed: () {
            widget.viewModel.togglePublish();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.viewModel.isPublished 
                    ? 'Form published successfully!' 
                    : 'Form unpublished'
                ),
                backgroundColor: widget.viewModel.isPublished ? Colors.green : Colors.orange,
              ),
            );
          },
          icon: Icon(
            widget.viewModel.isPublished ? Icons.cloud_done : Icons.publish,
            size: 24,
          ),
          label: Text(widget.viewModel.isPublished ? 'Published' : 'Publish'),
          style: FilledButton.styleFrom(
            backgroundColor: widget.viewModel.isPublished ? Colors.green : primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            elevation: 2,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
  
  Widget _buildFormTitleCard(BuildContext context, bool isMobile) {
    return Card(
      elevation: 1,
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: outlineColor.withValues(alpha: outlineColor.a * 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Title Input
            TextFormField(
              controller: widget.viewModel.titleController,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: onSurfaceColor,
              ),
              decoration: InputDecoration(
                hintText: 'Untitled Form',
                hintStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: onSurfaceVariantColor.withValues(alpha: onSurfaceVariantColor.a * 0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: outlineColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: outlineColor.withValues(alpha: outlineColor.a * 0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
                filled: true,
                fillColor: surfaceColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            // Form Description Input
            TextFormField(
              controller: widget.viewModel.descriptionController,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: onSurfaceVariantColor,
              ),
              decoration: InputDecoration(
                hintText: 'Form description (optional)',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: onSurfaceVariantColor.withValues(alpha: onSurfaceVariantColor.a * 0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: outlineColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: outlineColor.withValues(alpha: outlineColor.a * 0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
                filled: true,
                fillColor: surfaceColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionCard(BuildContext context, int sectionIndex, bool isMobile) {
    final section = widget.viewModel.sections[sectionIndex];
    final questions = section['questions'] as List<Map<String, dynamic>>;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Card(
        elevation: 2,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outlineColor.withValues(alpha: outlineColor.a * 0.2)),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 24 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                children: [
                                    Expanded(
                    child: TextFormField(
                      initialValue: section['title'],
                      onChanged: (value) => widget.viewModel.updateSectionTitle(sectionIndex, value),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: onSurfaceColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Section Title',
                        hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: onSurfaceVariantColor.withValues(alpha: onSurfaceVariantColor.a * 0.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: outlineColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: outlineColor.withValues(alpha: outlineColor.a * 0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: surfaceColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  if (widget.viewModel.sections.length > 1) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => widget.viewModel.removeSection(sectionIndex),
                      tooltip: 'Remove Section',
                      color: errorColor,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              
              // Section Description
              TextFormField(
                initialValue: section['description'],
                onChanged: (value) => widget.viewModel.updateSectionDescription(sectionIndex, value),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onSurfaceVariantColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Section description (optional)',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: onSurfaceVariantColor.withValues(alpha: onSurfaceVariantColor.a * 0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: outlineColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: outlineColor.withValues(alpha: outlineColor.a * 0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              
              if (questions.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
              ],
              
              // Questions
              ...List.generate(
                questions.length,
                (questionIndex) => _buildQuestionCard(
                  context, 
                  sectionIndex, 
                  questionIndex, 
                  isMobile
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Add Question Button
              TextButton.icon(
                onPressed: () => _showAddQuestionDialog(context, sectionIndex),
                icon: const Icon(Icons.add_circle_outline, size: 24),
                label: const Text('Add Question'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: primaryColor.withValues(alpha: primaryColor.a * 0.3)),
                    ),
                ),
              ),
            ],
          ),
          ),
        ),
      );
  }
  
  Widget _buildQuestionCard(BuildContext context, int sectionIndex, int questionIndex, bool isMobile) {
    final section = widget.viewModel.sections[sectionIndex];
    final questions = section['questions'] as List<Map<String, dynamic>>;
    final question = questions[questionIndex];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
        color: surfaceVariantColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineColor.withValues(alpha: outlineColor.a * 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Number and Actions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryContainerColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                  child: Text(
                  'Q${questionIndex + 1}',
                  style: const TextStyle(
                    color: onPrimaryContainerColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 24),
                onPressed: () => widget.viewModel.removeQuestion(sectionIndex, questionIndex),
                tooltip: 'Remove Question',
                color: errorColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Question Text Input
          TextFormField(
            initialValue: question['question'],
            onChanged: (value) => widget.viewModel.updateQuestion(sectionIndex, questionIndex, value),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: onSurfaceColor,
            ),
            decoration: InputDecoration(
              labelText: 'Enter question',
              labelStyle: TextStyle(color: onSurfaceVariantColor),
              hintText: 'Type your question here',
              hintStyle: TextStyle(color: onSurfaceVariantColor.withValues(alpha: onSurfaceVariantColor.a * 0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: outlineColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: outlineColor.withValues(alpha: outlineColor.a * 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
              filled: true,
              fillColor: surfaceColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          
          // Question Type Dropdown
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: question['type'],
                  items: widget.viewModel.questionTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(_getIconForQuestionType(type), size: 16, color: onSurfaceVariantColor),
                          const SizedBox(width: 8),
                          Text(type),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      widget.viewModel.updateQuestionType(sectionIndex, questionIndex, value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Question Type',
                    labelStyle: TextStyle(color: onSurfaceVariantColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: outlineColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: outlineColor.withValues(alpha: outlineColor.a * 0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: surfaceColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Required Toggle
              Tooltip(
                message: 'Required',
                child: FilterChip(
                  label: const Text('Required'),
                  selected: question['required'] ?? false,
                  onSelected: (_) => widget.viewModel.toggleQuestionRequired(sectionIndex, questionIndex),
                  selectedColor: primaryContainerColor,
                  checkmarkColor: onPrimaryContainerColor,
                  labelStyle: TextStyle(
                    color: (question['required'] ?? false) ? onPrimaryContainerColor : onSurfaceVariantColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddSectionButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => widget.viewModel.addSection(),
      icon: const Icon(Icons.add, size: 24),
      label: const Text('Add Section'),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor.withValues(alpha: primaryColor.a * 0.5), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await widget.viewModel.saveForm();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Form saved successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      icon: widget.viewModel.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.save),
      label: Text(widget.viewModel.isLoading ? 'Saving...' : 'Save Form'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    );
  }
  
  void _showAddQuestionDialog(BuildContext context, int sectionIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Question'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.viewModel.questionTypes.map((type) {
              return ListTile(
                leading: Icon(_getIconForQuestionType(type), color: primaryColor),
                title: Text(type),
                onTap: () {
                  widget.viewModel.addQuestion(sectionIndex, type);
                  Navigator.of(context).pop();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
  
  IconData _getIconForQuestionType(String type) {
    switch (type) {
      case 'Text':
        return Icons.text_fields;
      case 'Multiple Choice':
        return Icons.radio_button_checked;
      case 'Checkbox':
        return Icons.check_box;
      case 'Rating Scale':
        return Icons.star_border;
      case 'Date':
        return Icons.calendar_today;
      case 'File Upload':
        return Icons.upload_file;
      default:
        return Icons.help_outline;
    }
  }
}
