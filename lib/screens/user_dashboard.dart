import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/navigation_drawer.dart';
import '../models/user.dart';

class UserDashboard extends StatelessWidget {
  final User? user;
  const UserDashboard({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'User Dashboard'),
      drawer: AppDrawer(user: user),
      body: Center(child: Text('User Dashboard Screen')),
    );
  }
}
