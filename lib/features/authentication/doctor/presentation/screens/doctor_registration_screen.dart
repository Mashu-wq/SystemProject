import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medisafe/features/authentication/doctor/presentation/screens/doctor_login_screen.dart';

class DoctorRegistrationScreen extends ConsumerStatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  _DoctorRegistrationScreenState createState() =>
      _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState
    extends ConsumerState<DoctorRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();
  //String _selectedCategory = 'Cardiologist'; // Default category

  String _selectedGender = 'Male'; // Default gender
  DateTime? _selectedDate; // Date of Birth
  String? _selectedCategory;
  File? _profileImage; // To hold the selected image

  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;

  final List<String> _categories = [
    'Cardiologist',
    'Neurologist',
    'Pediatrician',
    'General',
    'Dentist',
    'Orthopedic',
    'Dermatologist',
    'Medicine'
    // Add more categories as needed
  ];

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Function to register doctor and store data in Firebase
  Future<void> _registerDoctor() async {
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
      Reference storageRef =
          _storage.ref().child('doctor_profiles/$userId.jpg');
      UploadTask uploadTask = storageRef.putFile(_profileImage!);
      TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() => null);
      String profileImageUrl = await storageSnapshot.ref.getDownloadURL();

      // Step 3: Store Doctor Info in Firestore
      await _firestore.collection('doctors').doc(userId).set({
        'doctor_name': _nameController.text.trim(),
        'clinic_name': _hospitalController.text.trim(),
        'email': _emailController.text.trim(),
        'contact_number': _contactController.text.trim(),
        'date_of_birth':
            _selectedDate != null ? _selectedDate!.toIso8601String() : '',
        'qualifications': _positionController.text.trim(),
        'gender': _selectedGender,
        'experience': int.parse(_experienceController.text.trim()),
        'specialization': _selectedCategory,
        'available_time': _scheduleController.text.trim(),
        'about': _bioController.text.trim(),
        'profile_image_url': profileImageUrl,
      });

      // Step 4: Notify Success and Redirect to Login Screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor registered successfully!')),
      );

      // Navigate to the Login Screen after registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DoctorLoginScreen()),
      );
    } catch (e) {
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
                        'Doctor Registration',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Profile Image Selector with Image Picker
                      _buildProfileImageSelector(),
                      const SizedBox(height: 10),

                      // Doctor Full Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Doctor Full Name',
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your full name'
                            : null,
                      ),
                      const SizedBox(height: 8),

                      // Hospital or Clinic Name & Address
                      _buildTextField(
                        controller: _hospitalController,
                        label: 'Hospital or Clinic Name & Address',
                        icon: Icons.local_hospital,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your hospital or clinic name'
                            : null,
                      ),
                      const SizedBox(height: 8),

                      // Doctor Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Doctor Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.contains('@')
                            ? null
                            : 'Please enter a valid email',
                      ),
                      const SizedBox(height: 8),

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
                      const SizedBox(height: 8),

                      // Date of Birth Picker
                      _buildDateOfBirthPicker(context),
                      const SizedBox(height: 8), // Position (Degree)
                      _buildTextField(
                        controller: _positionController,
                        label: 'Position (Degree)',
                        icon: Icons.badge,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your position'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _experienceController,
                        label: 'Experience (Years)',
                        icon: Icons.timeline,
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter years of experience'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 8),
                      // Consultancy Schedule
                      _buildTextField(
                        controller: _scheduleController,
                        label: 'Consultancy Schedule',
                        icon: Icons.schedule,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your consultancy schedule'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      // Bio
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _bioController,
                          maxLines:
                              3, // This will allow the TextFormField to have up to 3 lines.
                          decoration: InputDecoration(
                            labelText: 'Bio',
                            prefixIcon: const Icon(Icons.description),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a bio' : null,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),
                      _buildGenderSelection(),
                      const SizedBox(height: 8),

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
                      const SizedBox(height: 8),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.purpleAccent,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                           
                            _registerDoctor().then((_) {
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
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please fill in all fields and select an image.')),
                            );
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

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Category',
          prefixIcon: const Icon(Icons.category),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        items: _categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value!;
          });
        },
        validator: (value) => value == null ? 'Please select a category' : null,
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

  // Date of Birth Picker
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
