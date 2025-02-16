import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/doctor/presentation/controllers/categories_controller.dart';
import 'package:medisafe/features/home/doctor/presentation/controllers/doctors_controller.dart';
import 'package:medisafe/features/home/doctor/presentation/screens/doctor_details_screen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/CategoryDoctorsScreen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/search_doctor_screen.dart';
import 'package:medisafe/features/home/patient/presentation/widgets/customBottomNavigationBar.dart';
import 'package:medisafe/models/category_model.dart';
import 'package:medisafe/models/doctor_model.dart';

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsState = ref.watch(doctorsControllerProvider);
    final categoriesState = ref.watch(categoriesControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600; // Detects web layout
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 60 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBanner(isWeb),
                  const SizedBox(height: 20),
                  _buildCategoriesSection(context, categoriesState),
                  const SizedBox(height: 20),
                  _buildDoctorsSection(doctorsState),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Find Your Specialist',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchDoctorScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBanner(bool isWeb) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSingleBanner(
              title: 'Looking For Your Desire Specialist Doctor?',
              name: 'Dr. Asma Khan',
              specialization: 'Medicine & Heart Specialist',
              clinic: 'Good Health Clinic',
              width: isWeb ? 350 : 300,
            ),
            _buildSingleBanner(
              title: 'Need a Neurologist?',
              name: 'Dr. John Doe',
              specialization: 'Neurology Specialist',
              clinic: 'Brain Health Clinic',
              width: isWeb ? 350 : 300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleBanner({
    required String title,
    required String name,
    required String specialization,
    required String clinic,
    required double width,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: width,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.purpleAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                '$name\n$specialization\n$clinic',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, AsyncValue<List<Category>> categoriesState) {
    return categoriesState.when(
      data: (categories) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryDoctorsScreen(category: category),
                    ),
                  );
                },
                child: _buildCategoryTile(category),
              )).toList(),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error: $e'),
      ),
    );
  }

  Widget _buildCategoryTile(Category category) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(category.iconPath),
            radius: 30,
          ),
          const SizedBox(height: 4),
          Text(category.name),
        ],
      ),
    );
  }

  Widget _buildDoctorsSection(AsyncValue<List<Doctor>> doctorsState) {
    return doctorsState.when(
      data: (doctors) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Available Doctors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              return _buildDoctorCard(context, doctors[index]);
            },
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error: $e'),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetailsScreen(doctor: doctor, patiendId: '',),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(doctor.profileImageUrl),
            radius: 30,
          ),
          title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${doctor.specialization} • ${doctor.experience} years experience'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}
