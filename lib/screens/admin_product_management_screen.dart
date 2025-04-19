import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class AdminProductManagementScreen extends StatefulWidget {
  const AdminProductManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductManagementScreen> createState() => _AdminProductManagementScreenState();
}

class _AdminProductManagementScreenState extends State<AdminProductManagementScreen> {
  late Future<List<Product>> _productsFuture;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _productService.getAllProducts();
    });
  }

  void _showProductForm({Product? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final imageUrlController = TextEditingController(text: product?.imageUrl ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');
    final categoryController = TextEditingController(text: product?.category ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
                TextField(controller: imageUrlController, decoration: const InputDecoration(labelText: 'Image URL')),
                TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number),
                TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final newProduct = Product(
                  id: product?.id,
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  price: double.tryParse(priceController.text.trim()) ?? 0,
                  imageUrl: imageUrlController.text.trim(),
                  stock: int.tryParse(stockController.text.trim()) ?? 0,
                  category: categoryController.text.trim(),
                );
                if (product == null) {
                  await _productService.addProduct(newProduct);
                } else {
                  await _productService.updateProduct(newProduct);
                }
                Navigator.pop(context);
                _refreshProducts();
              },
              child: Text(product == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(Product product) async {
    await _productService.deleteProduct(product.id!);
    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading products'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products found.'));
          }
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, width: 40, height: 40, fit: BoxFit.cover)
                    : const Icon(Icons.pets, size: 40, color: Colors.teal),
                title: Text(product.name),
                subtitle: Text('₹${product.price.toStringAsFixed(2)} | Stock: ${product.stock} | ${product.category}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showProductForm(product: product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(product),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }
}
