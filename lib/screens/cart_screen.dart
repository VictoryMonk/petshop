import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../utils/address_storage.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final Future<void> Function(String address) onCheckout;
  final VoidCallback onClearCart;

  const CartScreen({Key? key, required this.cartItems, required this.onCheckout, required this.onClearCart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total = cartItems.fold(0, (sum, item) => sum + item.product.price * item.quantity);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear Cart',
            onPressed: onClearCart,
          ),
        ],
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: const Icon(Icons.pets, size: 40, color: Colors.teal),
                        title: Text(item.product.name),
                        subtitle: Text('₹${item.product.price.toStringAsFixed(2)} x ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  item.quantity--;
                                }
                              },
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                item.quantity++;
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Total: ₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: cartItems.isEmpty
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CheckoutScreen(
                                      cartItems: cartItems,
                                      onCheckout: onCheckout,
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
