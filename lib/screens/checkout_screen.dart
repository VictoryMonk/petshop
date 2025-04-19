import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../utils/address_storage.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final Future<void> Function(String address) onCheckout;

  const CheckoutScreen({Key? key, required this.cartItems, required this.onCheckout}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final defaultAddress = await AddressStorage.getDefaultAddress();
    if (defaultAddress != null) {
      _addressController.text = defaultAddress;
    }
  }

  double get _total => widget.cartItems.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  Future<void> _handleCheckout() async {
    final address = _addressController.text.trim();
    if (address.length < 10) {
      setState(() => _errorText = 'Address must be at least 10 characters.');
      return;
    }
    setState(() { _isLoading = true; _errorText = null; });
    await widget.onCheckout(address);
    setState(() { _isLoading = false; });

    if (mounted) {
      Navigator.pop(context); // Pop CheckoutScreen
      Navigator.pop(context); // Pop CartScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Enter your delivery address',
                errorText: _errorText,
              ),
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
            ),
            const SizedBox(height: 24),
            const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: widget.cartItems.map((item) => ListTile(
                  title: Text(item.product.name),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text('₹${(item.product.price * item.quantity).toStringAsFixed(2)}'),
                )).toList(),
              ),
            ),
            Text('Total: ₹${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleCheckout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Confirm & Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
