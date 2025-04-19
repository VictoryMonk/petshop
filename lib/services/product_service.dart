import '../models/product.dart';
import '../db/database_helper.dart';

class ProductService {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Product>> getAllProducts() async {
    final products = await dbHelper.fetchAllProducts();
    return products.map((map) => Product.fromMap(map)).toList();
  }

  Future<int> addProduct(Product product) async {
    return await dbHelper.createProduct(product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    return await dbHelper.updateProduct(product.toMap());
  }

  Future<int> deleteProduct(int id) async {
    return await dbHelper.deleteProduct(id);
  }
}
