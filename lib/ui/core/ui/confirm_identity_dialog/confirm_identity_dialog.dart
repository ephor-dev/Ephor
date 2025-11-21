import 'package:ephor/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:flutter/material.dart';

class ConfirmIdentityDialog extends StatefulWidget{
  final DashboardViewModel viewModel;
  const ConfirmIdentityDialog({
    super.key,
    required this.viewModel
  });

  @override
  State<ConfirmIdentityDialog> createState() => _ConfirmIdentityDialogState();
}

class _ConfirmIdentityDialogState extends State<ConfirmIdentityDialog> {
  bool _isPasswordVisible = false;
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm it is You'),
      constraints: BoxConstraints.tight(Size(540, 240)),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter your password to proceed to update your user information'),
          const SizedBox(height: 16,),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.viewModel.checkPassword.execute(_passwordController.text);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}