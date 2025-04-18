class Complaint {
  final int? id;
  final int userId;
  final int petId;
  final String description;
  final String dateFiled;

  Complaint({this.id, required this.userId, required this.petId, required this.description, required this.dateFiled});

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'petId': petId,
        'description': description,
        'dateFiled': dateFiled,
      };

  static Complaint fromMap(Map<String, dynamic> map) => Complaint(
        id: map['id'],
        userId: map['userId'],
        petId: map['petId'],
        description: map['description'],
        dateFiled: map['dateFiled'],
      );
}
