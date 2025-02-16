import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class PrescribeMedicine extends StatefulWidget {
  final String patientId;

  const PrescribeMedicine({super.key, required this.patientId});

  @override
  _PrescribeMedicineState createState() => _PrescribeMedicineState();
}

class _PrescribeMedicineState extends State<PrescribeMedicine> {
  final ImagePicker _picker = ImagePicker();
  String extractedText = "";
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    final InputImage inputImage = InputImage.fromFilePath(image.path);
    final TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      extractedText = recognizedText.text;
      _medicineController.text = extractedText;
    });

    textRecognizer.close();
  }

  void _submitPrescription() async {
    if (_medicineController.text.isEmpty || _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await FirebaseFirestore.instance.collection('prescriptions').add({
      'patientId': widget.patientId,
      'medicine': _medicineController.text,
      'dosage': _dosageController.text,
      'instructions': _instructionsController.text,
      'timestamp': Timestamp.now(),
    });

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Prescription saved successfully!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescribe Medicine"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: const Text("Capture Image"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Text("Select from Gallery"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _medicineController,
              decoration: const InputDecoration(
                labelText: "Extracted Prescription Text",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: "Dosage",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: "Instructions",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitPrescription,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text("Save Prescription"),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
