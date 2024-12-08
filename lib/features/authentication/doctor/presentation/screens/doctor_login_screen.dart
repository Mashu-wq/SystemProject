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
        // When login is successful, navigate to DoctorHomeScreen
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  "assets/images/1.jpeg", // Make sure to have this image asset in your project
                  height: 200,
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
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Your Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.visibility_off),
                        onPressed: () {
                          // Add password visibility toggle logic here if needed
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                loginState.maybeWhen(
                  loading: () => const CircularProgressIndicator(),
                  orElse: () => ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await ref.read(doctorLoginController.notifier).signIn(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 15),
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: const Text('Login'),
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
                  onPressed: () {
                    // Navigate to the forgot password screen
                  },
                  child: const Text('Forget Password?',
                      style: TextStyle(color: Colors.deepPurple)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        // Navigate to the registration screen
                      },
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const DoctorRegistrationScreen()));
                          },
                          child: const Text('Create New Account')),
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
  }
}
