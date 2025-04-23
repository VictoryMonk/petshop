import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/navigation_drawer.dart';
import '../models/user.dart';
import 'vet_appointments_screen.dart';

class VetDashboard extends StatelessWidget {
  final User? user;
  const VetDashboard({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Vet Dashboard'),
      drawer: AppDrawer(user: user),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: const Text('View Appointments'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VetAppointmentsScreen()),
            );
          },
        ),
      ),
    );
  }
}
