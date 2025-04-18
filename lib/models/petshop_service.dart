class PetshopServiceModel {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String category; // e.g., 'Grooming', 'Boarding', etc.

  PetshopServiceModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
    };
  }

  factory PetshopServiceModel.fromMap(Map<String, dynamic> map) {
    return PetshopServiceModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'] is int ? (map['price'] as int).toDouble() : map['price'],
      category: map['category'],
    );
  }
}
