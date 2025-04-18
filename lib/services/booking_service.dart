import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/booking.dart';

class BookingService {
  final DatabaseHelper dbHelper;
  BookingService(this.dbHelper);

  Future<int> createBooking(Booking booking) async {
    final db = await dbHelper.database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<List<Booking>> getBookingsForUser(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query('bookings', where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC');
    return result.map((map) => Booking.fromMap(map)).toList();
  }

  Future<List<Booking>> getAllBookings() async {
    final db = await dbHelper.database;
    final result = await db.query('bookings');
    return result.map((map) => Booking.fromMap(map)).toList();
  }

  Future<int> updateBooking(Booking booking) async {
    final db = await dbHelper.database;
    return await db.update('bookings', booking.toMap(), where: 'id = ?', whereArgs: [booking.id]);
  }

  Future<int> updateBookingStatus(int id, String status) async {
    final db = await dbHelper.database;
    return await db.update('bookings', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteBooking(int id) async {
    final db = await dbHelper.database;
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }
}
