import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/patient/presentation/widgets/customBottomNavigationBar.dart';
import 'package:medisafe/models/patient_model.dart';
import 'package:medisafe/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientProfileScreen extends ConsumerStatefulWidget {
  final String patientId;

  const PatientProfileScreen({super.key, required this.patientId});

  @override
  ConsumerState<PatientProfileScreen> createState() =>
      _PatientProfileScreenState();
}

class _PatientProfileScreenState extends ConsumerState<PatientProfileScreen> {
  bool isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Future<void> _updatePatientProfile(Patient patient) async {
    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patient.id)
          .update({
        'name': _nameController.text,
        'email': _emailController.text,
        'contactNumber': _phoneController.text,
        'address': _addressController.text,
      });
      setState(() {
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientState = ref.watch(patientProfileProvider(widget.patientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.settings),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: patientState.when(
        data: (patient) {
          _nameController.text = "${patient.firstName} ${patient.lastName}";
          _emailController.text = patient.email;
          _phoneController.text = patient.contactNumber;
          _addressController.text = patient.address;

          return _buildProfileDetails(patient);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("Error: $error")),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildProfileDetails(Patient patient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(patient.profileImageUrl),
              onBackgroundImageError: (_, __) =>
                  const Icon(Icons.person, size: 60),
            ),
          ),
          const SizedBox(height: 16),
          _buildEditableField("Name", _nameController),
          _buildEditableField("Email", _emailController),
          _buildEditableField("Phone", _phoneController),
          _buildEditableField("Address", _addressController),
          const SizedBox(height: 16),
          if (isEditing)
            ElevatedButton(
              onPressed: () => _updatePatientProfile(patient),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Save Changes"),
            ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
