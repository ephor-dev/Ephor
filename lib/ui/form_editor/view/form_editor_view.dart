import 'package:flutter/material.dart';
import 'package:ephor/ui/form_editor/view_model/form_editor_view_model.dart';
import 'package:ephor/domain/models/form_editor/form_model.dart';
import 'package:ephor/utils/responsiveness.dart';
import 'package:ephor/utils/results.dart';
import 'package:go_router/go_router.dart';
import 'package:ephor/routing/routes.dart';

class FormEditorView extends StatefulWidget {
  final FormEditorViewModel viewModel;
  
  const FormEditorView({super.key, required this.viewModel});

  @override
  State<FormEditorView> createState() => _FormEditorViewState();
}

class _FormEditorViewState extends State<FormEditorView> {
  // Material 3 Color Scheme - Red Theme
  Color get primaryColor => Theme.of(context).colorScheme.primary; // Primary Red (matches app theme)
  Color get primaryContainerColor => Theme.of(context).colorScheme.surfaceContainer; // Light Red Container
  Color get onPrimaryContainerColor => Theme.of(context).colorScheme.primaryFixedDim; // Dark Red
  Color get surfaceColor => Theme.of(context).colorScheme.surfaceContainerLowest;
  Color get surfaceVariantColor => Theme.of(context).colorScheme.surfaceContainerLow;
  Color get onSurfaceColor => Theme.of(context).colorScheme.onSurface;
  Color get onSurfaceVariantColor => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get outlineColor => Theme.of(context).colorScheme.outline;
  Color get errorColor => Theme.of(context).colorScheme.error;

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
          body: widget.viewModel.isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    SizedBox(height: 16),
                    Text('Loading form...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0), // 16 = 8*2, 24 = 8*3
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? double.infinity : 900,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Error message if any
                        if (widget.viewModel.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: errorColor.withValues(alpha: errorColor.a * 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: errorColor),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: errorColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.viewModel.errorMessage!,
                                    style: TextStyle(color: errorColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
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
              ),
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
          onPressed: () => context.go(Routes.getMyFormsPath()),
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
        FilledButton.icon(
          onPressed: widget.viewModel.isSaving ? null : () async {
            final confirmed = await _showSaveConfirmationDialog(context);
            if (!confirmed) return;
            
            final result = await widget.viewModel.saveForm();
            
            if (!context.mounted) return;
            
            switch (result) {
              case Ok<FormModel>():
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Form saved successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                
              case Error<FormModel>(:final error):
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Save failed: ${error.toString()}'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
            }
          },
          icon: widget.viewModel.isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.surfaceContainerLowest),
                  ),
                )
              : Icon(
                  Icons.save_outlined,
                  size: 24,
                ),
          label: Text(
            widget.viewModel.isSaving
                ? 'Processing...'
                : 'Save'
          ),
          style: FilledButton.styleFrom(
            backgroundColor: widget.viewModel.isSaving 
                ? Colors.grey 
                : primaryColor,
            foregroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
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
                  borderSide: BorderSide(color: primaryColor, width: 2),
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
                  borderSide: BorderSide(color: primaryColor, width: 2),
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
                          borderSide: BorderSide(color: primaryColor, width: 2),
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
                    borderSide: BorderSide(color: primaryColor, width: 2),
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
                  style: TextStyle(
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
                borderSide: BorderSide(color: primaryColor, width: 2),
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
                      borderSide: BorderSide(color: primaryColor, width: 2),
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
          
          // Dynamic content based on question type
          ..._buildQuestionTypeSpecificContent(context, sectionIndex, questionIndex, question),
        ],
      ),
    );
  }
  
  /// Builds type-specific content for each question type
  List<Widget> _buildQuestionTypeSpecificContent(
    BuildContext context,
    int sectionIndex,
    int questionIndex,
    Map<String, dynamic> question,
  ) {
    final questionType = question['type'] as String;
    
    switch (questionType) {
      case 'Multiple Choice':
      case 'Checkbox':
        return _buildOptionsEditor(context, sectionIndex, questionIndex, question, questionType);
      
      case 'Dropdown':
        return _buildDropdownConfig(context, sectionIndex, questionIndex, question);
      
      case 'Number':
        return _buildNumberConfig(context, sectionIndex, questionIndex, question);
      
      case 'Rating Scale':
        return _buildRatingScaleConfig(context, sectionIndex, questionIndex, question);
      
      case 'Date':
        return _buildDateConfig(context, sectionIndex, questionIndex, question);
      
      case 'File Upload':
        return _buildFileUploadConfig(context, sectionIndex, questionIndex, question);
      
      case 'Text':
        // Text type doesn't need additional configuration
        return [];
      
      default:
        return [];
    }
  }
  
  /// Builds options editor for Multiple Choice and Checkbox questions
  List<Widget> _buildOptionsEditor(
    BuildContext context,
    int sectionIndex,
    int questionIndex,
    Map<String, dynamic> question,
    String questionType,
  ) {
    final options = question['options'] as List<String>? ?? ['Option 1', 'Option 2'];
    final config = question['config'] as Map<String, dynamic>? ?? {};
    final maxSelections = config['maxSelections'] as int?;
    
    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 8),
      
      // Options header
      Row(
        children: [
          Icon(
            questionType == 'Multiple Choice' ? Icons.radio_button_checked : Icons.check_box,
            size: 18,
            color: onSurfaceVariantColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Options',
            style: TextStyle(
              color: onSurfaceVariantColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      
      // Options list
      ...List.generate(options.length, (optionIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                questionType == 'Multiple Choice' ? Icons.radio_button_unchecked : Icons.check_box_outline_blank,
                size: 20,
                color: onSurfaceVariantColor.withValues(alpha: onSurfaceVariantColor.a * 0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: options[optionIndex],
                  onChanged: (value) {
                    widget.viewModel.updateQuestionOption(
                      sectionIndex,
                      questionIndex,
                      optionIndex,
                      value,
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Option ${optionIndex + 1}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (options.length > 2) // Keep at least 2 options
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    widget.viewModel.removeQuestionOption(sectionIndex, questionIndex, optionIndex);
                  },
                  tooltip: 'Remove option',
                  color: errorColor,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        );
      }),
      
      // Add option button
      const SizedBox(height: 8),
      TextButton.icon(
        onPressed: () {
          widget.viewModel.addQuestionOption(sectionIndex, questionIndex);
        },
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add option'),
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      
      // Max selections configuration (Checkbox only)
      if (questionType == 'Checkbox') ...[
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        
        // Max selections header
        Row(
          children: [
            Icon(
              Icons.format_list_numbered,
              size: 18,
              color: onSurfaceVariantColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Selection Limit',
              style: TextStyle(
                color: onSurfaceVariantColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Max selections dropdown
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int?>(
                initialValue: maxSelections,
                decoration: InputDecoration(
                  labelText: 'Maximum Selections',
                  helperText: 'Limit how many options can be checked',
                  helperStyle: const TextStyle(fontSize: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No Limit'),
                  ),
                  ...List.generate(
                    options.length - 1,
                    (index) => DropdownMenuItem(
                      value: index + 2,
                      child: Text('${index + 2} options'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  widget.viewModel.updateCheckboxMaxSelections(
                    sectionIndex,
                    questionIndex,
                    maxSelections: value,
                  );
                },
              ),
            ),
          ],
        ),
        
        // Info message
        if (maxSelections != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryContainerColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: onPrimaryContainerColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Users can select up to $maxSelections option${maxSelections > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: onPrimaryContainerColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ];
  }
  
  /// Builds rating scale configuration
  List<Widget> _buildRatingScaleConfig(
    BuildContext context,
    int sectionIndex,
    int questionIndex,
    Map<String, dynamic> question,
  ) {
    final config = question['config'] as Map<String, dynamic>? ?? {};
    final minValue = config['min'] as int? ?? 1;
    final maxValue = config['max'] as int? ?? 5;
    
    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 8),
      
      // Rating scale header
      Row(
        children: [
          Icon(Icons.star_border, size: 18, color: onSurfaceVariantColor),
          const SizedBox(width: 8),
          Text(
            'Rating Scale Configuration',
            style: TextStyle(
              color: onSurfaceVariantColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      
      // Min and Max values
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: minValue,
              decoration: InputDecoration(
                labelText: 'Min Value',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
              items: [1, 0].map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.viewModel.updateRatingScaleConfig(
                    sectionIndex,
                    questionIndex,
                    min: value,
                    max: maxValue,
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: maxValue,
              decoration: InputDecoration(
                labelText: 'Max Value',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
              items: [3, 5, 7, 10].map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.viewModel.updateRatingScaleConfig(
                    sectionIndex,
                    questionIndex,
                    min: minValue,
                    max: value,
                  );
                }
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      
      // Preview
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: outlineColor.withValues(alpha: outlineColor.a * 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(maxValue - minValue + 1, (index) {
            final value = minValue + index;
            return Column(
              children: [
                Icon(Icons.star_border, size: 24, color: primaryColor),
                const SizedBox(height: 4),
                Text(
                  value.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }),
        ),
      ),
    ];
  }
  
  /// Builds date question configuration
  List<Widget> _buildDateConfig(
    BuildContext context,
    int sectionIndex,
    int questionIndex,
    Map<String, dynamic> question,
  ) {
    final config = question['config'] as Map<String, dynamic>? ?? {};
    final includeTime = config['includeTime'] as bool? ?? false;
    final minDateStr = config['minDate'] as String?;
    final maxDateStr = config['maxDate'] as String?;
    
    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 8),
      
      // Date configuration header
      Row(
        children: [
          Icon(Icons.calendar_today, size: 18, color: onSurfaceVariantColor),
          const SizedBox(width: 8),
          Text(
            'Date Configuration',
            style: TextStyle(
              color: onSurfaceVariantColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      
      // Include time toggle
      SwitchListTile(
        title: const Text('Include Time Picker'),
        subtitle: const Text('Allow users to select time in addition to date'),
        value: includeTime,
        onChanged: (value) {
          widget.viewModel.updateDateConfig(
            sectionIndex,
            questionIndex,
            includeTime: value,
          );
        },
        activeThumbColor: primaryColor,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
      const SizedBox(height: 12),
      
      // Date range options
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: minDateStr != null 
                      ? DateTime.parse(minDateStr) 
                      : DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                
                if (date != null) {
                  widget.viewModel.updateDateConfig(
                    sectionIndex,
                    questionIndex,
                    minDate: date,
                  );
                }
              },
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                minDateStr != null 
                    ? 'Min: ${DateTime.parse(minDateStr).toString().split(' ')[0]}'
                    : 'Set Min Date',
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (minDateStr != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                widget.viewModel.updateDateConfig(
                  sectionIndex,
                  questionIndex,
                  minDate: null,
                );
              },
              tooltip: 'Clear min date',
              color: errorColor,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: maxDateStr != null 
                      ? DateTime.parse(maxDateStr) 
                      : DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                
                if (date != null) {
                  widget.viewModel.updateDateConfig(
                    sectionIndex,
                    questionIndex,
                    maxDate: date,
                  );
                }
              },
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                maxDateStr != null 
                    ? 'Max: ${DateTime.parse(maxDateStr).toString().split(' ')[0]}'
                    : 'Set Max Date',
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (maxDateStr != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                widget.viewModel.updateDateConfig(
                  sectionIndex,
                  questionIndex,
                  maxDate: null,
                );
              },
              tooltip: 'Clear max date',
              color: errorColor,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    ];
  }

  List<Widget> _buildDropdownConfig(
    BuildContext context,
    int sectionIndex,
    int questionIndex,
    Map<String, dynamic> question,
  ) {
    final config = question['config'] as Map<String, dynamic>? ?? {};
    final currentSource = config['dataSource'] as String? ?? 'employees';
    print(currentSource);

    // Map backend IDs to readable labels for the user
    final Map<String, String> sourceLabels = {
      'employees': 'List of Personnel / Employees',
      'designations': 'Positions / Designations',
      'offices': 'Offices / Colleges',
      'operating_units': 'Operating Units / Campuses',
      'purpose_choices': 'Purpose of Assessment Options',
      'intervention_types': 'Intervention Types'
    };

    final bool valueExists = sourceLabels.containsKey(currentSource);

    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 8),

      // Header
      Row(
        children: [
          Icon(Icons.dynamic_form, size: 18, color: onSurfaceVariantColor),
          const SizedBox(width: 8),
          Text(
            'Dynamic Data Source',
            style: TextStyle(
              color: onSurfaceVariantColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),

      // Data Source Dropdown
      DropdownButtonFormField<String>(
        value: valueExists ? currentSource : null,
        decoration: InputDecoration(
          labelText: 'Select List Source',
          helperText: 'This list is populated automatically at runtime.',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: widget.viewModel.availableDataSources.map((source) {
          return DropdownMenuItem(
            value: source,
            child: Text(sourceLabels[source] ?? source),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            widget.viewModel.updateDropdownConfig(sectionIndex, questionIndex, value);
          }
        },
      ),
      
      // Info Box to explain functionality
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: outlineColor.withValues(alpha: outlineColor.a * 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 16, color: primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'When the user opens this form, they will see a searchable dropdown containing all entries from the "${sourceLabels[currentSource] ?? currentSource}" database.',
                style: TextStyle(fontSize: 12, color: onSurfaceVariantColor),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildNumberConfig(
    BuildContext context,
    int sectionIndex,
    int questionIndex,
    Map<String, dynamic> question,
  ) {
    final config = question['config'] as Map<String, dynamic>? ?? {};
    final allowDecimals = config['allowDecimals'] as bool? ?? false;

    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 8),

      Row(
        children: [
          Icon(Icons.settings_input_component, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            'Input Constraints',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),

      SwitchListTile(
        title: const Text('Allow Decimals'),
        subtitle: const Text('If disabled, only whole numbers (integers) will be accepted.'),
        value: allowDecimals,
        onChanged: (value) {
          widget.viewModel.updateNumberConfig(
            sectionIndex, 
            questionIndex, 
            allowDecimals: value
          );
        },
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    ];
  }
  
  /// Builds file upload question configuration
  List<Widget> _buildFileUploadConfig(
    BuildContext context,
    int sectionIndex,
    int questionIndex,
    Map<String, dynamic> question,
  ) {
    final config = question['config'] as Map<String, dynamic>? ?? {};
    final allowedTypes = (config['allowedTypes'] as List?)?.cast<String>() ?? ['all'];
    final maxSizeMB = config['maxSizeMB'] as int? ?? 10;
    final allowMultiple = config['allowMultiple'] as bool? ?? false;
    
    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 8),
      
      // File upload configuration header
      Row(
        children: [
          Icon(Icons.upload_file, size: 18, color: onSurfaceVariantColor),
          const SizedBox(width: 8),
          Text(
            'File Upload Configuration',
            style: TextStyle(
              color: onSurfaceVariantColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      
      // Allowed file types
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            label: const Text('All Types'),
            selected: allowedTypes.contains('all'),
            onSelected: (selected) {
              widget.viewModel.updateFileUploadConfig(
                sectionIndex,
                questionIndex,
                allowedTypes: selected ? ['all'] : [],
              );
            },
            selectedColor: primaryContainerColor,
            checkmarkColor: onPrimaryContainerColor,
          ),
          FilterChip(
            label: const Text('Images'),
            selected: allowedTypes.contains('image'),
            onSelected: (selected) {
              final newTypes = List<String>.from(allowedTypes);
              newTypes.remove('all');
              if (selected) {
                newTypes.add('image');
              } else {
                newTypes.remove('image');
              }
              widget.viewModel.updateFileUploadConfig(
                sectionIndex,
                questionIndex,
                allowedTypes: newTypes.isEmpty ? ['all'] : newTypes,
              );
            },
            selectedColor: primaryContainerColor,
            checkmarkColor: onPrimaryContainerColor,
          ),
          FilterChip(
            label: const Text('Documents'),
            selected: allowedTypes.contains('document'),
            onSelected: (selected) {
              final newTypes = List<String>.from(allowedTypes);
              newTypes.remove('all');
              if (selected) {
                newTypes.add('document');
              } else {
                newTypes.remove('document');
              }
              widget.viewModel.updateFileUploadConfig(
                sectionIndex,
                questionIndex,
                allowedTypes: newTypes.isEmpty ? ['all'] : newTypes,
              );
            },
            selectedColor: primaryContainerColor,
            checkmarkColor: onPrimaryContainerColor,
          ),
          FilterChip(
            label: const Text('PDFs'),
            selected: allowedTypes.contains('pdf'),
            onSelected: (selected) {
              final newTypes = List<String>.from(allowedTypes);
              newTypes.remove('all');
              if (selected) {
                newTypes.add('pdf');
              } else {
                newTypes.remove('pdf');
              }
              widget.viewModel.updateFileUploadConfig(
                sectionIndex,
                questionIndex,
                allowedTypes: newTypes.isEmpty ? ['all'] : newTypes,
              );
            },
            selectedColor: primaryContainerColor,
            checkmarkColor: onPrimaryContainerColor,
          ),
        ],
      ),
      const SizedBox(height: 16),
      
      // Max file size
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: maxSizeMB,
              decoration: InputDecoration(
                labelText: 'Max File Size',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
              items: [1, 5, 10, 25, 50, 100].map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text('$size MB'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.viewModel.updateFileUploadConfig(
                    sectionIndex,
                    questionIndex,
                    maxSizeMB: value,
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          
          // Allow multiple files toggle
          Expanded(
            child: SwitchListTile(
              title: const Text('Multiple Files', style: TextStyle(fontSize: 14)),
              value: allowMultiple,
              onChanged: (value) {
                widget.viewModel.updateFileUploadConfig(
                  sectionIndex,
                  questionIndex,
                  allowMultiple: value,
                );
              },
              activeThumbColor: primaryColor,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      
      // Info box
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: outlineColor.withValues(alpha: outlineColor.a * 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                allowedTypes.contains('all')
                    ? 'All file types allowed (up to $maxSizeMB MB)'
                    : 'Allowed: ${allowedTypes.join(", ")} (up to $maxSizeMB MB)',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    ];
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
  
  void _showAddQuestionDialog(BuildContext context, int sectionIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Type of Question'),
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
      case 'Dropdown':
        return Icons.arrow_drop_down_circle;
      case 'Number':
        return Icons.onetwothree;
      default:
        return Icons.help_outline;
    }
  }
  
  // ============================================
  // CONFIRMATION DIALOGS
  // ============================================
  Future<bool> _showSaveConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.save, color: primaryColor, size: 28),
            const SizedBox(width: 12),
            const Text('Save Form?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Once saved, this form will be accessible to users.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryContainerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: onSurfaceColor, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can still edit it after saving, but changes will be visible immediately.',
                      style: TextStyle(
                        color: onSurfaceColor,
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
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.save, size: 20),
            label: const Text('Save'),
            style: FilledButton.styleFrom(
              backgroundColor: primaryColor,
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}
