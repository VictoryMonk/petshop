import 'package:shared_preferences/shared_preferences.dart';

class AddressStorage {
  static const String _defaultAddressKey = 'default_address';

  static Future<void> saveDefaultAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultAddressKey, address);
  }

  static Future<String?> getDefaultAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultAddressKey);
  }

  static Future<void> clearDefaultAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_defaultAddressKey);
  }
}
