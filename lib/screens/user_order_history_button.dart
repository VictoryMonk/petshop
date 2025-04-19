import 'package:flutter/material.dart';
import '../utils/session_manager.dart';
import 'order_history_screen.dart';

class UserOrderHistoryButton extends StatelessWidget {
  const UserOrderHistoryButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.teal),
      title: const Text('My Orders'),
      onTap: () async {
        final userId = await SessionManager.getUserId();
        if (userId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderHistoryScreen(userId: userId),
            ),
          );
        }
      },
    );
  }
}
