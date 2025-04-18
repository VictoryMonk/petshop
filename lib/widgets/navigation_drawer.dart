import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/admin_dashboard.dart';
import '../screens/main_dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../models/user.dart';
import '../utils/session_manager.dart';
import '../screens/petshop_services_screen.dart';
import '../screens/my_bookings_screen.dart';

class AppDrawer extends StatelessWidget {
  final User? user;

  const AppDrawer({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Text(
              'Pet Care App',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
              );
            },
          ),
          if (user?.role == 'admin') ...[
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Dashboard'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AdminDashboard(user: user)),
                );
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Main Dashboard'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MainDashboardScreen(user: user)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Petshop Services'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PetshopServicesScreen(
                    user: user!,
                    isAdmin: user?.role == 'admin',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('My Bookings'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MyBookingsScreen(
                    user: user!,
                    isAdmin: user?.role == 'admin',
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await SessionManager.clearUserId();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
