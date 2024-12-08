import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medisafe/features/home/patient/presentation/screens/appointmentsScreen.dart';
import 'package:medisafe/models/doctor_model.dart';

class AppointmentPage extends StatefulWidget {
  final Doctor doctor;

  const AppointmentPage({super.key, required this.doctor});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  int selectedDateIndex = 0;
  int selectedSlotIndex = -1;

  List<String> availableDates = [];
  Map<String, List<String>> availableSlots = {};

  // Initialize with current date
  DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _generateAvailableDates();
    _fetchAvailableSlots();
  }

  void _generateAvailableDates() {
    availableDates = [];
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));
      final formattedDate =
          '${_getWeekdayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)} ${date.year}';
      availableDates.add(formattedDate);
    }
  }

  String _getWeekdayName(int weekday) {
    const weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return weekdays[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  void _fetchAvailableSlots() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctor.id)
          .get();
      print('Fetched document for doctor: ${widget.doctor.id}');

      if (doc.exists) {
        final data = doc.data();
        print('Doctor document data: $data');

        if (data != null && data['available_time'] != null) {
          print('Available time field: ${data['available_time']}');

          if (data['available_time'] is String) {
            // If `available_time` is a String, parse it
            print('Available time is a String: ${data['available_time']}');
            final timeRange = (data['available_time'] as String).split('-');
            if (timeRange.length == 2) {
              final start = timeRange[0].trim();
              final end = timeRange[1].trim();
              final slots = _generateTimeSlots(start, end);
              print('Generated time slots: $slots');

              setState(() {
                // Assign the same slots to all 7 days
                for (final date in availableDates) {
                  availableSlots[date] = slots;
                }
              });
            }
          } else if (data['available_time'] is Map<String, dynamic>) {
            // If `available_time` is a Map, process it as such
            print('Available time is a Map: ${data['available_time']}');
            final rawSlots = data['available_time'] as Map<String, dynamic>;
            setState(() {
              availableSlots = rawSlots.map((key, value) {
                final start = value['start'] as String;
                final end = value['end'] as String;
                final slots = _generateTimeSlots(start, end);
                print('Generated time slots for $key: $slots');
                return MapEntry(key, slots);
              });

              // Ensure availableDates are aligned with the keys
              availableDates = availableSlots.keys.toList();
            });
          } else {
            print('Available time has an unexpected type.');
          }
        } else {
          print('No available_time field found in the document.');
        }
      } else {
        print('Doctor document does not exist');
      }
    } catch (e) {
      print('Error fetching slots: $e');
    }
  }

  List<String> _generateTimeSlots(String startTime, String endTime) {
    final List<String> slots = [];
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);

    if (start == null || end == null || start.isAfter(end)) return slots;

    var current = start;
    while (!current.isAfter(end)) {
      slots.add(_formatTime(current));
      current = current.add(const Duration(minutes: 30));
    }

    return slots;
  }

  DateTime? _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateTime(today.year, today.month, today.day, hour, minute);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _bookAppointment() async {
    if (selectedSlotIndex == -1 || availableDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to book an appointment')),
      );
      return;
    }

    final selectedDate = availableDates[selectedDateIndex];
    final selectedSlot = availableSlots[selectedDate]?[selectedSlotIndex];

    try {
      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'doctorId': widget.doctor.id,
        'doctorName': widget.doctor.name, // Add doctor's name for reference
        'date': selectedDate,
        'timeSlot': selectedSlot,
        'status': 'Pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully')),
      );

      // Navigate to AppointmentsScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: $e')),
      );
    }
  }

  Widget _buildSlotSelector() {
    final slots = availableSlots[availableDates[selectedDateIndex]] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Time Slot:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0, // Horizontal spacing between chips
          runSpacing: 4.0, // Vertical spacing between lines of chips
          children: List.generate(
            slots.length,
            (index) {
              return ChoiceChip(
                label: Text(slots[index]),
                selected: selectedSlotIndex == index,
                onSelected: (bool selected) {
                  setState(() {
                    selectedSlotIndex = selected ? index : -1;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display available dates as buttons
              const Text(
                'Select Date:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                children: List.generate(availableDates.length, (index) {
                  return ChoiceChip(
                    label:
                        Text(availableDates[index]), // Display formatted dates
                    selected: selectedDateIndex == index,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedDateIndex = selected ? index : -1;
                        selectedSlotIndex = -1; // Reset slot selection
                      });
                    },
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Display available time slots for selected date
              if (selectedDateIndex != -1)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const Text(
                    //   'Select Time Slot:',
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    const SizedBox(height: 10),
                    _buildSlotSelector(),

                    // Column(
                    //   children: List.generate(
                    //     availableSlots[availableDates[selectedDateIndex]]
                    //             ?.length ??
                    //         0,
                    //     (index) {
                    //       return RadioListTile<int>(
                    //         title: Text(availableSlots[
                    //             availableDates[selectedDateIndex]]![index]),
                    //         value: index,
                    //         groupValue: selectedSlotIndex,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             selectedSlotIndex = value!;
                    //           });
                    //         },
                    //       );
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              const SizedBox(height: 20),

              // Book appointment button
              ElevatedButton(
                onPressed: () => _bookAppointment(),
                child: const Text('Book Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
