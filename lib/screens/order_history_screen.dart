import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../models/cart_item.dart';

class OrderHistoryScreen extends StatefulWidget {
  final int userId;
  const OrderHistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<Order>> _ordersFuture;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderService.getOrdersForUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }
          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text('Order #${order.id} - ₹${order.total.toStringAsFixed(2)}'),
                  subtitle: Text('${order.date.toLocal()}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: Colors.teal),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Delivery Address: ${order.address}', style: const TextStyle(fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                    ...order.items.map((item) => ListTile(
                      title: Text(item.product.name),
                      subtitle: Text('Qty: ${item.quantity}'),
                      trailing: Text('₹${(item.product.price * item.quantity).toStringAsFixed(2)}'),
                    )),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
