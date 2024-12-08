import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/splash/presentation/splash_provider.dart';
import 'package:medisafe/features/role_selection/presentation/role_selection_screen.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashState = ref.watch(splashProvider);

    splashState.when(
      data: (value) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const RoleSelectionScreen()),
          );
        });
      },
      loading: () => _buildLoadingScreen(),
      error: (error, stack) => _buildErrorScreen(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/Splash.png", width: 250, height: 250),
            const Text(
              "eClinic",
              style: TextStyle(
                fontSize: 31,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorScreen() {
    return const Center(
      child: Text("Error loading data"),
    );
  }
}
