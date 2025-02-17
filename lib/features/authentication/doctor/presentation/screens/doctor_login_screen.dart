import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/authentication/doctor/presentation/controllers/doctor_login_controller.dart';
import 'package:medisafe/features/authentication/doctor/presentation/screens/doctor_registration_screen.dart';
import 'package:medisafe/features/home/doctor/presentation/screens/doctors_main_screen.dart';

class DoctorLoginScreen extends ConsumerWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  DoctorLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(doctorLoginController);

    ref.listen<AsyncValue<void>>(doctorLoginController, (previous, next) {
      if (next is AsyncData<void>) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DoctorMainScreen()),
        );
      }
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${next.error}")),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600;
          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: isWeb ? 450 : double.infinity, // Limits width on web
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Image.asset(
                        "assets/images/1.jpeg",
                        height: isWeb ? 180 : 150, // Adjusts image size for web
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Doctor Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                          _emailController, 'Your Email', Icons.email, false),
                      const SizedBox(height: 10),
                      _buildTextField(
                          _passwordController, 'Password', Icons.lock, true),
                      const SizedBox(height: 20),
                      loginState.maybeWhen(
                        loading: () => const CircularProgressIndicator(),
                        orElse: () => SizedBox(
                          width: double.infinity, // Full width button
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await ref
                                    .read(doctorLoginController.notifier)
                                    .signIn(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: const StadiumBorder(),
                              backgroundColor: Colors.deepPurple,
                            ),
                            child: const Text('Login'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      loginState.maybeWhen(
                        error: (e, stack) => Text(
                          'Error: $e',
                          style: const TextStyle(color: Colors.red),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Forget Password?',
                            style: TextStyle(color: Colors.deepPurple)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DoctorRegistrationScreen()));
                            },
                            child: const Text('Create New Account'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isPassword) {
    return TextFormField(
      controller: controller,
      keyboardType:
          isPassword ? TextInputType.text : TextInputType.emailAddress,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: const Icon(Icons.visibility_off),
                onPressed: () {},
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return isPassword
              ? 'Please enter your password'
              : 'Please enter a valid email';
        }
        if (!isPassword && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }
}
