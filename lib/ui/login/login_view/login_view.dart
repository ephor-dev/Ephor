import 'package:flutter/material.dart';

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

  Set<String> _userRoleController = {'employee'};

  @override
  void dispose() {
    _employeeCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
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
          value: 'employee',
          label: Text('Employee'),
          icon: Icon(Icons.person),
        ),
        ButtonSegment<String>(
          value: 'hr',
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
                            TextField(
                              controller: _employeeCodeController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                labelText: 'Employee Code',
                                hintText: 'Enter Employee Code',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.person),
                              ),
                            ),
                            verticalSpace,
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              keyboardType: TextInputType.text,
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
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text('Login'),
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
                                    TextField(
                                      controller: _employeeCodeController,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                        labelText: 'Employee Code',
                                        hintText: 'Enter Employee Code',
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.person),
                                      ),
                                    ),
                                    verticalSpace,
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      keyboardType: TextInputType.text,
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
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        child: const Text('Login'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
