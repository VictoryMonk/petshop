import 'package:flutter/material.dart';
import '../models/user.dart';
import 'user_dashboard.dart';
import 'vet_dashboard.dart';
import 'petshop_dashboard.dart';
import 'pet_profile_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  final User? user;
  const MainDashboardScreen({Key? key, this.user}) : super(key: key);

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      UserDashboard(user: widget.user),
      VetDashboard(user: widget.user),
      PetshopDashboard(user: widget.user),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.pets),
            tooltip: 'My Pets',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PetProfileScreen(user: widget.user!),
                ),
              );
            },
          ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Vet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Petshop',
          ),
        ],
      ),
    );
  }
}
