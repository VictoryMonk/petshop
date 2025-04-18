class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String role;

  User({this.id, required this.name, required this.email, required this.password, required this.role});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      };

  static User fromMap(Map<String, dynamic> map) => User(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        password: map['password'],
        role: map['role'],
      );
}
