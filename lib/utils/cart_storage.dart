import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartStorage {
  static const String _cartKey = 'user_cart';

  static Future<void> saveCart(List<CartItem> cart) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(cart.map((item) => {
      'product': item.product.toMap(),
      'quantity': item.quantity,
    }).toList());
    await prefs.setString(_cartKey, cartJson);
  }

  static Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson == null) return [];
    final List<dynamic> decoded = jsonDecode(cartJson);
    return decoded.map((item) => CartItem(
      product: Product.fromMap(item['product']),
      quantity: item['quantity'],
    )).toList();
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
