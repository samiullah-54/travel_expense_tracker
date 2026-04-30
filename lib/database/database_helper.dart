import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tour.dart';
import '../models/city_stay.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('travel_expense.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const numType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE tours (
  id $idType,
  title $textType,
  description $textType,
  startDate $textType,
  endDate $textType,
  advanceCash $numType,
  miscAdvanceCash $numType
)
''');

    await db.execute('''
CREATE TABLE city_stays (
  id $idType,
  tourId $textType,
  cityName $textType,
  arrivalDate $textType,
  departureDate $textType,
  FOREIGN KEY (tourId) REFERENCES tours (id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE expenses (
  id $idType,
  cityStayId $textType,
  amount $numType,
  category $textType,
  description $textType,
  date $textType,
  imagePath TEXT,
  deductedFrom TEXT,
  FOREIGN KEY (cityStayId) REFERENCES city_stays (id) ON DELETE CASCADE
)
''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tours ADD COLUMN advanceCash REAL DEFAULT 0.0');
      await db.execute('ALTER TABLE tours ADD COLUMN miscAdvanceCash REAL DEFAULT 0.0');
      await db.execute('ALTER TABLE expenses ADD COLUMN deductedFrom TEXT');
    }
  }

  // Tour methods
  Future<void> insertTour(Tour tour) async {
    final db = await instance.database;
    await db.insert('tours', tour.toMap());
  }

  Future<List<Tour>> getTours() async {
    final db = await instance.database;
    final maps = await db.query('tours', orderBy: 'startDate DESC');
    return maps.map((map) => Tour.fromMap(map)).toList();
  }

  Future<void> updateTour(Tour tour) async {
    final db = await instance.database;
    await db.update('tours', tour.toMap(), where: 'id = ?', whereArgs: [tour.id]);
  }

  Future<void> deleteTour(String id) async {
    final db = await instance.database;
    
    // Explicit cascade delete for safety
    final cityStays = await db.query('city_stays', where: 'tourId = ?', whereArgs: [id]);
    for (var cityStay in cityStays) {
      await db.delete('expenses', where: 'cityStayId = ?', whereArgs: [cityStay['id']]);
    }
    await db.delete('city_stays', where: 'tourId = ?', whereArgs: [id]);
    await db.delete('tours', where: 'id = ?', whereArgs: [id]);
  }

  // CityStay methods
  Future<void> insertCityStay(CityStay cityStay) async {
    final db = await instance.database;
    await db.insert('city_stays', cityStay.toMap());
  }

  Future<List<CityStay>> getCityStays(String tourId) async {
    final db = await instance.database;
    final maps = await db.query('city_stays', where: 'tourId = ?', whereArgs: [tourId], orderBy: 'arrivalDate ASC');
    return maps.map((map) => CityStay.fromMap(map)).toList();
  }

  Future<void> updateCityStay(CityStay cityStay) async {
    final db = await instance.database;
    await db.update('city_stays', cityStay.toMap(), where: 'id = ?', whereArgs: [cityStay.id]);
  }

  Future<void> deleteCityStay(String id) async {
    final db = await instance.database;
    // Explicit cascade delete for safety
    await db.delete('expenses', where: 'cityStayId = ?', whereArgs: [id]);
    await db.delete('city_stays', where: 'id = ?', whereArgs: [id]);
  }

  // Expense methods
  Future<void> insertExpense(Expense expense) async {
    final db = await instance.database;
    await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpenses(String cityStayId) async {
    final db = await instance.database;
    final maps = await db.query('expenses', where: 'cityStayId = ?', whereArgs: [cityStayId], orderBy: 'date DESC');
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await instance.database;
    await db.update('expenses', expense.toMap(), where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<void> deleteExpense(String id) async {
    final db = await instance.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // Cross-table aggregations
  Future<double> getDeductedAmountForTour(String tourId, String deductedType) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT SUM(e.amount) as total
      FROM expenses e
      JOIN city_stays c ON e.cityStayId = c.id
      WHERE c.tourId = ? AND e.deductedFrom = ?
    ''', [tourId, deductedType]);
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
