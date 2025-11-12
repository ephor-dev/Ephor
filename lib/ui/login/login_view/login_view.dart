import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ephor/ui/login/login_viewmodel/login_viewmodel.dart';
import 'package:ephor/domain/models/login/user_role.dart';
import 'package:ephor/domain/models/login/login_request.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

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
  void dispose() {
    _employeeCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login button press
  Future<void> _handleLogin(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = Provider.of<LoginViewModel>(context, listen: false);
      
      // Get selected role
      final selectedRole = _userRoleController.first;
      final userRole = UserRole.fromString(selectedRole);

      // Create login request
      final loginRequest = LoginRequest(
        employeeCode: _employeeCodeController.text.trim(),
        password: _passwordController.text,
        userRole: userRole,
        rememberMe: _rememberMe,
      );

      // Attempt login
      final response = await viewModel.signInWithEmployeeCode(loginRequest);

      if (response.success && response.isAuthenticated) {
        // Navigate to next screen on success
        // TODO: Navigate to home/dashboard screen
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Error is already set in viewmodel, just show snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
          value: 'Human Resources',
          label: Text('Human Resources'),
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
                  margin: const EdgeInsets.symmetric(vertical: 32.0),
                  padding: const EdgeInsets.all(32),
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
                                image: AssetImage('assets/ephor logo.jpg'),
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
                            // Error message display
                            if (Provider.of<LoginViewModel>(context).errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  Provider.of<LoginViewModel>(context).errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Consumer<LoginViewModel>(
                                builder: (context, viewModel, child) {
                                  return ElevatedButton(
                                    onPressed: viewModel.isLoading
                                        ? null
                                        : () => _handleLogin(context),
                                    child: viewModel.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text('Login'),
                                  );
                                },
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
                                          'assets/ephor logo.jpg',
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
                                    // Error message display
                                    if (Provider.of<LoginViewModel>(context).errorMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          Provider.of<LoginViewModel>(context).errorMessage!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Consumer<LoginViewModel>(
                                        builder: (context, viewModel, child) {
                                          return ElevatedButton(
                                            onPressed: viewModel.isLoading
                                                ? null
                                                : () => _handleLogin(context),
                                            child: viewModel.isLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  )
                                                : const Text('Login'),
                                          );
                                        },
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
}