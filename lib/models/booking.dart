class Booking {
  final int? id;
  final int userId;
  final int petId;
  final int serviceId;
  final DateTime date;
  final String status; // e.g., 'Pending', 'Confirmed', 'Completed', 'Cancelled'

  Booking({
    this.id,
    required this.userId,
    required this.petId,
    required this.serviceId,
    required this.date,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'petId': petId,
      'serviceId': serviceId,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['userId'],
      petId: map['petId'],
      serviceId: map['serviceId'],
      date: DateTime.parse(map['date']),
      status: map['status'],
    );
  }
}
