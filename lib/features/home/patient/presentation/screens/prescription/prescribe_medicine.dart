import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class PrescribeMedicine extends StatefulWidget {
  final String patientId;

  const PrescribeMedicine({super.key, required this.patientId});

  @override
  _PrescribeMedicineState createState() => _PrescribeMedicineState();
}

class _PrescribeMedicineState extends State<PrescribeMedicine> {
  final ImagePicker _picker = ImagePicker();
  String extractedText = "";
  XFile? _selectedImage;
  String _uploadedImageUrl = "";
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _selectedImage = image;
    });

    await _uploadImageToFirebase(image);
  }

  Future<void> _uploadImageToFirebase(XFile imageFile) async {
  if (!mounted) return;

  setState(() {
    _isLoading = true;
  });

  try {
    String fileName = basename(imageFile.path);
    Reference storageRef = FirebaseStorage.instance.ref().child("prescriptions/$fileName");

    UploadTask uploadTask = storageRef.putData(await imageFile.readAsBytes());

    // 🔹 Ensure task is completed before getting URL
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    if (!mounted) return;
    setState(() {
      _uploadedImageUrl = imageUrl;
    });

    ScaffoldMessenger.of(this.context).showSnackBar(
      const SnackBar(content: Text("Image uploaded successfully!")),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(content: Text("Image upload failed: $e")),
    );
  } finally {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }
}


  Future<void> _extractTextFromImage(String imageUrl) async {
    try {
      if (kIsWeb) {
        // 🔹 Simulate Web OCR (Replace with actual Firebase Vision API)
        setState(() {
          extractedText = "Simulated OCR text from Firebase Vision (Web).";
          _medicineController.text = extractedText;
        });
      } else {
        // 🔹 Placeholder for ML Kit on mobile
        setState(() {
          extractedText = "Text recognition is available on mobile using Google ML Kit.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        extractedText = "Error in text recognition";
      });
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text("Error extracting text: $e")),
      );
    }
  }

  void _submitPrescription() async {
    if (_medicineController.text.isEmpty || _dosageController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    await FirebaseFirestore.instance.collection('prescriptions').add({
      'patientId': widget.patientId,
      'medicine': _medicineController.text,
      'dosage': _dosageController.text,
      'instructions': _instructionsController.text,
      'imageUrl': _uploadedImageUrl,
      'timestamp': Timestamp.now(),
    });

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(this.context).showSnackBar(
      const SnackBar(content: Text("Prescription saved successfully!")),
    );
    Navigator.pop(this.context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescribe Medicine"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = kIsWeb; // Detects if running on Web

          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: isWeb ? 500 : double.infinity, // Restrict width for web
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display Selected Image
                    if (_uploadedImageUrl.isNotEmpty)
                      Center(
                        child: Column(
                          children: [
                            Image.network(_uploadedImageUrl, height: 200, errorBuilder: (context, error, stackTrace) {
                              return const Text("Failed to load image");
                            }),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),

                    // Image Capture Buttons
                    _buildImageButtons(),

                     const SizedBox(height: 20),

                    // // Extracted Prescription Text
                    // _buildTextField("Extracted Prescription Text", _medicineController, maxLines: 5),

                    // const SizedBox(height: 10),

                    // // Dosage
                    // _buildTextField("Dosage", _dosageController),

                    // const SizedBox(height: 10),

                    // // Instructions
                    // _buildTextField("Instructions", _instructionsController, maxLines: 3),

                    // const SizedBox(height: 20),

                    // Save Button
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitPrescription,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Save Prescription", style: TextStyle(fontSize: 16)),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.camera),
          icon: const Icon(Icons.camera),
          label: const Text("Capture Image"),
        ),
        const SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery),
          icon: const Icon(Icons.image),
          label: const Text("Select from Gallery"),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

