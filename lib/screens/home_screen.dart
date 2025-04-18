import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/navigation_drawer.dart';
import '../models/user.dart';
import '../services/pet_service.dart';
import '../services/booking_service.dart';
import '../db/database_helper.dart';
import 'main_dashboard_screen.dart';
import 'petshop_services_screen.dart';
import 'my_bookings_screen.dart';
import 'vet_dashboard.dart';
import 'petshop_dashboard.dart';

class HomeScreen extends StatefulWidget {
  final User? user;
  const HomeScreen({Key? key, this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, int>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _refreshSummary();
  }

  void _refreshSummary() {
    _summaryFuture = getSummaryCounts(widget.user);
  }

  static Future<Map<String, int>> getSummaryCounts(User? user) async {
    if (user == null) return {'pets': 0, 'bookings': 0};
    final petCount = await PetService(DatabaseHelper.instance)
        .getPetsByOwner(user.id!)
        .then((pets) => pets.length);
    final bookingCount = await BookingService(DatabaseHelper.instance)
        .getBookingsForUser(user.id!)
        .then((b) => b.length);
    return {'pets': petCount, 'bookings': bookingCount};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Home'),
      drawer: AppDrawer(user: widget.user),
      body: FutureBuilder<Map<String, int>>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          final petsCount = snapshot.data?['pets'] ?? 0;
          final bookingsCount = snapshot.data?['bookings'] ?? 0;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 0),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.pets, size: 40, color: Colors.teal.shade700),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Welcome, ${widget.user?.name ?? 'Guest'}!',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    children: [
                      HomeCard(
                        icon: Icons.pets,
                        label: 'My Pets',
                        color: Colors.orange,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MainDashboardScreen(user: widget.user),
                            ),
                          );
                          setState(_refreshSummary);
                        },
                      ),
                      HomeCard(
                        icon: Icons.assignment_turned_in,
                        label: 'Health Records',
                        color: Colors.blue,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MainDashboardScreen(user: widget.user),
                            ),
                          );
                          setState(_refreshSummary);
                        },
                      ),
                      HomeCard(
                        icon: Icons.store,
                        label: 'Petshop Services',
                        color: Colors.teal,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PetshopServicesScreen(
                                user: widget.user!,
                                isAdmin: widget.user?.role == 'admin',
                              ),
                            ),
                          );
                          setState(_refreshSummary);
                        },
                      ),
                      HomeCard(
                        icon: Icons.assignment,
                        label: 'My Bookings',
                        color: Colors.green,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyBookingsScreen(
                                user: widget.user!,
                                isAdmin: widget.user?.role == 'admin',
                              ),
                            ),
                          );
                          setState(_refreshSummary);
                        },
                      ),
                      HomeCard(
                        icon: Icons.medical_services,
                        label: 'Vet Dashboard',
                        color: Colors.deepPurple,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VetDashboard(user: widget.user),
                            ),
                          );
                        },
                      ),
                      HomeCard(
                        icon: Icons.business,
                        label: 'Petshop Dashboard',
                        color: Colors.brown,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PetshopDashboard(user: widget.user),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('Summary', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.teal.shade50,
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Column(
                              children: [
                                const Text('Pets', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('$petsCount', style: const TextStyle(fontSize: 22)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          color: Colors.teal.shade50,
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Column(
                              children: [
                                const Text('Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('$bookingsCount', style: const TextStyle(fontSize: 22)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.user?.role == 'admin') ...[
                    const SizedBox(height: 20),
                    Text('Admin Stats', style: Theme.of(context).textTheme.titleLarge),
                    // Add more admin-specific widgets here
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Reusable card for HomeScreen shortcuts
class HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const HomeCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
