import '../db/database_helper.dart';
import '../models/order.dart';

class OrderService {
  final dbHelper = DatabaseHelper.instance;

  Future<int> addOrder(Order order) async {
    return await dbHelper.createOrder(order.toMap());
  }

  Future<List<Order>> getOrdersForUser(int userId) async {
    final orders = await dbHelper.fetchOrdersForUser(userId);
    return orders.map((map) => Order.fromMap(map)).toList();
  }

  Future<List<Order>> getAllOrders() async {
    final orders = await dbHelper.fetchAllOrders();
    return orders.map((map) => Order.fromMap(map)).toList();
  }
}
