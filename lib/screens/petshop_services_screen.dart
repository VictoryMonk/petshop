import 'package:flutter/material.dart';
import '../models/petshop_service.dart';
import '../models/user.dart';
import '../models/pet.dart';
import '../models/booking.dart';
import '../services/petshop_service_service.dart';
import '../services/booking_service.dart';
import '../services/pet_service.dart';
import '../db/database_helper.dart';
import '../widgets/navigation_drawer.dart';
import 'user_bookings_screen.dart';

class PetshopServicesScreen extends StatefulWidget {
  final User user;
  final bool isAdmin;
  const PetshopServicesScreen({Key? key, required this.user, this.isAdmin = false}) : super(key: key);

  @override
  State<PetshopServicesScreen> createState() => _PetshopServicesScreenState();
}

class _PetshopServicesScreenState extends State<PetshopServicesScreen> {
  late Future<List<PetshopServiceModel>> _servicesFuture;
  final _serviceService = PetshopServiceService(DatabaseHelper.instance);

  @override
  void initState() {
    super.initState();
    _refreshServices();
  }

  void _refreshServices() {
    _servicesFuture = _serviceService.getAllServices();
    setState(() {});
  }

  void _showServiceForm({PetshopServiceModel? service}) {
    final nameController = TextEditingController(text: service?.name ?? '');
    final descController = TextEditingController(text: service?.description ?? '');
    final priceController = TextEditingController(text: service?.price.toString() ?? '');
    final categoryController = TextEditingController(text: service?.category ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(service == null ? 'Add Service' : 'Edit Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
                TextField(controller: descController, decoration: InputDecoration(labelText: 'Description')),
                TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
                TextField(controller: categoryController, decoration: InputDecoration(labelText: 'Category')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final desc = descController.text.trim();
                final price = double.tryParse(priceController.text.trim()) ?? 0;
                final category = categoryController.text.trim();
                if (name.isEmpty || desc.isEmpty || price <= 0 || category.isEmpty) return;
                if (service == null) {
                  await _serviceService.createService(PetshopServiceModel(
                    name: name,
                    description: desc,
                    price: price,
                    category: category,
                  ));
                } else {
                  await _serviceService.updateService(PetshopServiceModel(
                    id: service.id,
                    name: name,
                    description: desc,
                    price: price,
                    category: category,
                  ));
                }
                Navigator.pop(context);
                _refreshServices();
              },
              child: Text(service == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteService(PetshopServiceModel service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Service'),
        content: Text('Delete ${service.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _serviceService.deleteService(service.id!);
      _refreshServices();
    }
  }

  void _showBookingDialog(PetshopServiceModel service) async {
    final pets = await PetService(DatabaseHelper.instance).getPetsByOwner(widget.user.id!);
    Pet? selectedPet;
    DateTime selectedDate = DateTime.now();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Book ${service.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Pet>(
                    value: selectedPet,
                    items: pets.map((pet) => DropdownMenuItem(
                      value: pet,
                      child: Text(pet.name),
                    )).toList(),
                    onChanged: (pet) => setState(() => selectedPet = pet),
                    decoration: InputDecoration(labelText: 'Select Pet'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => selectedDate = picked);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
                ElevatedButton(
                  onPressed: selectedPet == null ? null : () async {
                    await BookingService(DatabaseHelper.instance).createBooking(
                      Booking(
                        userId: widget.user.id!,
                        petId: selectedPet!.id!,
                        serviceId: service.id!,
                        date: selectedDate,
                        status: 'Pending',
                      ),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Booking requested!')),
                    );
                  },
                  child: Text('Book'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Petshop Services')),
      drawer: AppDrawer(user: widget.user),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
        onPressed: () => _showServiceForm(),
        child: Icon(Icons.add),
        tooltip: 'Add Service',
      )
          : null,
      body: Column(
        children: [
          if (!widget.isAdmin)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.history),
                  label: Text('My Bookings'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserBookingsScreen(user: widget.user),
                      ),
                    );
                  },
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<PetshopServiceModel>>(
              future: _servicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No services found.'));
                }
                final services = snapshot.data!;
                return ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(service.name),
                        subtitle: Text('${service.category} • ₹${service.price}\n${service.description}'),
                        isThreeLine: true,
                        trailing: widget.isAdmin
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showServiceForm(service: service),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteService(service),
                            ),
                          ],
                        )
                            : ElevatedButton(
                          onPressed: () => _showBookingDialog(service),
                          child: Text('Book'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
