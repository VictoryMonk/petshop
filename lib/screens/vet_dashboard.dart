import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/navigation_drawer.dart';
import '../models/user.dart';

class VetDashboard extends StatelessWidget {
  final User? user;
  const VetDashboard({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Vet Dashboard'),
      drawer: AppDrawer(user: user),
      body: Center(child: Text('Vet Dashboard Screen')),
    );
  }
}
