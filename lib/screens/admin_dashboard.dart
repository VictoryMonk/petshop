import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/navigation_drawer.dart';
import '../models/user.dart';

class AdminDashboard extends StatelessWidget {
  final User? user;
  const AdminDashboard({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user?.role != 'admin') {
      return Scaffold(
        appBar: CustomAppBar(title: 'Access Denied'),
        body: Center(child: Text('You do not have permission to access this page')),
      );
    }
    return Scaffold(
      appBar: CustomAppBar(title: 'Admin Dashboard'),
      drawer: AppDrawer(user: user),
      body: Center(child: Text('Admin Dashboard Screen')),
    );
  }
}
