// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:medisafe/models/doctor_model.dart';

// class AppointmentPage extends StatefulWidget {
//   final Doctor doctor;

//   const AppointmentPage({super.key, required this.doctor});

//   @override
//   State<AppointmentPage> createState() => _AppointmentPageState();
// }

// class _AppointmentPageState extends State<AppointmentPage> {
//   int selectedDateIndex = 0;
//   int selectedSlotIndex = -1;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Appointment"),
//         backgroundColor: Colors.purpleAccent,
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('doctors')
//             .doc(widget.doctor.id)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }

//           if (!snapshot.hasData || snapshot.data == null) {
//             return const Center(child: Text("No data available."));
//           }

//           final data = snapshot.data!.data() as Map<String, dynamic>?;
//           if (data == null || data['available_time'] == null) {
//             return const Center(child: Text("No slots available."));
//           }

//           final availableSlots = Map<String, List<String>>.from(
//             (data['available_time'] as Map<String, dynamic>).map(
//               (key, value) => MapEntry(key, List<String>.from(value)),
//             ),
//           );

//           final availableDates = availableSlots.keys.toList();

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildDateSelector(availableDates),
//                 const SizedBox(height: 16),
//                 _buildSlotSelector(availableSlots, availableDates),
//                 const SizedBox(height: 32),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: selectedSlotIndex != -1
//                         ? () => _bookAppointment(
//                               availableDates,
//                               availableSlots,
//                             )
//                         : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       disabledBackgroundColor: Colors.grey,
//                     ),
//                     child: const Text("Confirm Appointment"),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDateSelector(List<String> availableDates) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: List.generate(availableDates.length, (index) {
//         return GestureDetector(
//           onTap: () {
//             setState(() {
//               selectedDateIndex = index;
//               selectedSlotIndex = -1; // Reset slot selection
//             });
//           },
//           child: Container(
//             padding: const EdgeInsets.all(8.0),
//             decoration: BoxDecoration(
//               color: selectedDateIndex == index ? Colors.blue : Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.blue),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   availableDates[index],
//                   style: TextStyle(
//                     color:
//                         selectedDateIndex == index ? Colors.white : Colors.blue,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildSlotSelector(
//     Map<String, List<String>> availableSlots,
//     List<String> availableDates,
//   ) {
//     final slots = availableSlots[availableDates[selectedDateIndex]] ?? [];
//     return Wrap(
//       spacing: 10,
//       runSpacing: 10,
//       children: List.generate(slots.length, (index) {
//         return GestureDetector(
//           onTap: () {
//             setState(() {
//               selectedSlotIndex = index;
//             });
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: selectedSlotIndex == index ? Colors.blue : Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.blue),
//             ),
//             child: Text(
//               slots[index],
//               style: TextStyle(
//                 color: selectedSlotIndex == index ? Colors.white : Colors.blue,
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Future<void> _bookAppointment(
//     List<String> availableDates,
//     Map<String, List<String>> availableSlots,
//   ) async {
//     if (selectedSlotIndex == -1 || availableDates.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a date and time slot')),
//       );
//       return;
//     }

//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('You need to log in to book an appointment')),
//       );
//       return;
//     }

//     final selectedDate = availableDates[selectedDateIndex];
//     final selectedSlot = availableSlots[selectedDate]![selectedSlotIndex];

//     try {
//       await FirebaseFirestore.instance.collection('appointments').add({
//         'doctor_id': widget.doctor.id,
//         'patient_id': user.uid,
//         'date': selectedDate,
//         'slot': selectedSlot,
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       // Show confirmation dialog
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Appointment Confirmed"),
//           content: Text(
//               "Your appointment with Dr. ${widget.doctor.name} has been confirmed."),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to book appointment: $e')),
//       );
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:medisafe/models/doctor_model.dart';

// class AppointmentPage extends StatefulWidget {
//   final Doctor doctor;

//   const AppointmentPage({super.key, required this.doctor});

//   @override
//   State<AppointmentPage> createState() => _AppointmentPageState();
// }

// class _AppointmentPageState extends State<AppointmentPage> {
//   int selectedDateIndex = 0;
//   int selectedSlotIndex = -1;

//   List<String> availableDates = [];
//   Map<String, List<String>> availableSlots = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchAvailableSlots();
//   }

//   // Fetch available slots for the selected doctor
//   Future<void> _fetchAvailableSlots() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('doctors')
//           .doc(widget.doctor.id)
//           .get();

//       if (doc.exists) {
//         final data = doc.data();
//         if (data != null && data['available_time'] != null) {
//           final rawSlots = data['available_time'] as Map<String, dynamic>;

//           setState(() {
//             availableSlots = rawSlots.map((key, value) {
//               return MapEntry(key, List<String>.from(value as List));
//             });
//             availableDates = availableSlots.keys.toList();
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching slots: $e');
//     }
//   }

//   // Book appointment logic
//   Future<void> _bookAppointment() async {
//     if (selectedSlotIndex == -1 || availableDates.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a date and time slot')),
//       );
//       return;
//     }

//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please log in to book an appointment')),
//       );
//       return;
//     }

//     // Proceed with booking the appointment
//     final selectedDate = availableDates[selectedDateIndex];
//     final selectedSlot = availableSlots[selectedDate]?[selectedSlotIndex];

//     if (selectedSlot != null) {
//       try {
//         await FirebaseFirestore.instance.collection('appointments').add({
//           'doctor_id': widget.doctor.id,
//           'patient_id': user.uid,
//           'date': selectedDate,
//           'time_slot': selectedSlot,
//           'status': 'pending',
//           'created_at': FieldValue.serverTimestamp(),
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Appointment booked successfully')),
//         );
//         // You can navigate to a confirmation screen or back to the home page
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error booking appointment: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Book Appointment'),
//         backgroundColor: Colors.purpleAccent,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Available Dates Section
//               const Text(
//                 'Select a Date:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               availableDates.isEmpty
//                   ? const Center(child: CircularProgressIndicator())
//                   : Column(
//                       children: List.generate(availableDates.length, (index) {
//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               selectedDateIndex = index;
//                               selectedSlotIndex = -1; // Reset slot selection
//                             });
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(vertical: 5),
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: selectedDateIndex == index
//                                   ? Colors.purpleAccent
//                                   : Colors.grey[200],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               availableDates[index],
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: selectedDateIndex == index
//                                     ? Colors.white
//                                     : Colors.black,
//                               ),
//                             ),
//                           ),
//                         );
//                       }),
//                     ),
//               const SizedBox(height: 20),

//               // Available Time Slots Section
//               if (availableDates.isNotEmpty)
//                 const Text(
//                   'Select a Time Slot:',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               const SizedBox(height: 10),
//               availableDates.isEmpty ||
//                       availableSlots[availableDates[selectedDateIndex]] == null
//                   ? const Center(child: CircularProgressIndicator())
//                   : Column(
//                       children: List.generate(
//                         availableSlots[availableDates[selectedDateIndex]]!
//                             .length,
//                         (index) {
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 selectedSlotIndex = index;
//                               });
//                             },
//                             child: Container(
//                               margin: const EdgeInsets.symmetric(vertical: 5),
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: selectedSlotIndex == index
//                                     ? Colors.purpleAccent
//                                     : Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 availableSlots[
//                                     availableDates[selectedDateIndex]]![index],
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: selectedSlotIndex == index
//                                       ? Colors.white
//                                       : Colors.black,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//               const SizedBox(height: 20),

//               // Book Appointment Button
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _bookAppointment,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purpleAccent,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 40, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text('Book Appointment',
//                       style: TextStyle(fontSize: 18)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Generate the next 7 days from today
  void _generateAvailableDates() {
    availableDates = [];
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));
      availableDates.add(
        '${date.day}/${date.month}/${date.year}', // Format the date as Day/Month/Year
      );
    }
  }

  // Fetch available slots for the selected doctor from Firestore
  Future<void> _fetchAvailableSlots() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctor.id)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['available_time'] != null) {
          final rawSlots = data['available_time'] as Map<String, dynamic>;

          setState(() {
            availableSlots = rawSlots.map((key, value) {
              return MapEntry(key, List<String>.from(value as List));
            });
          });
        }
      }
    } catch (e) {
      print('Error fetching slots: $e');
    }
  }

  // Handle appointment booking
  Future<void> _bookAppointment() async {
    if (selectedSlotIndex == -1 || availableDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time slot')),
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

    // Add appointment logic to Firestore
    try {
      final selectedDate = availableDates[selectedDateIndex];
      final selectedSlot = availableSlots[selectedDate]![selectedSlotIndex];

      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'doctorId': widget.doctor.id,
        'date': selectedDate,
        'timeSlot': selectedSlot,
        'status': 'Pending', // Or 'Confirmed' based on your logic
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: $e')),
      );
    }
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
                    label: Text(availableDates[index]),
                    selected: selectedDateIndex == index,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedDateIndex = selected ? index : -1;
                        selectedSlotIndex =
                            -1; // Reset slot when date is changed
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
                    const Text(
                      'Select Time Slot:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: List.generate(
                        availableSlots[availableDates[selectedDateIndex]]
                                ?.length ??
                            0,
                        (index) {
                          return RadioListTile<int>(
                            title: Text(availableSlots[
                                availableDates[selectedDateIndex]]![index]),
                            value: index,
                            groupValue: selectedSlotIndex,
                            onChanged: (value) {
                              setState(() {
                                selectedSlotIndex = value!;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // Book appointment button
              ElevatedButton(
                onPressed: _bookAppointment,
                child: const Text('Book Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
