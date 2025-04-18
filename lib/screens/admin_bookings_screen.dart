import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../models/pet.dart';
import '../models/petshop_service.dart';
import '../services/booking_service.dart';
import '../services/pet_service.dart';
import '../services/petshop_service_service.dart';
import '../db/database_helper.dart';

class AdminBookingsScreen extends StatefulWidget {
  final User user;
  const AdminBookingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  late Future<List<Booking>> _bookingsFuture;
  late PetService _petService;
  late PetshopServiceService _serviceService;

  @override
  void initState() {
    super.initState();
    _petService = PetService(DatabaseHelper.instance);
    _serviceService = PetshopServiceService(DatabaseHelper.instance);
    _refreshBookings();
  }

  void _refreshBookings() {
    _bookingsFuture = BookingService(DatabaseHelper.instance).getAllBookings();
    setState(() {});
  }

  Future<String> _getPetName(int petId) async {
    // For admin, we don't know the ownerId, so fetch all pets
    final pets = await _petService.getAllPets();
    return pets.firstWhere(
      (p) => p.id == petId,
      orElse: () => Pet(
        name: 'Unknown',
        species: 'Unknown',
        breed: 'Unknown',
        age: 0,
        ownerId: 0,
      ),
    ).name;
  }

  Future<String> _getServiceName(int serviceId) async {
    final services = await _serviceService.getAllServices();
    return services.firstWhere((s) => s.id == serviceId, orElse: () => PetshopServiceModel(name: 'Unknown', description: '', price: 0, category: '')).name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Bookings')),
      body: FutureBuilder<List<Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bookings found.'));
          }
          final bookings = snapshot.data!;
          return ListView(
            children: bookings.map((b) => _buildBookingTile(b)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildBookingTile(Booking booking) {
    return FutureBuilder<List<String>>(
      future: Future.wait([
        _getPetName(booking.petId),
        _getServiceName(booking.serviceId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return ListTile(title: Text('Loading...'));
        final petName = snapshot.data![0];
        final serviceName = snapshot.data![1];
        final statusColor = _statusColor(booking.status);
        final canApprove = booking.status == 'Pending';
        final canDecline = booking.status == 'Pending' || booking.status == 'Confirmed';
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Row(
              children: [
                Expanded(child: Text(serviceName)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text('Pet: $petName\nDate: ${booking.date.toLocal().toString().substring(0, 16)}'),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canApprove)
                  IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    tooltip: 'Approve',
                    onPressed: () => _updateStatus(booking, 'Confirmed'),
                  ),
                if (canDecline)
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    tooltip: 'Decline',
                    onPressed: () => _updateStatus(booking, 'Cancelled'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _updateStatus(Booking booking, String newStatus) async {
    await BookingService(DatabaseHelper.instance).updateBookingStatus(booking.id!, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking updated.')));
    _refreshBookings();
  }
}
