class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final String category;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.category,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'stock': stock,
        'category': category,
      };

  static Product fromMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        price: map['price'],
        imageUrl: map['imageUrl'],
        stock: map['stock'],
        category: map['category'],
      );
}
