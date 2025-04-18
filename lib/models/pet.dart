class Pet {
  final int? id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final int ownerId;
  final String? imagePath;

  Pet({this.id, required this.name, required this.species, required this.breed, required this.age, required this.ownerId, this.imagePath});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'species': species,
        'breed': breed,
        'age': age,
        'ownerId': ownerId,
'imagePath': imagePath,
      };

  static Pet fromMap(Map<String, dynamic> map) => Pet(
        id: map['id'],
        name: map['name'],
        species: map['species'],
        breed: map['breed'],
        age: map['age'],
        ownerId: map['ownerId'],
        imagePath: map['imagePath'],
      );
}
