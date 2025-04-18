import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import 'dart:io';
import '../widgets/navigation_drawer.dart';
import '../models/user.dart';
import '../models/pet.dart';
import '../screens/health_records_screen.dart';
import '../services/pet_service.dart';
import '../db/database_helper.dart';

class UserDashboard extends StatelessWidget {
  final User? user;
  const UserDashboard({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'User Dashboard'),
      drawer: AppDrawer(user: user),
      body: FutureBuilder<List<Pet>>(
        future: user != null ? PetService(DatabaseHelper.instance).getPetsByOwner(user!.id!) : Future.value([]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pets found.'));
          }
          final pets = snapshot.data!;
          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: (pet.imagePath != null && File(pet.imagePath!).existsSync())
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(pet.imagePath!),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.pets, size: 32, color: Colors.grey[700]),
                        ),
                  title: Text(pet.name),
                  subtitle: Text('${pet.species} • ${pet.breed} • Age: ${pet.age}'),
                  trailing: ElevatedButton.icon(
                    icon: Icon(Icons.assignment_turned_in, color: Colors.white),
                    label: Text('Health Records'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HealthRecordsScreen(pet: pet),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
