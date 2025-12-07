import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/impact_assessment_form/view/widgets/impact_assessment_section_view.dart';
import 'package:ephor/ui/impact_assessment_form/view/widgets/impact_assessment_start_view.dart'; // See below
import 'package:ephor/ui/impact_assessment_form/view_model/impact_assessment_viewmodel.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImpactAssessmentView extends StatefulWidget {
  final ImpactAssessmentViewModel viewModel;

  const ImpactAssessmentView({super.key, required this.viewModel});

  @override
  State<ImpactAssessmentView> createState() => _ImpactAssessmentViewState();
}

class _ImpactAssessmentViewState extends State<ImpactAssessmentView> {
  bool _isGoingBack = false;
  late ValueKey<int> _currentKey;

  @override
  void initState() {
    super.initState();
    widget.viewModel.submitAssessment.addListener(_onSubmit);
    _currentKey = ValueKey(widget.viewModel.currentIndex);
  }

  @override
  void dispose() {
    widget.viewModel.submitAssessment.removeListener(_onSubmit);
    super.dispose();
  }

  void _onSubmit() {
    if (widget.viewModel.submitAssessment.completed) {
      widget.viewModel.submitAssessment.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully submitted Impact Assessment."),
          backgroundColor: Colors.green,
        ),
      );
      context.go(Routes.getOverviewPath());
      return;
    }

    if (widget.viewModel.submitAssessment.error) {
      final error = widget.viewModel.submitAssessment.result as Error;
      final exception = error.error as CustomMessageException;
      widget.viewModel.submitAssessment.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${exception.message}"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _next() async {
    final int currentIndex = widget.viewModel.currentIndex;
    final int totalSteps = widget.viewModel.sections.length + 1;

    if (currentIndex > 0) {
      final result = await widget.viewModel.validateCurrentStep();
      if (result case Error(error: CustomMessageException ex)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ex.message), behavior: SnackBarBehavior.floating),
        );
        return;
      }
      widget.viewModel.saveStepData.execute();
    }

    if (currentIndex < totalSteps - 1) {
      setState(() {
        _isGoingBack = false;
        widget.viewModel.currentIndex++;
        _currentKey = ValueKey(widget.viewModel.currentIndex);
      });
    } else {
      widget.viewModel.submitAssessment.execute();
    }
  }

  void _back() {
    if (widget.viewModel.currentIndex > 0) {
      setState(() {
        _isGoingBack = true;
        widget.viewModel.currentIndex--;
        _currentKey = ValueKey(widget.viewModel.currentIndex);
      });
    } else {
      context.go(Routes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final List<Widget> steps = [
          ImpactAssessmentStartView(viewModel: widget.viewModel),
          // Use the generic renderer for all dynamic sections
          ...widget.viewModel.sections.map((section) => ImpactAssessmentSectionView(
                section: section,
                // We cast or modify ImpactSectionView to accept ImpactViewModel 
                // (or make generic ViewModel class parent)
                // For now, assume ImpactSectionView accepts ImpactViewModel
                viewModel: widget.viewModel, 
              )),
        ];

        final int currentIndex = widget.viewModel.currentIndex;
        final int totalSteps = steps.length;
        final bool isLastPage = currentIndex == totalSteps - 1;
        final bool isFirstPage = currentIndex == 0;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          appBar: AppBar(
            title: Text(
              currentIndex == 0 ? 'Impact Assessment' : 'Section $currentIndex',
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
                    icon: Icon(isLastPage ? Icons.check : Icons.arrow_forward, size: 18),
                    label: Text(isLastPage ? 'Submit' : 'Next'),
                    style: FilledButton.styleFrom(
                      backgroundColor: isLastPage ? Colors.green.shade700 : null,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: isLastPage ? widget.viewModel.submitAssessment.execute : _next,
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
              final isEntering = child.key == _currentKey;
              final Offset enterStart = _isGoingBack ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0);
              final Offset exitEnd = _isGoingBack ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);

              return SlideTransition(
                position: Tween<Offset>(
                  begin: isEntering ? enterStart : exitEnd,
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: Container(
              key: _currentKey,
              width: double.infinity,
              height: double.infinity,
              child: steps.isNotEmpty && currentIndex < steps.length
                  ? steps[currentIndex]
                  : const Center(child: Text("No form sections available.")),
            ),
          ),
        );
      },
    );
  }
}