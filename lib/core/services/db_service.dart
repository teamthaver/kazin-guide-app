import 'dart:convert';
import 'package:kazin_guide_app/models/tour_file_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  static final DbService instance = DbService._init();
  static Database? _database;

  DbService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kazin_tour_guide.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tour_files (
        arrival_id INTEGER PRIMARY KEY,
        enquiry_id INTEGER,
        enquiry_no TEXT,
        lead_name TEXT,
        lead_contact TEXT,
        status TEXT,
        number_persons INTEGER,
        check_in_date TEXT,
        check_out_date TEXT,
        number_of_nights TEXT,
        driver_name TEXT,
        driver_phone TEXT,
        vehicle_name TEXT,
        vehicle_type TEXT,
        vehicle_capacity INTEGER,
        hotel_name TEXT,
        hotel_city TEXT,
        full_json_blob TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE itinerary_steps (
        id INTEGER PRIMARY KEY,
        arrival_id INTEGER,
        date TEXT,
        time TEXT,
        title TEXT,
        content TEXT,
        remarks TEXT,
        is_completed INTEGER,
        FOREIGN KEY (arrival_id) REFERENCES tour_files (arrival_id) ON DELETE CASCADE
      )
    ''');

    await _createQueueTable(db);
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createQueueTable(db);
    }
  }

  Future<void> _createQueueTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action_type TEXT NOT NULL,
        payload TEXT NOT NULL,
        image_paths TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // --- Sync Queue CRUD Methods ---
  Future<int> queueOfflineAction({
    required String actionType,
    required Map<String, dynamic> payload,
    List<String> imagePaths = const [],
  }) async {
    final db = await database;
    return await db.insert('sync_queue', {
      'action_type': actionType,
      'payload': jsonEncode(payload),
      'image_paths': jsonEncode(imagePaths),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> clearActiveTourFile() async {
    final db = await database;
    await db.delete('tour_files'); // aapke table ka jo bhi exact name ho
  }

  Future<List<Map<String, dynamic>>> getPendingSyncActions() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'id ASC');
  }

  Future<void> removeQueueAction(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  // --- Tour Files & Itinerary Methods ---
  Future<void> saveTourFile(TourFileModel tourFile) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      await txn.insert('tour_files', {
        'arrival_id': tourFile.arrivalId,
        'enquiry_id': tourFile.enquiryId,
        'enquiry_no': tourFile.enquiryNo,
        'lead_name': tourFile.leadName,
        'lead_contact': tourFile.leadContact,
        'status': tourFile.status,
        'number_persons': tourFile.numberPersons,
        'check_in_date': tourFile.checkInDate,
        'check_out_date': tourFile.checkOutDate,
        'number_of_nights': tourFile.numberOfNights,
        'driver_name': tourFile.driver?.name ?? '',
        'driver_phone': tourFile.driver?.phone ?? '',
        'vehicle_name': tourFile.transport?.vehicleName ?? '',
        'vehicle_type': tourFile.transport?.vehicleType ?? '',
        'vehicle_capacity': tourFile.transport?.capacity ?? 0,
        'hotel_name': tourFile.hotel?.hotelName ?? '',
        'hotel_city': tourFile.hotel?.city ?? '',
        'full_json_blob': jsonEncode(tourFile.toJson()),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.delete(
        'itinerary_steps',
        where: 'arrival_id = ?',
        whereArgs: [tourFile.arrivalId],
      );

      for (final step in tourFile.itinerary) {
        await txn.insert('itinerary_steps', {
          'id': step.id,
          'arrival_id': tourFile.arrivalId,
          'date': step.date,
          'time': step.time,
          'title': step.title,
          'content': step.content,
          'remarks': step.remarks,
          // Int direct store hota hai SQLite me
          'is_completed': step.isCompleted,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<TourFileModel?> getActiveTourFile() async {
    final db = await instance.database;
    final results = await db.query(
      'tour_files',
      limit: 1,
      orderBy: 'arrival_id DESC',
    );

    if (results.isNotEmpty) {
      final jsonBlob = results.first['full_json_blob'] as String?;
      if (jsonBlob != null && jsonBlob.isNotEmpty) {
        return TourFileModel.fromJson(jsonDecode(jsonBlob));
      }
    }
    return null;
  }

  Future<void> updateStepStatus(int stepId, bool isCompleted) async {
    final db = await instance.database;
    await db.update(
      'itinerary_steps',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [stepId],
    );
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('itinerary_steps');
    await db.delete('tour_files');
    await db.delete('sync_queue');
  }
}
