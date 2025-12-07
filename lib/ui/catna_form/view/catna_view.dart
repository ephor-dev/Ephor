import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/catna_form/view/widgets/catna_section_view.dart';
import 'package:ephor/ui/catna_form/view/widgets/catna_start_view.dart';
import 'package:ephor/ui/catna_form/view_model/catna_viewmodel.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CatnaView extends StatefulWidget {
  final CatnaViewModel viewModel;

  const CatnaView({super.key, required this.viewModel});

  @override
  State<CatnaView> createState() => _CatnaViewState();
}

class _CatnaViewState extends State<CatnaView> {
  bool _isGoingBack = false;
  late ValueKey<int> _currentKey;

  @override
  void initState() {
    super.initState();
    widget.viewModel.submitCatna.addListener(_onCatnaSubmitted);
    widget.viewModel.addListener(_update);
    _currentKey = ValueKey(widget.viewModel.currentIndex);
  }

  @override
  void didUpdateWidget(covariant CatnaView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.submitCatna != widget.viewModel.submitCatna) {
      oldWidget.viewModel.submitCatna.removeListener(_onCatnaSubmitted);
      widget.viewModel.submitCatna.addListener(_onCatnaSubmitted);
    }
  }

  @override
  void dispose() {
    widget.viewModel.submitCatna.removeListener(_onCatnaSubmitted);
    widget.viewModel.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  void _onCatnaSubmitted() {
    if (widget.viewModel.submitCatna.completed) {
      widget.viewModel.submitCatna.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully submitted CATNA."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
      context.go(Routes.getOverviewPath());
      return;
    }

    if (widget.viewModel.submitCatna.error) {
      Error error = widget.viewModel.submitCatna.result as Error;
      CustomMessageException messageException =
          error.error as CustomMessageException;
      widget.viewModel.submitCatna.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Submission Error: ${messageException.message}"),
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _next() async {
    final int currentIndex = widget.viewModel.currentIndex;
    // Total steps = StartView + Number of Dynamic Sections
    final int totalSteps = widget.viewModel.sections.length + 1; 

    // 1. Validate current step (Skip validation if we are on the StartView at index 0)
    if (currentIndex > 0) {
      final result = await widget.viewModel.validateCurrentStep();
      
      if (result case Error(error: CustomMessageException ex)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ex.message),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      // Save draft data before moving on
      widget.viewModel.saveStepData.execute();
    }

    // 2. Navigate or Submit
    if (currentIndex < totalSteps - 1) {
      setState(() {
        _isGoingBack = false;
        widget.viewModel.currentIndex++;
        _currentKey = ValueKey(widget.viewModel.currentIndex);
      });
    } else {
      // We are on the last step
      widget.viewModel.submitCatna.execute();
    }
  }

  void _back() {
    final int currentIndex = widget.viewModel.currentIndex;

    if (currentIndex > 0) {
      setState(() {
        _isGoingBack = true;
        widget.viewModel.currentIndex--;
        _currentKey = ValueKey(widget.viewModel.currentIndex);
      });
    } else {
      // Exit the form
      context.go(Routes.dashboard);
    }
  }

  void _submit() {
    _next();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Show Loading Indicator if JSON is being fetched
    if (widget.viewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Generate the list of widgets dynamically
    final List<Widget> steps = [
      CatnaStartView(viewModel: widget.viewModel), // Index 0
      ...widget.viewModel.sections.map((section) => CatnaSectionView(
            section: section,
            viewModel: widget.viewModel,
          )),
    ];

    final int currentIndex = widget.viewModel.currentIndex;
    final int totalSteps = steps.length;
    final bool isLastPage = currentIndex == totalSteps - 1;
    final bool isFirstPage = currentIndex == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentIndex == 0
              ? 'CATNA Preparation'
              : 'Form Section $currentIndex', // Adjust title as needed
        ),
        leading: Center(
          child: SizedBox(
            width: 105,
            child: FilledButton.icon(
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(isFirstPage ? 'Cancel' : 'Back'),
              style: isFirstPage
                  ? FilledButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                    )
                  : FilledButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondaryContainer,
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      padding: EdgeInsets.zero,
                    ),
              onPressed: _back,
            ),
          ),
        ),
        leadingWidth: 140,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              width: 105,
              child: FilledButton.icon(
                icon: Icon(isLastPage ? Icons.check : Icons.arrow_forward,
                    size: 18),
                label: Text(isLastPage ? 'Submit' : 'Next'),
                style: FilledButton.styleFrom(
                  backgroundColor: isLastPage ? Colors.green.shade700 : null,
                  padding: EdgeInsets.zero,
                ),
                onPressed:
                    isLastPage ? _submit : _next, // Calls _submit or _next
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Identify if this specific 'child' is the one entering based on Key
          final isEntering = child.key == _currentKey;

          final Offset enterStart =
              _isGoingBack ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0);
          final Offset exitEnd =
              _isGoingBack ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);

          return SlideTransition(
            position: Tween<Offset>(
              begin: isEntering ? enterStart : exitEnd,
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: Container(
          // Key is crucial for AnimatedSwitcher to detect changes
          key: _currentKey,
          width: double.infinity,
          height: double.infinity,
          // Safety check: Ensure index is within bounds
          child: steps.length > currentIndex
              ? steps[currentIndex]
              : const Center(child: Text("Error: Step index out of bounds")),
        ),
      ),
    );
  }
}