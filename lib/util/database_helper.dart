import 'package:flutter/foundation.dart';
import 'package:followyourselfflutter/models/activity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;
  DatabaseHelper._internal();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper;
    } else {
      return _databaseHelper;
    }
  }

  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await _initializeDatabase();
      return _database;
    } else {
      return _database;
    }
  }

  _initializeDatabase() async {
    var klasor = await getApplicationDocumentsDirectory();
    var path = join(klasor.path, "kisiselTakip.db");
    var kisiselTakipDb =
        await openDatabase(path, version: 1, onCreate: _createDB);
    debugPrint("path=>" + kisiselTakipDb.path);
    return kisiselTakipDb;
  }

  Future _createDB(Database db, int version) async {
    await db.execute(
        "CREATE TABLE Activity (activityId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, activityName TEXT, activityRegisterDate TEXT, isActive INTEGER)");
    await db.execute(
        "CREATE TABLE ActivityStatus (activityStatusId INT PRIMARY KEY NOT NULL, activityId INT REFERENCES Activity (activityId), activityValue DOUBLE, date TEXT);");
  }

  Future<List<Map<String, dynamic>>> getAllActivities() async {
    var db = await _getDatabase();
    var result = await db.query("Activity", orderBy: 'activityId ASC');
    return result;
  }

  Future<int> addActivity(Activity activity) async {
    var db = await _getDatabase();
    var result = await db.insert("Activity", activity.toMap());
    return result;
  }

  Future<int> updateActivity(Activity activity) async {
    var db = await _getDatabase();
    var result = await db.update("Activity", activity.toMap(),
        where: 'activityId = ?', whereArgs: [activity.activityId]);
    return result;
  }

  Future<bool> hasActivity(Activity activity) async {
    var db = await _getDatabase();
    // var result= await db.query("Activity",where:'activityName= ?',whereArgs: [activity.activityName]);
    var result = await db.rawQuery(
        "select * from Activity where LOWER(activityName)='${activity.activityName.toLowerCase()}'",
        null);
    if (result.length > 0)
      return true;
    else
      return false;
    //buradan devam edilecek
  }

  Future<bool> hasActivityWithId(Activity activity) async {
    var db = await _getDatabase();
    // var result= await db.query("Activity",where:'activityName= ?',whereArgs: [activity.activityName]);
    var query =
        "select * from Activity where LOWER(activityName)='${activity.activityName.toLowerCase()}' AND activityId!='${activity.activityId}'";
    var result = await db.rawQuery(query, null);
    if (result.length > 0)
      return true;
    else
      return false;
    //buradan devam edilecek
  }
}
