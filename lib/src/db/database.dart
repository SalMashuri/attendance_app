import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// database table and column names
final String tableDatauser = 'MSG_datauser';
final String columnId = '_id';
final String columnName = 'name';
final String columnEmail = 'email';
final String columnStatus = 'status';
final String columnHomeadd = 'home_address';
final String columnHomelat = 'home_latlong';
final String columnOfficeadd = 'office_address';
final String columnOfficelat = 'office_latlong';
final String columnImage = 'image';
final String columnToken = 'token';

class Datauser {
  int? id;
  String? name;
  String? email;
  String? status;
  String? homeAddress;
  String? homeLatlong;
  String? officeAddress;
  String? officeLatlong;
  String? image;
  String? token;

  Datauser(
      {this.id,
      this.name,
      this.email,
      this.status,
      this.homeAddress,
      this.homeLatlong,
      this.officeAddress,
      this.officeLatlong,
      this.image,
      this.token});

  Datauser.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    email = map[columnEmail];
    status = map[columnStatus];
    homeAddress = map[columnHomeadd];
    homeLatlong = map[columnHomelat];
    officeAddress = map[columnOfficeadd];
    officeLatlong = map[columnOfficelat];
    image = map[columnImage];
    token = map[columnToken];
  }

  // convenience method to create a Map from this datauser object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnName: name,
      columnEmail: email,
      columnStatus: status,
      columnHomeadd: homeAddress,
      columnHomelat: homeLatlong,
      columnOfficeadd: officeAddress,
      columnOfficelat: officeLatlong,
      columnImage: image,
      columnToken: token,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

// singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "faridah_MSG.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 3;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableDatauser (
                $columnId INTEGER PRIMARY KEY,
                $columnName TEXT NOT NULL,
                $columnEmail TEXT NOT NULL,
                $columnStatus TEXT NOT NULL,
                $columnHomeadd TEXT,
                $columnHomelat TEXT,
                $columnOfficeadd TEXT,
                $columnOfficelat TEXT,
                $columnImage TEXT,
                $columnToken TEXT NOT NULL
              )
              ''');
  }

  // Database helper methods:

  Future<int> insert(Datauser datauser) async {
    Database? db = await database;
    int id = await db!.insert(tableDatauser, datauser.toMap());
    return id;
  }

  // Future<Datauser> queryWord(int id) async {
  Future<Datauser?> queryDatauser(int id) async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableDatauser,
        columns: [
          columnId,
          columnName,
          columnEmail,
          columnStatus,
          columnHomeadd,
          columnHomelat,
          columnOfficeadd,
          columnOfficelat,
          columnImage,
          columnToken
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Datauser.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!
        .delete(tableDatauser, where: '$columnId = ?', whereArgs: [id]);
  }

  // Future<int> update(Datauser datauser) async {
  //   Database db = await instance.database;
  //   int id = datauser.toMap()['_id'];
  //   return await db.update(tableDatauser, datauser.toMap(),
  //       where: '$columnId = ?', whereArgs: [id]);
  // }

  // Future<int> update(Datauser datauser) async {
  //   Database db = await instance.database;
  //   return await db.update(tableDatauser, datauser.toMap(),
  //       where: '$columnId = ?', whereArgs: [datauser.id]);
  // }

  // Future<int> update(Map<String, dynamic> row) async {
  //   Database db = await instance.database;
  //   int id = row[columnId];
  //   return await db.update(tableDatauser, row, where: '$columnId = ?', whereArgs: [id]);
  // }

  Future<int?> update(Datauser datauser) async {
    try {
      Database? db = await database;
      return await db!.update(tableDatauser, datauser.toMap(),
          where: '$columnId = ?', whereArgs: [datauser.id]);
    } catch (e) {
      print('Could not update the data: $e');
    }
  }

  // TODO: queryAllWords()
  // TODO: delete(int id)
  // TODO: update(Word word)
}
