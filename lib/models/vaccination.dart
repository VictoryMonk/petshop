class Vaccination {
  final int? id;
  final int petId;
  final String vaccineName;
  final String dateAdministered;
  final String nextDueDate;

  Vaccination({this.id, required this.petId, required this.vaccineName, required this.dateAdministered, required this.nextDueDate});

  Map<String, dynamic> toMap() => {
        'id': id,
        'petId': petId,
        'vaccineName': vaccineName,
        'dateAdministered': dateAdministered,
        'nextDueDate': nextDueDate,
      };

  static Vaccination fromMap(Map<String, dynamic> map) => Vaccination(
        id: map['id'],
        petId: map['petId'],
        vaccineName: map['vaccineName'],
        dateAdministered: map['dateAdministered'],
        nextDueDate: map['nextDueDate'],
      );
}
