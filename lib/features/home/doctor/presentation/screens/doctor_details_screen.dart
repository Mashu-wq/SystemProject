import 'package:flutter/material.dart';
import 'package:medisafe/features/authentication/patient/presentation/screens/appointment_page.dart';
import 'package:medisafe/models/doctor_model.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(doctor.profileImageUrl),
                radius: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Dr. ${doctor.name}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                doctor.specialization,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                '${doctor.clinicName}, ${doctor.qualifications}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.call,
                    label: 'Voice Call',
                    color: Colors.blue,
                    onPressed: () {},
                  ),
                  _buildActionButton(
                    icon: Icons.video_call,
                    label: 'Video Call',
                    color: Colors.purple,
                    onPressed: () {},
                  ),
                  _buildActionButton(
                    icon: Icons.message,
                    label: 'Message',
                    color: Colors.orange,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Biography',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                doctor.qualifications.isEmpty
                    ? 'No description available.'
                    : doctor.about,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatistic('Patients', doctor.patients.toString()),
                  _buildStatistic('Experience', '${doctor.experience} Years'),
                  _buildStatistic('Reviews', '2.05K'), // Example static value
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to booking screen or perform booking
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentPage(
                          doctor: doctor), // Navigate to AppointmentPage
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Book an Appointment',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: color),
          onPressed: onPressed,
        ),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  Widget _buildStatistic(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
