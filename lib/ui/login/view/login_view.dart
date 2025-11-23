import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:ephor/ui/login/view_model/login_viewmodel.dart';
import 'package:go_router/go_router.dart';

import 'package:ephor/routing/routes.dart';
import 'package:ephor/utils/responsiveness.dart';

class LoginView extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginView({super.key, required this.viewModel});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  static const double _formSpacing = 16.0;
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _isForgetPasswordHovered = false;
  final TextEditingController _employeeCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Set<String> _userRoleController = {'Supervisor'};
  final _formKey = GlobalKey<FormState>();

  Map<String, String> roles = {
    'Human Resource': 'humanResource',
    'Supervisor': 'supervisor'
  };

  @override
  void initState() {
    super.initState();
    widget.viewModel.login.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant LoginView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.login != widget.viewModel.login) {
      oldWidget.viewModel.login.removeListener(_onResult);
      widget.viewModel.login.addListener(_onResult);
    }
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
        roles[_userRoleController.first]
      ));
    }
  }

  Widget _buildRoleSegmentedButton() {
    return SegmentedButton<String>(
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

  /// Builds the left panel for the desktop layout (Logo and Title).
  Widget _buildDesktopLogoPanel() {
    return const Flexible(
      flex: 1,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Image(
                image: AssetImage('assets/images/logo_square.png'),
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
    );
  }

  /// Builds the core login form content, dynamically including/excluding the
  /// logo block based on the screen size from the Responsive utility.
  Widget _buildLoginForm() {
    final isMobile = Responsive.isMobile(context);
    final Widget verticalSpace = const SizedBox(height: _formSpacing);

    final formContent = <Widget>[
      // --- Mobile Logo/Title Block (Only appears on mobile) ---
      if (isMobile) ...[
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
      ],

      // --- Desktop Welcome Text (Only appears on desktop) ---
      if (!isMobile) ...[
        const Text(
          'Welcome',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
      ],

      // --- Shared 'Sign In' Text ---
      const Text(
        'Sign in to your university account',
        style: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      ),
      verticalSpace,
      verticalSpace,

      // --- Form Fields ---
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
              // color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ),
      verticalSpace,

      // --- Role Segmented Button ---
      Row(
        children: [
          Expanded(child: _buildRoleSegmentedButton()),
        ],
      ),
      verticalSpace,

      // --- Remember Me / Forget Password ---
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
                  widget.viewModel.setRememberMe.execute(_rememberMe);
                },
              ),
              const Text('Remember Me'),
            ],
          ),
          InkWell(
            onTap: () {
              context.go(Routes.forgotPassword);
            },
            onHover: (hovered) {
              setState(() {
                _isForgetPasswordHovered = hovered;
              });
            },
            child: Text(
              'Forget Password',
              style: TextStyle(
                decoration: _isForgetPasswordHovered
                  ? TextDecoration.underline
                  : TextDecoration.none,
                decorationColor: _isForgetPasswordHovered
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
                color: _isForgetPasswordHovered
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface
              )
            ),
          ),
        ],
      ),
      verticalSpace,

      // --- Login Button ---
      Align(
        alignment: Alignment.centerRight,
        child: ListenableBuilder(
          listenable: widget.viewModel.login,
          builder: (context, _) {
            Color surfaceColor = Theme.of(context).colorScheme.surface;
            return FilledButton(
              onPressed: widget.viewModel.isLoading
                  ? null
                  : () => _handleLogin(context),
              child: widget.viewModel.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(surfaceColor),
                      ),
                    )
                  : const Text("Login"),
            );
          },
        ),
      ),
    ];

    return Form(
      key: _formKey,
      child: Column(
        // Center for mobile, start for desktop (where it's on the right side)
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: formContent,
      ),
    );
  }

  /// The main structure that wraps the form for all screen sizes,
  /// with sizing determined by the Responsive utility.
  Widget _buildLoginWrapper({required Widget child}) {
    final isMobile = Responsive.isMobile(context);

    // The logic for size constraints is determined here based on isMobile
    final double width = isMobile ? MediaQuery.of(context).size.width * 0.9 : 946;
    final BoxConstraints constraints = BoxConstraints(
      minHeight: isMobile ? MediaQuery.of(context).size.height * 0.9 : 527,
      maxHeight: isMobile ? double.infinity : 527,
      maxWidth: 946,
    );

    return Center(
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            width: width,
            constraints: constraints,
            margin: const EdgeInsets.symmetric(vertical: 32.0),
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 32.0),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(224),
              borderRadius: BorderRadius.circular(45),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/school.jpg"),
            fit: BoxFit.fill,
            opacity: 0.4,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary.withAlpha(80), 
              BlendMode.color
            )
          )
          // gradient: LinearGradient(
          //   begin: AlignmentGeometry.bottomLeft,
          //   end: AlignmentGeometry.topRight,
          //   colors: [
          //     Color(0xffac575d),
          //     Color(0xffC68380),
          //     Color(0xffE0B0A4),
          //     Color(0xffC68380),
          //     Color(0xffac575d),
          //   ],
          //   stops: [
          //     0.00,
          //     0.08,
          //     0.50,
          //     0.75,
          //     1.00
          //   ]
          // ),
        ),
        // color: Theme.of(context).colorScheme.surface,
        child: Responsive(
          mobile: _buildLoginWrapper(
            child: _buildLoginForm(),
          ),
          desktop: _buildLoginWrapper(
            child: Row(
              children: [
                _buildDesktopLogoPanel(),
                const SizedBox(width: 32),
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildLoginForm(),
                  ),
                ),
              ],
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
      return;
    }

    if (widget.viewModel.login.error) {
      Error error = widget.viewModel.login.result as Error;
      CustomMessageException messageException = error.error as CustomMessageException;
      widget.viewModel.login.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Error: ${messageException.message}"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}