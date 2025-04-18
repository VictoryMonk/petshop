import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../utils/session_manager.dart';

class StartupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _tryAutoLogin(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(user: snapshot.data);
        } else {
          return LoginScreen();
        }
      },
    );
  }

  Future<User?> _tryAutoLogin(BuildContext context) async {
    final userId = await SessionManager.getUserId();
    if (userId != null) {
      final userService = Provider.of<UserService>(context, listen: false);
      return await userService.getUserById(userId);
    }
    return null;
  }
}
