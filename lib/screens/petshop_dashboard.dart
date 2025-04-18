import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/navigation_drawer.dart';
import '../models/user.dart';
import 'admin_bookings_screen.dart';

class PetshopDashboard extends StatelessWidget {
  final User? user;
  const PetshopDashboard({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Petshop Dashboard'),
      drawer: AppDrawer(user: user),
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.calendar_today),
          label: Text('Manage Bookings'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminBookingsScreen(user: user!),
              ),
            );
          },
        ),
      ),
    );
  }
}
