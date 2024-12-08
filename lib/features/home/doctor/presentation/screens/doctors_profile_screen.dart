import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/models/doctor_model.dart';
import 'package:medisafe/providers.dart';

// class ProfileScreen extends ConsumerWidget {
//   final String doctorId;

//   ProfileScreen({super.key, required this.doctorId})
//       : assert(doctorId.isNotEmpty, "Doctor ID cannot be empty");

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     if (doctorId.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: const Text("Doctor's Profile")),
//         body: const Center(
//           child: Text(
//             "Error: Doctor ID is empty or null",
//             style: TextStyle(color: Colors.red),
//           ),
//         ),
//       );
//     }

//     final profileAsyncValue = ref.watch(doctorProfileProvider(doctorId));

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Doctor's Profile"),
//       ),
//       body: profileAsyncValue.when(
//         data: (profile) => ProfileDetails(profile: profile, ref: ref),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, _) => Center(child: Text("Error: $error")),
//       ),
//     );
//   }
// }

class ProfileScreen extends ConsumerWidget {
  final String doctorId;

  ProfileScreen({super.key, required this.doctorId, required String patientId})
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
      body: profileAsyncValue.when(
        data: (profile) => ProfileDetails(profile: profile, ref: ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("Error: $error")),
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  final Doctor profile;
  final WidgetRef ref; // Add WidgetRef here to access providers

  const ProfileDetails({super.key, required this.profile, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profile.profileImageUrl),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(profile.email),
          const SizedBox(height: 16),

          // Editable fields
          _buildEditableField(
            context,
            "Specialization",
            profile.specialization,
            "specialization",
          ),
          _buildEditableField(
            context,
            "Experience",
            "${profile.experience} years",
            "experience",
          ),
          _buildEditableField(
            context,
            "Qualifications",
            profile.qualifications,
            "qualifications",
          ),
          _buildEditableField(
            context,
            "Available Schedule",
            profile.availableTime, //added later
            "available_schedule",
          ),
          _buildEditableField(
            context,
            "About",
            profile.about,
            "about",
          ),
          const Divider(),
          _buildStatistic("Pending Appointments", profile.patients.toString()),
          _buildStatistic("Visited Appointments", profile.patients.toString()),
          _buildStatistic("Total Patients", profile.patients.toString()),
          _buildStatistic("Experience", "${profile.experience} years"),
        ],
      ),
    );
  }

  Widget _buildStatistic(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildEditableField(
      BuildContext context, String title, String value, String fieldKey) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value.isEmpty ? "Tap to add $title" : value),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () async {
          // Open a dialog to edit the field
          final newValue = await showDialog<String>(
            context: context,
            builder: (context) => EditFieldDialog(
              title: title,
              initialValue: value,
            ),
          );

          // If the user enters a new value, update it in Firebase
          if (newValue != null && newValue.trim().isNotEmpty) {
            _updateField(context, fieldKey, newValue.trim());
          }
        },
      ),
    );
  }

  void _updateField(BuildContext context, String field, String value) async {
    try {
      final provider = ref.read(updateDoctorProfileProvider);
      await provider.updateDoctorProfile(profile.id, {field: value});
      // Refetch the profile data manually (optional if using streams)
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
}

class EditFieldDialog extends StatelessWidget {
  final String title;
  final String initialValue;

  const EditFieldDialog(
      {super.key, required this.title, required this.initialValue});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: initialValue);

    return AlertDialog(
      title: Text("Edit $title"),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Enter $title",
        ),
        maxLines: title == "About" ? 4 : 1, // Multiline for "About"
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text("Save"),
        ),
      ],
    );
  }
}
