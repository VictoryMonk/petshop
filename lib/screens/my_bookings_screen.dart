import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/petshop_service.dart';
import '../models/pet.dart';
import '../models/user.dart';
import '../services/booking_service.dart';
import '../services/petshop_service_service.dart';
import '../services/pet_service.dart';
import '../db/database_helper.dart';
import '../widgets/navigation_drawer.dart';

class MyBookingsScreen extends StatefulWidget {
  final User user;
  final bool isAdmin;
  const MyBookingsScreen({Key? key, required this.user, this.isAdmin = false}) : super(key: key);

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late Future<List<Booking>> _bookingsFuture;
  final _bookingService = BookingService(DatabaseHelper.instance);
  final _serviceService = PetshopServiceService(DatabaseHelper.instance);
  final _petService = PetService(DatabaseHelper.instance);

  @override
  void initState() {
    super.initState();
    _refreshBookings();
  }

  void _refreshBookings() {
    _bookingsFuture = widget.isAdmin
        ? _bookingService.getAllBookings()
        : _bookingService.getBookingsForUser(widget.user.id!);
    setState(() {});
  }

  Future<Map<String, dynamic>> _resolveBookingDetails(Booking booking) async {
    final service = await _serviceService.getAllServices().then((list) => list.firstWhere((s) => s.id == booking.serviceId));
    final pet = await _petService.getPetsByOwner(booking.userId).then((list) => list.firstWhere((p) => p.id == booking.petId));
    return {'service': service, 'pet': pet};
  }

  void _showStatusDialog(Booking booking) async {
    String status = booking.status;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Booking Status'),
          content: DropdownButtonFormField<String>(
            value: status,
            items: ['Pending', 'Confirmed', 'Completed', 'Cancelled']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) => status = val!,
            decoration: InputDecoration(labelText: 'Status'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await _bookingService.updateBooking(
                  Booking(
                    id: booking.id,
                    userId: booking.userId,
                    petId: booking.petId,
                    serviceId: booking.serviceId,
                    date: booking.date,
                    status: status,
                  ),
                );
                Navigator.pop(context);
                _refreshBookings();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Bookings')),
      drawer: AppDrawer(user: widget.user),
      body: FutureBuilder<List<Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bookings found.'));
          }
          final bookings = snapshot.data!;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return FutureBuilder<Map<String, dynamic>>(
                future: _resolveBookingDetails(booking),
                builder: (context, detailsSnap) {
                  if (!detailsSnap.hasData) {
                    return ListTile(title: Text('Loading...'));
                  }
                  final service = detailsSnap.data!['service'] as PetshopServiceModel;
                  final pet = detailsSnap.data!['pet'] as Pet;
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('${service.name} for ${pet.name}'),
                      subtitle: Text('Date: ${booking.date.toLocal().toString().split(' ')[0]}\nStatus: ${booking.status}'),
                      isThreeLine: true,
                      trailing: widget.isAdmin
                          ? IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showStatusDialog(booking),
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
