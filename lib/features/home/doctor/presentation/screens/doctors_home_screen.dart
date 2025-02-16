import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:medisafe/features/home/patient/presentation/screens/patient_profile_consultancy.dart';
import 'package:uuid/uuid.dart'; // For generating unique room IDs

import 'package:medisafe/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorName = ref.watch(doctorNameProvider);
    final String doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final String today = DateTime.now().toIso8601String().substring(0, 10);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            doctorName.when(
              data: (name) => Text(
                "Hello, Dr. $name",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text("Error loading doctor name"),
            ),
            const SizedBox(height: 20),
            const DigitalClock(),
            const Text(
              "Today's Appointments",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('appointments')
                    .where('doctorId', isEqualTo: doctorId)
                    .where('date', isEqualTo: today)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No appointments for today.'));
                  }

                  final appointments = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      final userId = appointment['userId'];
                      final data = appointment.data() as Map<String, dynamic>;

                      // Ensure roomId exists
                      String roomId = data['roomId'] ?? const Uuid().v4();
                      if (!data.containsKey('roomId')) {
                        FirebaseFirestore.instance
                            .collection('appointments')
                            .doc(appointment.id)
                            .update({'roomId': roomId});
                        debugPrint('Generated new roomId: $roomId for appointment ${appointment.id}');
                      }

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('patients')
                            .doc(userId)
                            .get(),
                        builder: (context, patientSnapshot) {
                          if (patientSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const ListTile(
                              title: Text("Loading..."),
                              subtitle: Text("Fetching patient data"),
                            );
                          }

                          if (!patientSnapshot.hasData ||
                              !patientSnapshot.data!.exists) {
                            return const ListTile(
                              title: Text("Unknown Patient"),
                              subtitle: Text("Patient data not found"),
                            );
                          }

                          final patientData = patientSnapshot.data!.data() as Map<String, dynamic>;
                          final patientName = patientData['first_name'] ?? 'Unknown';
                          final contactNumber = patientData['contact_number'] ?? 'N/A';

                          return AppointmentCard(
                            patientName: patientName,
                            time: data['timeSlot'] ?? 'N/A',
                            status: data['status'] ?? 'Pending',
                            contactNumber: contactNumber,
                            patientId: userId, // Pass userId as patientId
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DigitalClock extends StatefulWidget {
  const DigitalClock({super.key});

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  late Stream<DateTime> _clockStream;

  @override
  void initState() {
    super.initState();
    _clockStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _clockStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final currentTime = snapshot.data!;
          final timeFormatted = DateFormat('h:mm:ss a').format(currentTime);

          return Center(
            child: Text(
              timeFormatted,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String patientName;
  final String time;
  final String status;
  final String contactNumber;
  final String patientId; // Add patientId

  const AppointmentCard({
    super.key,
    required this.patientName,
    required this.time,
    required this.status,
    required this.contactNumber,
    required this.patientId, // Include patientId in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( 
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientProfileForConsultancy(patientId: patientId),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: $patientName",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Contact: $contactNumber"),
              Text("Time: $time"),
              Text("Status: $status",
                  style: TextStyle(
                    color: status == "Visited" ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
