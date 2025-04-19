import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../models/cart_item.dart';
import 'cart_screen.dart';
import '../utils/cart_storage.dart';
import '../services/order_service.dart';
import '../models/order.dart';
import '../utils/session_manager.dart';

class PetSuppliesScreen extends StatefulWidget {
  const PetSuppliesScreen({Key? key}) : super(key: key);

  @override
  State<PetSuppliesScreen> createState() => _PetSuppliesScreenState();
}

class _PetSuppliesScreenState extends State<PetSuppliesScreen> {
  late Future<List<Product>> _productsFuture;
  final ProductService _productService = ProductService();
  List<CartItem> _cart = [];

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getAllProducts();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final loadedCart = await CartStorage.loadCart();
    setState(() {
      _cart = loadedCart;
    });
  }

  void _openCartScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          cartItems: _cart,
          onCheckout: (String address) async {
            try {
              final userId = await SessionManager.getUserId();
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User not logged in. Please login to place orders.')),
                );
                return;
              }
              if (_cart.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cart is empty.')),
                );
                return;
              }
              final total = _cart.fold<double>(0, (sum, item) => sum + item.product.price * item.quantity);
              final order = Order(
                userId: userId,
                items: List<CartItem>.from(_cart),
                total: total,
                date: DateTime.now(),
                address: address,
              );
              await OrderService().addOrder(order);
              if (Navigator.canPop(context)) Navigator.pop(context); // Close checkout screen
              setState(() {
                _cart.clear();
              });
              await CartStorage.clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checkout successful!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order failed: ${e.toString()}')),
              );
            }
          },
          onClearCart: () async {
            setState(() {
              _cart.clear();
            });
            await CartStorage.clearCart();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cart cleared.')),
            );
          },
        ),
      ),
    );
    setState(() {}); // Refresh after coming back from cart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Pet Supplies'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading products'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          final products = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text('₹${product.price.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            final existing = _cart.indexWhere((item) => item.product.id == product.id);
                            if (existing != -1) {
                              _cart[existing].quantity++;
                            } else {
                              _cart.add(CartItem(product: product));
                            }
                          });
                          await CartStorage.saveCart(_cart);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.name} added to cart!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _cart.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _openCartScreen,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.shopping_cart),
        label: Text('Cart (${_cart.fold<int>(0, (sum, item) => sum + item.quantity)})'),
      )
          : null,
    );
  }
}
