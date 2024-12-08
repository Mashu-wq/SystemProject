import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  // Get the current user ID

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: userId.isEmpty
          ? const Center(
              child: Text(
                'Please log in to view your appointments.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              // Listen to the appointments collection for the current user
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('userId', isEqualTo: userId)
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
                  return const Center(child: Text('No appointments found.'));
                }

                // Map Firestore documents to appointment widgets
                final appointments = snapshot.data!.docs;

                // Sort appointments by date in ascending order (handling possible nulls)
                appointments.sort((a, b) {
                  final dateA = _parseDate(a['date']);
                  final dateB = _parseDate(b['date']);
                  if (dateA == null || dateB == null) return 0;
                  return dateA.compareTo(dateB);
                });

                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final data = appointment.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          'Dr. ${data['doctorName'] ?? 'Unknown'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${data['date'] ?? 'N/A'}'),
                            Text('Time: ${data['timeSlot'] ?? 'N/A'}'),
                            Text('Status: ${data['status'] ?? 'Pending'}'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Optional: Handle tap to show more details or edit
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  /// Parses the date from Firestore safely
  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return null;
    }
  }
}
