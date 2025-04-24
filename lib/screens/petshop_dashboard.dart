import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/navigation_drawer.dart';
import '../models/user.dart';
import 'admin_bookings_screen.dart';
import 'petshop_dashboard_card.dart';
import 'pet_supplies_screen.dart';
import 'order_history_screen.dart';
import 'manage_address_screen.dart';
import 'book_pet_services_screen.dart';
import 'my_bookings_screen.dart';

class PetshopDashboard extends StatelessWidget {
  final User? user;
  const PetshopDashboard({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back/swipe from minimizing
      child: Scaffold(
        appBar: CustomAppBar(title: 'Petshop Dashboard'),
        drawer: AppDrawer(user: user),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: user?.role == 'admin'
                ? [
              DashboardCard(
                icon: Icons.shopping_bag,
                label: 'Product Management',
                onTap: () {},
              ),
              DashboardCard(
                icon: Icons.receipt_long,
                label: 'Order Management',
                onTap: () {},
              ),
              DashboardCard(
                icon: Icons.inventory,
                label: 'Inventory Overview',
                onTap: () {},
              ),
              DashboardCard(
                icon: Icons.people,
                label: 'Customer Management',
                onTap: () {},
              ),
              DashboardCard(
                icon: Icons.local_offer,
                label: 'Promotions & Discounts',
                onTap: () {},
              ),
              DashboardCard(
                icon: Icons.bar_chart,
                label: 'Analytics & Reports',
                onTap: () {},
              ),
              DashboardCard(
                icon: Icons.notifications,
                label: 'Notifications',
                onTap: () {},
              ),
              DashboardCard(
                icon: Icons.settings,
                label: 'Shop Profile & Settings',
                onTap: () {},
              ),
            ]
                : [
              DashboardCard(
                icon: Icons.store,
                label: 'Shop Pet Supplies',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PetSuppliesScreen()),
                  );
                },
              ),
              DashboardCard(
                icon: Icons.medical_services,
                label: 'Book Pet Services',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookPetServicesScreen(),
                    ),
                  );
                },
              ),
              DashboardCard(
                icon: Icons.shopping_cart,
                label: 'My Orders',
                onTap: () async {
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderHistoryScreen(userId: user!.id!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please log in to view your orders.')),
                    );
                  }
                },
              ),
              DashboardCard(
                icon: Icons.calendar_today,
                label: 'My Bookings',
                onTap: () {
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyBookingsScreen(user: user!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please log in to view your bookings.')),
                    );
                  }
                },
              ),
              DashboardCard(
                icon: Icons.local_offer,
                label: 'Offers & Discounts',
                onTap: () {},
              ),
              DashboardCard(
                icon: Icons.person,
                label: 'Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageAddressScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
