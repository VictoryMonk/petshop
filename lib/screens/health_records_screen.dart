import 'package:flutter/material.dart';
import '../models/health_record.dart';
import '../models/pet.dart';
import '../services/health_record_service.dart';
import '../db/database_helper.dart';

class HealthRecordsScreen extends StatefulWidget {
  final Pet pet;
  const HealthRecordsScreen({Key? key, required this.pet}) : super(key: key);

  @override
  _HealthRecordsScreenState createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  late Future<List<HealthRecord>> _recordsFuture;
  final _service = HealthRecordService(DatabaseHelper.instance);

  @override
  void initState() {
    super.initState();
    _refreshRecords();
  }

  void _refreshRecords() {
    _recordsFuture = _service.getHealthRecordsForPet(widget.pet.id!);
    setState(() {});
  }

  void _showRecordForm({HealthRecord? record}) {
    final typeController = TextEditingController(text: record?.type ?? '');
    final descController = TextEditingController(text: record?.description ?? '');
    DateTime selectedDate = record?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                  record == null ? 'Add Health Record' : 'Edit Health Record'
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: typeController,
                      decoration: InputDecoration(labelText: 'Type (e.g. Vaccination)'),
                    ),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(labelText: 'Description'),
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
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final type = typeController.text.trim();
                    final desc = descController.text.trim();
                    if (type.isEmpty || desc.isEmpty) return;

                    if (record == null) {
                      await _service.createHealthRecord(
                        HealthRecord(
                          petId: widget.pet.id!,
                          type: type,
                          description: desc,
                          date: selectedDate,
                        ),
                      );
                    } else {
                      await _service.updateHealthRecord(
                        HealthRecord(
                          id: record.id,
                          petId: widget.pet.id!,
                          type: type,
                          description: desc,
                          date: selectedDate,
                        ),
                      );
                    }

                    Navigator.of(context).pop();
                    _refreshRecords();
                  },
                  child: Text(record == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteRecord(HealthRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Record'),
        content: Text('Delete this health record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteHealthRecord(record.id!);
      _refreshRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Records for ${widget.pet.name}'),
      ),
      body: FutureBuilder<List<HealthRecord>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No health records. Tap + to add.'));
          }
          final records = snapshot.data!;
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                title: Text(record.type),
                subtitle: Text(
                  '${record.description}\n${record.date.toLocal().toString().split(' ')[0]}',
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showRecordForm(record: record),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteRecord(record),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRecordForm(),
        child: Icon(Icons.add),
        tooltip: 'Add Health Record',
      ),
    );
  }
}
