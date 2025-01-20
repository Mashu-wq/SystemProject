import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisafe/models/prescription_model.dart';

class PatientPrescriptionScreen extends StatelessWidget {
  final String patientId;

  const PatientPrescriptionScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Prescriptions")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prescriptions')
            .where('patientId', isEqualTo: patientId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No prescriptions found."));
          }

          final prescriptions = snapshot.data!.docs.map((doc) {
            return Prescription.fromFirestore(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              return Card(
                child: ListTile(
                  title: Text("Prescription ${index + 1}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: prescription.medicines.map((medicine) {
                      return Text(
                          "${medicine.name} - ${medicine.dose} (${medicine.time})");
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
