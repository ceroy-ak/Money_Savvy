import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:moneysavvy/models/expenseDataClass.dart';

class DatabaseProvider {
  static const String TABLE_RECORD = "record";
  static const String COLUMN_ID = "id";
  static const String COLUMN_DESC = "description";
  static const String COLUMN_CAT = "category";
  static const String COLUMN_AMOUNT = "amount";
  static const String COLUMN_DATE = "date";
  static const String COLUMN_TYPE = "type";

  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  Database _database;

  Future<Database> get database async {
    print("database getter called");

    if (_database != null) {
      return _database;
    }

    _database = await createDatabase();

    return _database;
  }

  Future<Database> createDatabase() async {
    String dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, 'recordDB.db'),
      version: 1,
      onCreate: (Database database, int version) async {
        print("Creating food table");

        await database.execute(
          '''
          CREATE TABLE $TABLE_RECORD (
          $COLUMN_ID INTEGER PRIMARY KEY,
          $COLUMN_DESC TEXT,
          $COLUMN_CAT TEXT,
          $COLUMN_AMOUNT NUMERIC,
          $COLUMN_TYPE INTEGER,
          $COLUMN_DATE TEXT )
          ''',
        );
      },
    );
  }

  Future<List<ExpenseData>> fetchRecords() async {
    print('Fetch Record Working');
    final db = await database;

    var records = await db.query(TABLE_RECORD,
        columns: [
          COLUMN_ID,
          COLUMN_DESC,
          COLUMN_AMOUNT,
          COLUMN_CAT,
          COLUMN_TYPE,
          COLUMN_DATE
        ],
        where: "$COLUMN_DATE LIKE ?",
        whereArgs: [DateTime.now().toString().substring(0, 7) + '%']);

    List<ExpenseData> recordsList = List<ExpenseData>();
    records.forEach((element) {
      //print(element);
      ExpenseData temp = ExpenseData.fromMap(element);
      recordsList.add(temp);
    });
    //print(recordsList);
    return recordsList;
  }

  Future<List<ExpenseData>> fetchPastRecords(DateTime _date) async {
    print('Fetch Record Working');
    final db = await database;

    var records = await db.query(TABLE_RECORD,
        columns: [
          COLUMN_ID,
          COLUMN_DESC,
          COLUMN_AMOUNT,
          COLUMN_CAT,
          COLUMN_TYPE,
          COLUMN_DATE
        ],
        where: "$COLUMN_DATE LIKE ?",
        whereArgs: [_date.toString().substring(0, 7) + '%']);

    List<ExpenseData> recordsList = List<ExpenseData>();
    records.forEach((element) {
      //print(element);
      ExpenseData temp = ExpenseData.fromMap(element);
      recordsList.add(temp);
    });
    //print(recordsList);
    return recordsList;
  }

  Future<ExpenseData> insertRecord(ExpenseData temp) async {
    print("Insert Record Working");
    final db = await database;
    temp.id = await db.insert(TABLE_RECORD, temp.toMap());
    return temp;
  }

  Future<int> deleteRecord(int id) async {
    print('Delete Record Working to delete $id');
    final db = await database;

    return await db.delete(TABLE_RECORD, where: "id = ?", whereArgs: [id]);
  }

  Future<int> updateRecord(ExpenseData temp) async {
    final db = await database;
    print('Update Record Working');
    return await db.update(TABLE_RECORD, temp.toMap(),
        where: "id = ?", whereArgs: [temp.id]);
  }
}
