import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medisafe/features/authentication/patient/presentation/screens/patient_login_screen.dart';

class PatientRegistrationScreen extends ConsumerStatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  _PatientRegistrationScreenState createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState
    extends ConsumerState<PatientRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedGender = 'Male'; // Default gender
  DateTime? _selectedDate; // Date of Birth
  int? _age; // Age calculated from DOB
  File? _profileImage; // To hold the selected image

  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Function to calculate age from DOB
  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Function to register patient and store data in Firebase
  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate() || _profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete the form and select an image.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Create User in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid;

      // Step 2: Upload Image to Firebase Storage
      print('Uploading image...');
      Reference storageRef =
          _storage.ref().child('patient_profiles/$userId.jpg');
      UploadTask uploadTask = storageRef.putFile(_profileImage!);
      TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() => null);
      String profileImageUrl = await storageSnapshot.ref.getDownloadURL();
      print('Image uploaded successfully, URL: $profileImageUrl');

      // Step 3: Store Patient Info in Firestore
      print('Saving patient data to firestore...');
      await _firestore.collection('patients').doc(userId).set({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'address': _addressController.text.trim(),
        'email': _emailController.text.trim(),
        'contact_number': _contactController.text.trim(),
        'date_of_birth':
            _selectedDate != null ? _selectedDate!.toIso8601String() : '',
        'age': _age, // Store calculated age
        'gender': _selectedGender,
        'profile_image_url': profileImageUrl,
      });

      print('Patient data saved successfully');

      // Step 4: Notify Success and Redirect to Login Screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient registered successfully!')),
      );

      // Navigate to the Login Screen after registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientLoginScreen()),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        'Patient Registration',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Profile Image Selector with Image Picker
                      _buildProfileImageSelector(),
                      const SizedBox(height: 10),

                      // First Name
                      _buildTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your first name'
                            : null,
                      ),
                      const SizedBox(height: 10),

                      // Last Name
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        icon: Icons.person_outline,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your last name'
                            : null,
                      ),
                      const SizedBox(height: 10),

                      // Address
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.home,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your address' : null,
                      ),
                      const SizedBox(height: 10),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.contains('@')
                            ? null
                            : 'Please enter a valid email',
                      ),
                      const SizedBox(height: 10),

                      // Contact Number
                      _buildTextField(
                        controller: _contactController,
                        label: 'Contact Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.length >= 10
                            ? null
                            : 'Enter valid phone number',
                      ),
                      const SizedBox(height: 10),

                      // Date of Birth Picker and Age Display
                      _buildDateOfBirthPicker(context),
                      const SizedBox(height: 10),

                      // Display Age
                      if (_age != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Age: $_age',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Gender Selection
                      _buildGenderSelection(),
                      const SizedBox(height: 10),

                      // Password
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your password'
                            : null,
                      ),
                      const SizedBox(height: 10),

                      // Register Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.deepPurple,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _registerPatient()
                                // ref
                                //     .read(patientRegistrationController.notifier)
                                //     .registerPatient(
                                //       email: _emailController.text.trim(),
                                //       password: _passwordController.text.trim(),
                                //       firstName: _firstNameController.text.trim(),
                                //       lastName: _lastNameController.text.trim(),
                                //       address: _addressController.text.trim(),
                                //       contactNumber: _contactController.text.trim(),
                                //       gender: _selectedGender,
                                //       dateOfBirth: _selectedDate!,
                                //       profileImage:
                                //           _profileImage, // The image file selected by the user
                                //       age: _age!, // Pass the calculated age
                                //     )
                                .then((_) {
                              // Navigate back to the login screen after successful registration
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Registration successful')),
                              );
                              Navigator.of(context).pop();
                            }).catchError((error) {
                              // Handle error if registration fails
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Registration failed: $error')),
                              );
                            });
                          }
                        },
                        child: const Text('Register'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Profile Image Selector Widget
  Widget _buildProfileImageSelector() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[200],
        backgroundImage:
            _profileImage != null ? FileImage(_profileImage!) : null,
        child: _profileImage == null
            ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
            : null,
      ),
    );
  }

  // Gender Selection Widget
  Widget _buildGenderSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text('Gender:'),
          Row(
            children: [
              Radio<String>(
                value: 'Male',
                groupValue: _selectedGender,
                onChanged: (String? value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
              const Text('Male'),
            ],
          ),
          Row(
            children: [
              Radio<String>(
                value: 'Female',
                groupValue: _selectedGender,
                onChanged: (String? value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
              const Text('Female'),
            ],
          ),
        ],
      ),
    );
  }

  // Date of Birth Picker and Age Calculation
  Widget _buildDateOfBirthPicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            _age = _calculateAge(pickedDate); // Calculate age from DOB
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(_selectedDate == null
              ? 'Select Date'
              : _selectedDate!.toLocal().toString().split(' ')[0]),
        ),
      ),
    );
  }

  // Reusable Text Field Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
