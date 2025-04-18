import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../models/pet.dart';
import '../models/petshop_service.dart';
import '../services/booking_service.dart';
import '../services/pet_service.dart';
import '../services/petshop_service_service.dart';
import '../db/database_helper.dart';

class UserBookingsScreen extends StatefulWidget {
  final User user;
  const UserBookingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserBookingsScreen> createState() => _UserBookingsScreenState();
}

class _UserBookingsScreenState extends State<UserBookingsScreen> {
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
    _bookingsFuture = BookingService(DatabaseHelper.instance)
        .getBookingsForUser(widget.user.id!);
    setState(() {});
  }

  Future<String> _getPetName(int petId) async {
    final pets = await _petService.getPetsByOwner(widget.user.id!);
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
      appBar: AppBar(title: Text('My Bookings')),
      body: FutureBuilder<List<Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bookings found.'));
          }
          final bookings = snapshot.data!;
          final now = DateTime.now();
          final upcoming = bookings.where((b) => b.date.isAfter(now) && b.status != 'Completed').toList();
          final past = bookings.where((b) => b.date.isBefore(now) || b.status == 'Completed').toList();
          return ListView(
            children: [
              if (upcoming.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('Upcoming Bookings', style: Theme.of(context).textTheme.titleLarge),
                ),
                ...upcoming.map((b) => _buildBookingTile(b)),
              ],
              if (past.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('Past Bookings', style: Theme.of(context).textTheme.titleLarge),
                ),
                ...past.map((b) => _buildBookingTile(b)),
              ],
            ],
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
        final canCancel = booking.status == 'Pending' || booking.status == 'Confirmed';
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            onTap: () => _showBookingDetailsDialog(booking, petName, serviceName),
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
            trailing: canCancel
                ? IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    tooltip: 'Cancel Booking',
                    onPressed: () => _cancelBooking(booking),
                  )
                : null,
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

  void _cancelBooking(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
        ],
      ),
    );
    if (confirm == true) {
      await BookingService(DatabaseHelper.instance).updateBookingStatus(booking.id!, 'Cancelled');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking cancelled.')));
      _refreshBookings();
    }
  }

  void _showBookingDetailsDialog(Booking booking, String petName, String serviceName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Booking Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Service: $serviceName'),
              Text('Pet: $petName'),
              Text('Date: ${booking.date.toLocal().toString().substring(0, 16)}'),
              Text('Status: ${booking.status}'),
              // Add more details if needed
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
          ],
        );
      },
    );
  }
}
