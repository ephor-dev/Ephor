import 'package:ephor/ui/password_update/forgot_password/view_model/forgot_password_viewmodel.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ephor/routing/routes.dart';
import 'package:ephor/utils/responsiveness.dart';

class ForgotPasswordView extends StatefulWidget {
  final ForgotPasswordViewModel viewModel;

  const ForgotPasswordView({super.key, required this.viewModel});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _employeeCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.viewModel.sendLinkCommand.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant ForgotPasswordView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.sendLinkCommand != widget.viewModel.sendLinkCommand) {
      oldWidget.viewModel.sendLinkCommand.removeListener(_onResult);
      widget.viewModel.sendLinkCommand.addListener(_onResult);
    }
  }

  @override
  void dispose() {
    _employeeCodeController.dispose();
    widget.viewModel.sendLinkCommand.removeListener(_onResult);
    super.dispose();
  }

  Future<void> _handleSendLink(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      widget.viewModel.sendLinkCommand.execute(_employeeCodeController.text.trim());
    }
  }

  /// Builds the left panel for the desktop layout (Logo and Title).
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentGeometry.bottomLeft,
            end: AlignmentGeometry.topRight,
            colors: [
              Color(0xffac575d),
              Color(0xffC68380),
              Color(0xffE0B0A4),
              Color(0xffC68380),
              Color(0xffac575d),
            ],
            stops: [
              0.00,
              0.08,
              0.50,
              0.75,
              1.00
            ]
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
               width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 500,
               padding: const EdgeInsets.all(32),
               decoration: BoxDecoration(
                 color: Theme.of(context).colorScheme.surface.withAlpha(127),
                 borderRadius: BorderRadius.circular(24),
                 boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
               ),
               child: Form(
                 key: _formKey,
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text("Forgot Password", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 8),
                     const Text("Enter your Employee Code to receive a reset link."),
                     const SizedBox(height: 24),
                     
                     TextFormField(
                       controller: _employeeCodeController,
                       validator: (v) => v == null || v.isEmpty ? "Required" : null,
                       decoration: const InputDecoration(
                         labelText: "Employee Code",
                         border: OutlineInputBorder(),
                         prefixIcon: Icon(Icons.badge),
                       ),
                     ),
                     const SizedBox(height: 24),
                     
                     Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         TextButton(
                           onPressed: () => context.go(Routes.login), 
                           child: const Text("Cancel")
                         ),
                         const SizedBox(width: 8),
                         ListenableBuilder(
                           listenable: widget.viewModel.sendLinkCommand,
                           builder: (context, _) {
                             return FilledButton(
                               onPressed: () => widget.viewModel.isLoading ? null : _handleSendLink(context),
                               child: widget.viewModel.isLoading 
                                 ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                 : const Text("Send Link"),
                             );
                           }
                         ),
                       ],
                     )
                   ],
                 ),
               ),
            ),
          ),
        ),
      ),
    );
  }

  void _onResult() {
    if (widget.viewModel.sendLinkCommand.completed) {
      widget.viewModel.sendLinkCommand.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reset link sent! Check your email."),
          backgroundColor: Colors.green,
        ),
      );
      context.go(Routes.login); // Go back to login to wait for email
    }

    if (widget.viewModel.sendLinkCommand.error) {
      Error error = widget.viewModel.sendLinkCommand.result as Error;
      CustomMessageException ex = error.error as CustomMessageException;
      widget.viewModel.sendLinkCommand.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ex.message), backgroundColor: Colors.red),
      );
    }
  }
}