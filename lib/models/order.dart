import 'dart:convert';
import 'cart_item.dart';
import 'product.dart';

class Order {
  final int? id;
  final int userId;
  final List<CartItem> items;
  final double total;
  final DateTime date;
  final String address;

  Order({this.id, required this.userId, required this.items, required this.total, required this.date, required this.address});

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'items': jsonEncode(items.map((e) => {
          'product': e.product.toMap(),
          'quantity': e.quantity,
        }).toList()),
        'total': total,
        'date': date.toIso8601String(),
        'address': address,
      };

  static Order fromMap(Map<String, dynamic> map) => Order(
        id: map['id'],
        userId: map['userId'],
        items: (jsonDecode(map['items']) as List)
          .map((item) => CartItem(
            product: Product.fromMap(item['product']),
            quantity: item['quantity'],
          )).toList(),
        total: map['total'],
        date: DateTime.parse(map['date']),
        address: map['address'] ?? '',
      );
}
