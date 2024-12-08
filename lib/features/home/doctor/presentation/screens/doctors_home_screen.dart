import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medisafe/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorName = ref.watch(doctorNameProvider);
    final String doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Get today's date in a consistent format
    final String today = DateTime.now().toIso8601String().substring(0, 10);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            doctorName.when(
              data: (name) => Text(
                "Hello, Dr. $name",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => const Text("Error loading doctor name"),
            ),
            const SizedBox(height: 20),
            // Search Section
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Patient',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Today's Appointments Section
            const Text(
              "Today's Appointments",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('appointments')
                    .where('doctorId',
                        isEqualTo: doctorId) // Filter by doctor ID
                    .where('date', isEqualTo: today) // Filter by today's date
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    debugPrint('Firestore error: ${snapshot.error}');
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    debugPrint(
                        'No appointments found for doctorId: $doctorId and date: $today');
                    return const Center(
                        child: Text('No appointments for today.'));
                  }

                  final appointments = snapshot.data!.docs;
                  debugPrint(
                      'Fetched appointments: ${appointments.map((e) => e.data())}');

                  return ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment =
                          appointments[index].data() as Map<String, dynamic>;

                      return AppointmentCard(
                        name: appointment['patientName'] ?? 'Unknown',
                        time: appointment['timeSlot'] ?? 'N/A',
                        status: appointment['status'] ?? 'Pending',
                        payment: appointment['paymentStatus'] ?? 'N/A',
                        details:
                            appointment['details'] ?? 'No details provided',
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

class AppointmentCard extends StatelessWidget {
  final String name;
  final String time;
  final String status;
  final String payment;
  final String details;

  const AppointmentCard({
    super.key,
    required this.name,
    required this.time,
    required this.status,
    required this.payment,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $name",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Time: $time"),
            Text("Status: $status"),
            Text("Payment: $payment"),
            Text("Details: $details"),
          ],
        ),
      ),
    );
  }
}
