import 'package:flutter/material.dart';
import 'package:medisafe/features/authentication/doctor/presentation/screens/doctor_login_screen.dart';
import 'package:medisafe/features/authentication/patient/presentation/screens/patient_login_screen.dart';
// import 'package:medisafe/features/doctor/presentation/doctor_login_screen.dart';
// import 'package:medisafe/features/patient/presentation/patient_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/2.jpeg", // Your image here
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              "Select What You Are?",
              style: TextStyle(
                fontSize: 22,
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _buildRoleButton(
                context, "Doctor", DoctorLoginScreen(), Colors.purple),
            const SizedBox(height: 15),
            _buildRoleButton(
                context, "Patient", PatientLoginScreen(), Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
      BuildContext context, String title, Widget screen, Color color) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
