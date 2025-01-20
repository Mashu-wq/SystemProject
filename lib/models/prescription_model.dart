class Prescription {
  final String prescriptionId;
  final String doctorId;
  final String patientId;
  final DateTime createdAt;
  final List<Medicine> medicines;

  Prescription({
    required this.prescriptionId,
    required this.doctorId,
    required this.patientId,
    required this.createdAt,
    required this.medicines,
  });

  Map<String, dynamic> toMap() {
    return {
      'prescriptionId': prescriptionId,
      'doctorId': doctorId,
      'patientId': patientId,
      'createdAt': createdAt.toIso8601String(),
      'medicines': medicines.map((medicine) => medicine.toMap()).toList(),
    };
  }

  factory Prescription.fromFirestore(Map<String, dynamic> data) {
    return Prescription(
      prescriptionId: data['prescriptionId'],
      doctorId: data['doctorId'],
      patientId: data['patientId'],
      createdAt: DateTime.parse(data['createdAt']),
      medicines: (data['medicines'] as List)
          .map((medicine) => Medicine.fromMap(medicine))
          .toList(),
    );
  }
}

class Medicine {
   String name;
   String dose;
   String time;
   String instructions;

  Medicine({
    required this.name,
    required this.dose,
    required this.time,
    required this.instructions,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dose': dose,
      'time': time,
      'instructions': instructions,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> data) {
    return Medicine(
      name: data['name'],
      dose: data['dose'],
      time: data['time'],
      instructions: data['instructions'],
    );
  }
}
