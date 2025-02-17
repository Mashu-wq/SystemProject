import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medisafe/features/authentication/patient/presentation/screens/appointment_page.dart';
import 'package:medisafe/features/home/doctor/presentation/screens/rating_submission_screen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/call_screen/voice_call_screen.dart';
import 'package:medisafe/models/doctor_model.dart';
import 'reviews_page.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Doctor doctor;
  final String patiendId;

  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
    required this.patiendId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600; // Detects web layout

          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: isWeb ? 500 : double.infinity, // Restrict width on web
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
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
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),

                    // Call, Video & Message Buttons
                    _buildActionButtons(context),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Biography
                    _buildBiographySection(),

                    const SizedBox(height: 16),

                    // Doctor Stats
                    _buildDoctorStats(context),

                    const SizedBox(height: 24),

                    // Book Appointment Button
                    _buildBookAppointmentButton(context),

                    const SizedBox(height: 30),

                    // Reviews Section
                    _buildReviewsSection(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.call,
          label: 'Voice Call',
          color: Colors.blue,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VoiceCallScreen(
                  doctor: doctor,
                  patientId: patiendId,
                ),
              ),
            );
          },
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
    );
  }

  Widget _buildBiographySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Biography',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          doctor.about.isEmpty ? 'No description available.' : doctor.about,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDoctorStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatistic('Patients', doctor.patients.toString()),
        _buildStatistic('Experience', '${doctor.experience} Years'),
        _buildDynamicReviewStatistic(context, doctor.id),
      ],
    );
  }

  Widget _buildBookAppointmentButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentPage(doctor: doctor),
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
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      children: [
        const Text(
          'Reviews',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        RatingForm(doctorId: doctor.id),
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

  // Dynamically fetch and display the review count
  Widget _buildDynamicReviewStatistic(BuildContext context, String doctorId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('doctorId', isEqualTo: doctorId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }
        if (snapshot.hasError) {
          return const Text('Error');
        }

        final reviewCount = snapshot.data?.docs.length ?? 0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewsPage(doctorId: doctorId),
              ),
            );
          },
          child: Column(
            children: [
              Text(
                '$reviewCount',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Text(
                'Reviews',
                style: TextStyle(fontSize: 14, color: Colors.blueAccent),
              ),
            ],
          ),
        );
      },
    );
  }
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
