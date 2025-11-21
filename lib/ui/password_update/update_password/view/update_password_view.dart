import 'package:ephor/ui/password_update/update_password/view_model/update_password_viewmodel.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ephor/routing/routes.dart';
import 'package:ephor/utils/responsiveness.dart';

class UpdatePasswordView extends StatefulWidget {
  final UpdatePasswordViewModel viewModel;

  const UpdatePasswordView({super.key, required this.viewModel});

  @override
  State<UpdatePasswordView> createState() => _UpdatePasswordViewState();
}

class _UpdatePasswordViewState extends State<UpdatePasswordView> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    widget.viewModel.updateCommand.addListener(_onResult);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    widget.viewModel.updateCommand.removeListener(_onResult);
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      widget.viewModel.updateCommand.execute(_passwordController.text);
    }
  }

  void _onResult() {
    if (widget.viewModel.updateCommand.completed) {
      widget.viewModel.updateCommand.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated! Please login."), backgroundColor: Colors.green),
      );
      context.go(Routes.login); // Redirect to login after successful update
    }

    if (widget.viewModel.updateCommand.error) {
      Error error = widget.viewModel.updateCommand.result as Error;
      CustomMessageException ex = error.error as CustomMessageException;
      widget.viewModel.updateCommand.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(ex.message), backgroundColor: Colors.red),
      );
    }
  }

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
                 color: Theme.of(context).colorScheme.surface,
                 borderRadius: BorderRadius.circular(24),
                 boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
               ),
               child: Form(
                 key: _formKey,
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text("Reset Password", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 24),
                     
                     TextFormField(
                       controller: _passwordController,
                       obscureText: _obscurePass,
                       validator: (v) => (v?.length ?? 0) < 6 ? "Min 6 chars" : null,
                       decoration: InputDecoration(
                         labelText: "New Password", 
                         border: OutlineInputBorder(), 
                         prefixIcon: Icon(Icons.lock),
                         suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePass = !_obscurePass;
                            });
                          }, 
                          icon: Icon(
                            _obscurePass ? Icons.visibility_off : Icons.visibility
                          )
                         ),
                       ),
                     ),
                     const SizedBox(height: 16),
                     TextFormField(
                       controller: _confirmController,
                       obscureText: _obscureConfirm,
                       validator: (v) => v != _passwordController.text ? "Passwords do not match" : null,
                       decoration: InputDecoration(
                         labelText: "Confirm Password", 
                         border: OutlineInputBorder(), 
                         prefixIcon: Icon(Icons.lock_outline),
                         suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirm = !_obscureConfirm;
                            });
                          }, 
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off : Icons.visibility
                          )
                         ),
                       ),
                     ),
                     const SizedBox(height: 24),     
                     ListenableBuilder(
                       listenable: widget.viewModel.updateCommand,
                       builder: (context, _) {
                         return Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             FilledButton(
                               onPressed: widget.viewModel.isLoading ? null : () {context.go(Routes.dashboard);},
                               style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                                foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer
                               ),
                               child: widget.viewModel.isLoading 
                                 ? CircularProgressIndicator(
                                  backgroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
                                 ) 
                                 : const Text("Cancel"),
                             ),

                             FilledButton(
                               onPressed: widget.viewModel.isLoading ? null : _handleUpdate,
                               child: widget.viewModel.isLoading 
                                 ? CircularProgressIndicator(
                                    backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer
                                 ) 
                                 : const Text("Set New Password"),
                             ),
                           ],
                         );
                       }
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
}