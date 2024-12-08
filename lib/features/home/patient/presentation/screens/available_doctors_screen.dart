import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/doctor/presentation/screens/doctor_details_screen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/search_doctor_screen.dart';
import 'package:medisafe/features/home/patient/presentation/widgets/customBottomNavigationBar.dart';
import 'package:medisafe/models/doctor_model.dart';
import 'package:medisafe/features/home/doctor/presentation/controllers/doctors_controller.dart';

class AvailableDoctorsScreen extends ConsumerWidget {
  const AvailableDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsState = ref.watch(doctorsControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Available Specialist',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SearchDoctorScreen()),
              );
            },
          ),
        ],
      ),
      body: doctorsState.when(
        data: (doctors) => _buildDoctorsGrid(doctors),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: $e'),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildDoctorsGrid(List<Doctor> doctors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Display two cards per row
          childAspectRatio: 0.7, // Adjust the aspect ratio for card height
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          return _buildDoctorCard(context, doctors[index]);
        },
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    return GestureDetector(
      onTap: () {
        // Navigate to the doctor details screen when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetailsScreen(doctor: doctor),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(doctor.profileImageUrl),
                radius: 40, // Profile image size
              ),
              const SizedBox(height: 12),
              Text(
                'Dr. ${doctor.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                doctor.specialization,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Experience: ${doctor.experience} Years',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Patients: ${doctor.patients}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
