class HealthRecord {
  final int? id;
  final int petId;
  final String type; // e.g., 'Vaccination', 'Vet Visit', 'Medication', etc.
  final String description;
  final DateTime date;

  HealthRecord({
    this.id,
    required this.petId,
    required this.type,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      petId: map['petId'],
      type: map['type'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }
}
