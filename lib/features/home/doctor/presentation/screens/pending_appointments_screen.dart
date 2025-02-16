import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PendingAppointmentsScreen extends StatelessWidget {
  const PendingAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Appointments"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('status', isEqualTo: 'Pending') // Initially stored pending status
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No pending appointments found."));
            }

            // Convert Firestore data and dynamically determine the status
            final pendingAppointments = snapshot.data!.docs.map((doc) {
              final appointment = doc.data() as Map<String, dynamic>;
              final dateStr = appointment['date'] ?? '';
              final timeSlot = appointment['timeSlot'] ?? 'N/A';
              final userId = appointment['userId'] ?? '';
              final isConsulted = appointment['isConsulted'] ?? false;

              DateTime appointmentDate = DateTime.tryParse(dateStr) ?? DateTime(2000);
              DateTime today = DateTime.now();

              // Determine dynamic status
              String dynamicStatus;
              if (isConsulted) {
                dynamicStatus = "Visited";
              } else if (appointmentDate.isBefore(today)) {
                dynamicStatus = "Rejected";
              } else {
                dynamicStatus = "Pending";
              }

              return {
                'date': dateStr,
                'timeSlot': timeSlot,
                'status': dynamicStatus,
                'userId': userId,
              };
            }).toList();

            if (pendingAppointments.isEmpty) {
              return const Center(child: Text("No pending appointments found."));
            }

            return ListView.builder(
              itemCount: pendingAppointments.length,
              itemBuilder: (context, index) {
                final appointment = pendingAppointments[index];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('patients')
                      .doc(appointment['userId'])
                      .get(),
                  builder: (context, patientSnapshot) {
                    if (patientSnapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        title: Text("Loading..."),
                        subtitle: Text("Fetching patient data"),
                      );
                    }

                    if (!patientSnapshot.hasData || !patientSnapshot.data!.exists) {
                      return const ListTile(
                        title: Text("Unknown Patient"),
                        subtitle: Text("Patient data not found"),
                      );
                    }

                    final patientData = patientSnapshot.data!.data() as Map<String, dynamic>;
                    final patientName = patientData['first_name'] ?? 'Unknown';

                    return AppointmentCard(
                      patientName: patientName,
                      date: appointment['date'],
                      time: appointment['timeSlot'],
                      status: appointment['status'], // Passing dynamically determined status
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Appointment Card UI Component
class AppointmentCard extends StatelessWidget {
  final String patientName;
  final String date;
  final String time;
  final String status;

  const AppointmentCard({
    super.key,
    required this.patientName,
    required this.date,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $patientName",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Date: $date"),
            Text("Time: $time"),
            Text("Status: $status",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: status == "Rejected"
                        ? Colors.red
                        : status == "Visited"
                            ? Colors.green
                            : Colors.orange)),
          ],
        ),
      ),
    );
  }
}
