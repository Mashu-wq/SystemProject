import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/models/doctor_model.dart';
import 'package:medisafe/providers.dart';

class ProfileScreen extends ConsumerWidget {
  final String doctorId;

  ProfileScreen({super.key, required this.doctorId})
      : assert(doctorId.isNotEmpty, "Doctor ID cannot be empty");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (doctorId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Doctor's Profile")),
        body: const Center(
          child: Text(
            "Error: Doctor ID is empty or null",
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final profileAsyncValue = ref.watch(doctorProfileProvider(doctorId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor's Profile"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600; // Detect web layout

          return profileAsyncValue.when(
            data: (profile) => Center(
              child: Container(
                width: isWeb ? 500 : double.infinity, // Restrict width on web
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 16),
                child: ProfileDetails(profile: profile, ref: ref),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text("Error: $error")),
          );
        },
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  final Doctor profile;
  final WidgetRef ref;

  const ProfileDetails({super.key, required this.profile, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profile.profileImageUrl),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(profile.email),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Editable Fields
          _buildEditableCard(context, "Specialization", profile.specialization, "specialization"),
          _buildEditableCard(context, "Experience", "${profile.experience} years", "experience"),
          _buildEditableCard(context, "Qualifications", profile.qualifications, "qualifications"),
          _buildEditableCard(context, "Available Schedule", profile.availableTime, "available_schedule"),
          _buildEditableCard(context, "About", profile.about, "about"),

          const Divider(),

          // Doctor Stats
          _buildStatisticCard(
            title: "Appointments Overview",
            stats: [
              _buildStatistic("Pending", profile.patients.toString()),
              _buildStatistic("Visited", profile.patients.toString()),
              _buildStatistic("Total Patients", profile.patients.toString()),
              _buildStatistic("Experience", "${profile.experience} years"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistic(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _buildEditableCard(BuildContext context, String title, String value, String fieldKey) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isEmpty ? "Tap to add $title" : value),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final newValue = await showDialog<String>(
              context: context,
              builder: (context) => EditFieldDialog(title: title, initialValue: value),
            );

            if (newValue != null && newValue.trim().isNotEmpty) {
              _updateField(context, fieldKey, newValue.trim());
            }
          },
        ),
      ),
    );
  }

  void _updateField(BuildContext context, String field, String value) async {
    try {
      final provider = ref.read(updateDoctorProfileProvider);
      await provider.updateDoctorProfile(profile.id, {field: value});

      ref.refresh(doctorProfileProvider(profile.id));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  Widget _buildStatisticCard({required String title, required List<Widget> stats}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Column(children: stats),
          ],
        ),
      ),
    );
  }
}

class EditFieldDialog extends StatelessWidget {
  final String title;
  final String initialValue;

  const EditFieldDialog({super.key, required this.title, required this.initialValue});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: initialValue);

    return AlertDialog(
      title: Text("Edit $title"),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: "Enter $title"),
        maxLines: title == "About" ? 4 : 1,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
        TextButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text("Save")),
      ],
    );
  }
}
