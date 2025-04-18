import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/admin_dashboard.dart';
import '../screens/vet_dashboard.dart';
import '../screens/user_dashboard.dart';
import '../screens/petshop_dashboard.dart';

class AppNavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Text('Pet Care App', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen(user: null)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin Dashboard'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminDashboard()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('Vet Dashboard'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => VetDashboard()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('User Dashboard'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => UserDashboard()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Petshop Dashboard'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PetshopDashboard()),
            ),
          ),
        ],
      ),
    );
  }
}
