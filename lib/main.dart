import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db/database_helper.dart';
import 'screens/login_screen.dart';
import 'services/user_service.dart';
import 'services/pet_service.dart';
import 'services/disease_prediction_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initializeDB();
  runApp(PetCareApp());
}

class PetCareApp extends StatelessWidget {
  const PetCareApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseHelper>.value(value: DatabaseHelper.instance),
        Provider<UserService>(create: (_) => UserService(DatabaseHelper.instance)),
        Provider<PetService>(create: (_) => PetService(DatabaseHelper.instance)),
        Provider<DiseasePredictionService>(create: (_) => DiseasePredictionService()),
      ],
      child: MaterialApp(
        title: 'Pet Care App',
        theme: ThemeData(primarySwatch: Colors.teal),
        home: LoginScreen(),
      ),
    );
  }
}

/// Alias for testing
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PetCareApp();
  }
}
