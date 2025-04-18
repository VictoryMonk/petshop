import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/pet_service.dart';
import '../db/database_helper.dart';
import 'health_records_screen.dart';

class PetProfileScreen extends StatefulWidget {
  final User user;

  const PetProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  late Future<List<Pet>> _petsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPets();
  }

  void _refreshPets() {
    _petsFuture = PetService(DatabaseHelper.instance).getPetsByOwner(widget.user.id!);
    setState(() {});
  }

  void _showPetForm({Pet? pet}) {
    String? imagePath = pet?.imagePath;
    final ImagePicker _picker = ImagePicker();
    final nameController = TextEditingController(text: pet?.name ?? '');
    final speciesController = TextEditingController(text: pet?.species ?? '');
    final breedController = TextEditingController(text: pet?.breed ?? '');
    final ageController = TextEditingController(text: pet?.age?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(pet == null ? 'Add Pet' : 'Edit Pet'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: speciesController,
                  decoration: InputDecoration(labelText: 'Species'),
                ),
                TextField(
                  controller: breedController,
                  decoration: InputDecoration(labelText: 'Breed'),
                ),
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      imagePath = pickedFile.path;
                      // Refresh dialog to show image
                      (context as Element).markNeedsBuild();
                    }
                  },
                  child: imagePath != null
                      ? Image.file(File(imagePath!), width: 100, height: 100, fit: BoxFit.cover)
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.camera_alt, size: 40, color: Colors.grey[700]),
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final species = speciesController.text.trim();
                final breed = breedController.text.trim();
                final age = int.tryParse(ageController.text.trim()) ?? 0;

                if (name.isEmpty || species.isEmpty || breed.isEmpty || age <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields correctly')),
                  );
                  return;
                }

                if (pet == null) {
                  // Add new pet
                  await PetService(DatabaseHelper.instance).createPet(
                    Pet(
                      name: name,
                      species: species,
                      breed: breed,
                      age: age,
                      ownerId: widget.user.id!,
                    ),
                  );
                } else {
                  // Update existing pet
                  await PetService(DatabaseHelper.instance).updatePet(
                    Pet(
                      id: pet.id,
                      name: name,
                      species: species,
                      breed: breed,
                      age: age,
                      ownerId: widget.user.id!,
                      imagePath: imagePath,
                    ),
                  );
                }

                Navigator.pop(context);
                _refreshPets();
              },
              child: Text(pet == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _deletePet(Pet pet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Pet'),
        content: Text('Are you sure you want to delete ${pet.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await PetService(DatabaseHelper.instance).deletePet(pet.id!);
      _refreshPets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Pets')),
      body: FutureBuilder<List<Pet>>(
        future: _petsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading pets'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pets found. Tap + to add one.'));
          }

          final pets = snapshot.data!;

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return Card(
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.assignment_turned_in, color: Colors.teal),
                        tooltip: 'Health Records',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HealthRecordsScreen(pet: pet),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showPetForm(pet: pet),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePet(pet),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPetForm(),
        child: Icon(Icons.add),
        tooltip: 'Add Pet',
      ),
    );
  }
}
