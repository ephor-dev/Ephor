import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:ephor/ui/login/view_model/login_viewmodel.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';

class LoginView extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginView({super.key, required this.viewModel});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final double formSpacing = 16.0;
  bool _rememberMe = false;
  final TextEditingController _employeeCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Set<String> _userRoleController = {'Supervisor'};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.viewModel.login.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant LoginView oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.login.removeListener(_onResult);
    widget.viewModel.login.addListener(_onResult);
  }

  @override
  void dispose() {
    _employeeCodeController.dispose();
    _passwordController.dispose();
    widget.viewModel.login.removeListener(_onResult);
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      widget.viewModel.login.execute((
        _employeeCodeController.text.trim(),
        _passwordController.text,
        _userRoleController.first,
        _rememberMe
      ));
    }
  }

  Widget _buildRoleSegmentedButton() {
    return SegmentedButton<String>(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const Color.fromARGB(255, 214, 47, 32);
          }
          return Colors.grey.shade200;
        }),
        textStyle: WidgetStateProperty.resolveWith<TextStyle?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            );
          }
          return const TextStyle(color: Color.fromARGB(255, 214, 47, 32));
        }),
      ),

      segments: const <ButtonSegment<String>>[
        ButtonSegment<String>(
          value: 'Supervisor',
          label: Text('Supervisor'),
          icon: Icon(Icons.person),
        ),
        ButtonSegment<String>(
          value: 'Human Resource',
          label: Text('Human Resource'),
          icon: Icon(Icons.business_center),
        ),
      ],
      selected: _userRoleController,
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _userRoleController = newSelection;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget verticalSpace = SizedBox(height: formSpacing);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrowScreen = constraints.maxWidth < 600;

                return Container(
                  width: isNarrowScreen ? constraints.maxWidth * 0.9 : 946,
                  constraints: BoxConstraints(
                    minHeight: isNarrowScreen
                        ? MediaQuery.of(context).size.height * 0.9
                        : 527,
                    maxHeight: isNarrowScreen ? double.infinity : 527,
                    maxWidth: 946,
                  ),
                  margin: isNarrowScreen ? EdgeInsets.zero : EdgeInsets.symmetric(vertical: 32.0),
                  padding: isNarrowScreen ? EdgeInsets.zero : EdgeInsets.symmetric(vertical: 32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(45),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: isNarrowScreen
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            const SizedBox(
                              width: 150,
                              height: 150,
                              child: Image(
                                image: AssetImage('assets/images/logo.png'),
                              ),
                            ),
                            const Text(
                              'Ephor',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            verticalSpace,
                            const Text(
                              'Sign in to your university account',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            verticalSpace,
                            verticalSpace,
                            TextFormField(
                              controller: _employeeCodeController,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Employee code is required';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Employee Code',
                                hintText: 'Enter Employee Code',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.person),
                              ),
                            ),
                            verticalSpace,
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.lock),
                              ),
                            ),
                            verticalSpace,
                            Row(
                              children: [
                                Expanded(child: _buildRoleSegmentedButton()),
                              ],
                            ),
                            verticalSpace,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value!;
                                        });
                                      },
                                    ),
                                    const Text('Remember Me'),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    //INPUT LATER
                                  },
                                  child: const Text('Forget Password'),
                                ),
                              ],
                            ),
                            verticalSpace,
                            Align(
                              alignment: Alignment.centerRight,
                              child: ListenableBuilder(
                                listenable: widget.viewModel.login, 
                                builder: (context, _) {
                                  return ElevatedButton(
                                    onPressed: widget.viewModel.isLoading
                                      ? null
                                      : () => _handleLogin(context), 
                                    child: widget.viewModel.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text("Login")
                                  );
                                }
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Flexible(
                              flex: 1,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      height: 150,
                                      child: Image(
                                        image: AssetImage(
                                          'assets/images/logo.png',
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Ephor',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            Flexible(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Welcome',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Sign in to your university account',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    verticalSpace,
                                    TextFormField(
                                      controller: _employeeCodeController,
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Employee code is required';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Employee Code',
                                        hintText: 'Enter Employee Code',
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.person),
                                      ),
                                    ),
                                    verticalSpace,
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Password is required';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Password',
                                        hintText: 'Enter your password',
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.lock),
                                      ),
                                    ),
                                    verticalSpace,
                                    verticalSpace,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildRoleSegmentedButton(),
                                        ),
                                      ],
                                    ),
                                    verticalSpace,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: _rememberMe,
                                              onChanged: (value) {
                                                setState(() {
                                                  _rememberMe = value!;
                                                });
                                              },
                                            ),
                                            const Text('Remember Me'),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () {
                                            //INPUT LATER
                                          },
                                          child: const Text('Forget Password'),
                                        ),
                                      ],
                                    ),
                                    verticalSpace,
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ListenableBuilder(
                                        listenable: widget.viewModel.login, 
                                        builder: (context, _) {
                                          return ElevatedButton(
                                            onPressed: widget.viewModel.isLoading
                                              ? null
                                              : () => _handleLogin(context),
                                            child: widget.viewModel.isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  )
                                                )
                                              : const Text("Login")
                                          );
                                        }
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                    ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onResult() {
    if (widget.viewModel.login.completed) {
      widget.viewModel.login.clearResult();
      context.go(Routes.dashboard);
    }

    if (widget.viewModel.login.error) {
      Error error = widget.viewModel.login.result as Error;
      CustomMessageException messageException = error.error as CustomMessageException;
      widget.viewModel.login.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Error: ${messageException.message}"),
          action: SnackBarAction(
            label: "Try Again",
            onPressed: () => widget.viewModel.login.execute((
              _employeeCodeController.text.trim(),
              _passwordController.text,
              _userRoleController.first,
              _rememberMe
            )),
          ),
        ),
      );
    }
  }
}