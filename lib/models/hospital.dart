class Hospital {
  final int? id;
  final String name;
  final String address;
  final String contactNumber;

  Hospital({this.id, required this.name, required this.address, required this.contactNumber});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'contactNumber': contactNumber,
      };

  static Hospital fromMap(Map<String, dynamic> map) => Hospital(
        id: map['id'],
        name: map['name'],
        address: map['address'],
        contactNumber: map['contactNumber'],
      );
}
