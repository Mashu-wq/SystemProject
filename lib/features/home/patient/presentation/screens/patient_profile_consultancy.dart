import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/doctor/presentation/screens/call_screen.dart';
import 'package:medisafe/features/home/doctor/presentation/screens/video_call_screen.dart';

import 'package:medisafe/features/home/patient/presentation/screens/prescription/prescribe_medicine.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medisafe/models/doctor_model.dart';

class PatientProfileForConsultancy extends ConsumerWidget {
  final String patientId;

  const PatientProfileForConsultancy({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Profile"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Patient data not found"));
          }

          final patientData = snapshot.data!.data() as Map<String, dynamic>;
          final patientName = patientData['first_name'] ?? 'Unknown';
          final age = patientData['age'] ?? 'N/A';
          final gender = patientData['gender'] ?? 'N/A';
          final contact = patientData['contact_number'] ?? 'N/A';
          final medicalHistory =
              patientData['medical_history'] ?? 'No history available';
          final profileImageUrl =
              patientData['profile_image'] ?? ''; // Profile image URL

          return LayoutBuilder(
            builder: (context, constraints) {
              bool isWeb = constraints.maxWidth > 600; // Detects web layout

              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    width:
                        isWeb ? 500 : double.infinity, // Restrict width for web
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: profileImageUrl.isEmpty
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          patientName,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "$gender, $age years old",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          "Contact: $contact",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        const Text("Medical History:",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child:
                              Text(medicalHistory, textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 30),

                        // Action Buttons (Voice Call, Video Call, Message)
                        _buildActionButtons(context, contact, patientId),

                        const SizedBox(height: 30),

                        // Prescribe Medicine Button
                        _buildPrescribeMedicineButton(context),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, String callerName, String callerImageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: FontAwesomeIcons.phone,
          label: "Voice Call",
          color: Colors.blue,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CallScreen(isVideoCall: false,
                callerName: callerName,
                callerImageUrl: callerImageUrl,)),
            );
          },
        ),
const SizedBox(width: 40),
 _ActionButton(
                          icon: FontAwesomeIcons.video,
                          label: "Video Call",
                          color: Colors.purple,
                          onPressed: () {
                            // The doctor object might be from your auth or Firestore
                            // For demo, we create a dummy doctor
                            final doc = Doctor(
                              id: "doc123",
                              name: "Dr. Smith",
                              email: "doc@example.com",
                              specialization: "General",
                              experience: 5,
                              patients: 50,
                              clinicName: "City Clinic",
                              qualifications: "MBBS, MD",
                              availableTime: "9AM-5PM",
                              area: "Downtown",
                              about: "Experienced in general medicine",
                              profileImageUrl:
                                  "https://example.com/doctor_profile.png", // Replace with actual doc image
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoCallScreen(
                                  doctor: doc,
                                  patientId: patientId, // James's ID
                                ),
                              ),
                            );
                          },
                        ),

      ],
    );
  }

  Widget _buildPrescribeMedicineButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PrescribeMedicine(patientId: ''),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text("Prescribe Medicine", style: TextStyle(fontSize: 16)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 30),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
