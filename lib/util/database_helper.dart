import 'package:flutter/foundation.dart';
import 'package:followyourselfflutter/models/activity.dart';
import 'package:followyourselfflutter/models/activityStatus.dart';
import 'package:followyourselfflutter/viewModels/activityStatusVM.dart';
import 'package:followyourselfflutter/viewModels/reportVM.dart';
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
        "CREATE TABLE ActivityStatus (activityStatusId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, activityId INT REFERENCES Activity (activityId), activityValue DOUBLE, date TEXT, year INTEGER, month INTEGER, day INTEGER);");
  }

  Future<List<Map<String, dynamic>>> getAllActivities({bool isActive}) async {
    var db = await _getDatabase();
    if (isActive != null) {
      var result = await db.query("Activity",
          where: "isActive=?", whereArgs: [1], orderBy: 'activityId ASC');
      return result;
    }
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
  }

  Future<List<ActivityStatusVM>> getAllActivityStatus(DateTime date) async {
    var db = await _getDatabase();
    var allActivityStatus = List<ActivityStatusVM>();
    var veri = await getAllActivities(isActive: true);
    for (Map readMap in veri) {
      var activity = Activity.fromMap(readMap);
      // var now = DateTime.now();
      var diff = activity.activityRegisterDate.difference(date).inDays;
      if (diff <= 0) {
        var activityStatus = await db.query("ActivityStatus",
            where: 'activityId=? AND year=? AND month=? AND day=? ',
            whereArgs: [activity.activityId, date.year, date.month, date.day]);
        if (activityStatus.length > 0) {
          var singleActivityState = ActivityStatus.fromMap(activityStatus[0]);
          allActivityStatus.add(ActivityStatusVM(
              singleActivityState.activityValue,
              activity.activityName,
              activity.activityId,
              activityStatusId: singleActivityState.activityStatusId));
        } else {
          allActivityStatus.add(
              ActivityStatusVM(0, activity.activityName, activity.activityId));
        }
      }
    }
    ;
    debugPrint("toplam ${allActivityStatus.length}");
    return allActivityStatus;
  }

  Future<int> saveActivityStatus(
      List<ActivityStatusVM> allActivityStatus, DateTime date) async {
    var db = await _getDatabase();
    var counter = 0;
    for (var i = 0; i < allActivityStatus.length; i++) {
      if (allActivityStatus[i].activityValue == 0) {
        counter++;
      } else {
        var activityStatus = await db.query("ActivityStatus",
            where: 'activityId=? AND year=? AND month=? AND day=?',
            whereArgs: [
              allActivityStatus[i].activityId,
              date.year,
              date.month,
              date.day
            ]);
        if (activityStatus.length == 0) {
          var result = await addActivityStatus(allActivityStatus[i], date);
          if (result != 0) counter++;
        } else {
          var result = await updateActivityStatus(allActivityStatus[i], date);
          if (result != 0) counter++;
        }
      }
    }
    return counter;
  }

  Future<int> addActivityStatus(
      ActivityStatusVM activityStateVM, DateTime date) async {
    var db = await _getDatabase();
    var activityState = ActivityStatus(activityStateVM.activityId,
        activityStateVM.activityValue, date, date.year, date.month, date.day);
    var result = await db.insert("ActivityStatus", activityState.toMap());
    return result;
  }

  Future<int> updateActivityStatus(
      ActivityStatusVM activityStateVM, DateTime date) async {
    var db = await _getDatabase();
    var activityState = ActivityStatus.withId(
        activityStateVM.activityStatusId,
        activityStateVM.activityId,
        activityStateVM.activityValue,
        date,
        date.year,
        date.month,
        date.day);
    var result = await db.update("ActivityStatus", activityState.toMap());
    return result;
  }

  Future<List<Report>> report() async {
    var db = await _getDatabase();
    var allActivities = await getAllActivities();
    var reportList = List<Report>();
    for (var map in allActivities) {
      var activity = Activity.fromMap(map);
      var sum = await db.rawQuery(
          "select SUM(activityValue) from ActivityStatus where activityId=${activity.activityId}",
          null);
      var sumValue = sum[0]["SUM(activityValue)"] as double;
      var thisYear = await db.rawQuery(
          "select SUM(activityValue) from ActivityStatus where activityId=${activity.activityId} AND year=${DateTime.now().year}",
          null);
      var thisYearValue = thisYear[0]["SUM(activityValue)"] as double;
      var thisMonth = await db.rawQuery(
          "select SUM(activityValue) from ActivityStatus where activityId=${activity.activityId} AND year=${DateTime.now().year} AND month=${DateTime.now().month}",
          null);
      var thisMonthValue = thisMonth[0]["SUM(activityValue)"] as double;
      var todaysWeek = DateTime.now().weekday;
      var startedDay = DateTime.now().add(Duration(days: -todaysWeek));
      var thisWeek = await db.rawQuery(
          "select SUM(activityValue) from ActivityStatus where activityId=${activity.activityId} AND year=${startedDay.year} AND month>=${startedDay.month} AND day>=${startedDay.day}",
          null);
      var thisWeekValue = thisWeek[0]["SUM(activityValue)"] as double;
      reportList.add(Report(
          activity.activityName,
          sumValue != null ? sumValue.toString() : "0",
          thisYearValue != null ? thisYearValue.toString() : "0",
          thisMonthValue != null ? thisMonthValue.toString() : "0",
          thisWeekValue != null ? thisWeekValue.toString() : "0"));
    }
    return reportList;
  }
}
