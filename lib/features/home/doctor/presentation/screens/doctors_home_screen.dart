import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorName = ref.watch(doctorNameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medisafe"),
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
              child: ListView(
                children: const [
                  // Appointment card example
                  AppointmentCard(
                    name: 'John Doe',
                    time: '10:00 AM - 11:00 AM',
                    status: 'Pending',
                    payment: 'Success',
                    details: 'Routine check-up',
                  ),
                ],
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
