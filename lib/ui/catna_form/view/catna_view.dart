import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/catna_form/view/widgets/catna_form1_view.dart';
import 'package:ephor/ui/catna_form/view/widgets/catna_form2_view.dart';
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

  List<Widget> get _steps => [
    CatnaStartView(viewModel: widget.viewModel),
    CatnaForm1View(viewModel: widget.viewModel),
    CatnaForm2View(viewModel: widget.viewModel),
  ];

  @override
  void initState() {
    widget.viewModel.submitCatna.addListener(_onCatnaSubmitted);
    _currentKey = ValueKey(widget.viewModel.currentIndex);
    super.initState();
  }

  @override void didUpdateWidget(covariant CatnaView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.submitCatna != widget.viewModel.submitCatna) {
      oldWidget.viewModel.submitCatna.removeListener(_onCatnaSubmitted);
      widget.viewModel.submitCatna.addListener(_onCatnaSubmitted);
    }
  }

  @override
  void dispose() {
    widget.viewModel.submitCatna.removeListener(_onCatnaSubmitted);
    super.dispose();
  }

  void _onCatnaSubmitted() {
    if (widget.viewModel.submitCatna.completed) {
      widget.viewModel.submitCatna.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully submitted CATNA."),
          duration: const Duration(seconds: 3),
        ),
      );
      context.go(Routes.getOverviewPath());
      return;
    }

    if (widget.viewModel.submitCatna.error) {
      Error error = widget.viewModel.submitCatna.result as Error;
      CustomMessageException messageException = error.error as CustomMessageException;
      widget.viewModel.submitCatna.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Submission Error: ${messageException.message}"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _next() async {
    if (!mounted) return;

    final int currentIndex = widget.viewModel.currentIndex;
    
    if (currentIndex == 1 || currentIndex == 2) {
      final result = await widget.viewModel.validateCurrentStep();
      if (result case Error(error: CustomMessageException exception)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Validation Error: ${exception.message}"),
            duration: const Duration(seconds: 3),
          ),
        );

        return;
      }
    }

    if (currentIndex == 1) {
      widget.viewModel.saveIdentifyingData.execute();
    } else if (currentIndex == 2) {
      widget.viewModel.saveCompetencyRatings.execute();
      await widget.viewModel.submitCatna.execute();
    }

    if (currentIndex < _steps.length - 1) {
      setState(() {
        _isGoingBack = false;
        widget.viewModel.currentIndex++;
        _currentKey = ValueKey(widget.viewModel.currentIndex);
      });
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
      context.go(Routes.dashboard);
    }
  }

  void _submit() {
    _next();
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = widget.viewModel.currentIndex;
    final int totalSteps = _steps.length;
    final bool isFirstPage = currentIndex == 0;
    final bool isLastPage = currentIndex == totalSteps - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentIndex == 0 
            ? 'CATNA Preparation' 
            : 'Form $currentIndex'
        ),
        leading: Center(
          child: SizedBox(
            width: 105,
            child: FilledButton.icon(
              icon: Icon(Icons.arrow_back, size: 18), 
              label: Text(isFirstPage ? 'Cancel' : 'Back'),
              style: isFirstPage 
                ? FilledButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    backgroundColor: Colors.transparent, 
                    padding: EdgeInsets.zero, 
                  )
                : FilledButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
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
                onPressed: isLastPage ? _submit : _next, // Calls _submit or _next
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
          // 2. Determine if this specific 'child' is the one entering or exiting.
          // The 'entering' child always matches the key you currently hold in your state.
          final isEntering = child.key == _currentKey; 

          // 3. Define the offsets based on direction
          // If Back: New comes from LEFT (-1), Old goes to RIGHT (1)
          // If Next: New comes from RIGHT (1), Old goes to LEFT (-1)
          final Offset enterStart = _isGoingBack ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0);
          final Offset exitEnd    = _isGoingBack ? const Offset(1.0, 0.0)  : const Offset(-1.0, 0.0);

          // 4. Apply the SlideTransition
          // AnimatedSwitcher runs the animation 0.0 -> 1.0 for Entering.
          // It runs 1.0 -> 0.0 for Exiting.
          return SlideTransition(
            position: Tween<Offset>(
              // If entering: slide FROM start TO zero.
              // If exiting:  slide FROM end   TO zero (since it runs in reverse, it looks like Zero -> End)
              begin: isEntering ? enterStart : exitEnd,
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: Container(
          key: _currentKey,
          child: _steps[currentIndex],
        ),
      ),
    );
  }
}