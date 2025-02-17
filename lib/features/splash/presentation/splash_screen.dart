import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/splash/presentation/splash_provider.dart';
import 'package:medisafe/features/role_selection/presentation/role_selection_screen.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashState = ref.watch(splashProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      splashState.when(
        data: (value) {
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen()),
            );
          });
        },
        loading: () {},
        error: (error, stack) {
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen()),
            );
          });
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/Splash.png", width: 250, height: 250),
            const SizedBox(height: 10),
            const Text(
              "eClinic",
              style: TextStyle(
                fontSize: 31,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
