import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/patient/presentation/screens/prescription/prescribe_medicine.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          final medicalHistory = patientData['medical_history'] ?? 'No history available';
          final profileImageUrl = patientData['profile_image'] ?? ''; // Profile image URL

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : const AssetImage("assets/default_profile.png") as ImageProvider,
              ),
              const SizedBox(height: 16),
              Text("$patientName", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("$gender, $age years old", style: TextStyle(color: Colors.grey[600])),
              Text("Contact: $contact", style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              const Text("Medical History:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(medicalHistory, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    icon: FontAwesomeIcons.phone,
                    label: "Voice Call",
                    color: Colors.blue,
                    onPressed: () async {
                      final Uri phoneUrl = Uri.parse("tel:$contact");
                      if (await canLaunchUrl(phoneUrl)) {
                        await launchUrl(phoneUrl);
                      }
                    },
                  ),
                  const SizedBox(width: 40),
                  _ActionButton(
                    icon: FontAwesomeIcons.video,
                    label: "Video Call",
                    color: Colors.purple,
                    onPressed: () async {
                      final Uri videoUrl = Uri.parse("https://video-call-platform.com/$patientId");
                      if (await canLaunchUrl(videoUrl)) {
                        await launchUrl(videoUrl);
                      }
                    },
                  ),
                  const SizedBox(width: 40),
                  _ActionButton(
                    icon: FontAwesomeIcons.comment,
                    label: "Message",
                    color: Colors.orange,
                    onPressed: () {
                      // Implement message feature
                    },
                  ),
                ],
              ),
               const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrescribeMedicine(patientId: '',),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Prescribe Medicine"),
              ),
            ],
          );
        },
      ),
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
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}