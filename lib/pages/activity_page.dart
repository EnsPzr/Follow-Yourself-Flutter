import 'dart:async';
import 'package:flutter/material.dart';
import 'package:followyourselfflutter/models/activity.dart';
import 'package:followyourselfflutter/pages/activiy_add_or_update_page.dart';
import 'package:followyourselfflutter/util/database_helper.dart';
import 'drawer_menu.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  DatabaseHelper databaseHelper;
  List<Activity> allActivities = List<Activity>();
  bool isSuccess = false;
  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: DrawerMenu(),
      appBar: AppBar(
        title: Text("Tüm Aktivitelerim"),
        backgroundColor: Colors.red.shade900,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ActivityAddOrUpdatePage()))
                  .then((isAdded) {
                if (isAdded) {
                  snackBarShow();
                  fetchData();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchData();
            },
          ),
        ],
      ),
      body: Center(
        child: !isSuccess
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                width: 250,
                height: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.red.shade900),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Aktiviteleriniz Yükleniyor...")
                  ],
                ),
              )
            : allActivities.length == 0
                ? Text("Hiç bir aktivite eklememişsiniz.")
                : ListView.builder(
                    itemCount: allActivities.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        child: Card(
                          child: ListTile(
                            onTap: () {
                              Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ActivityAddOrUpdatePage(
                                                  activity:
                                                      allActivities[index])))
                                  .then((isUpdated) {
                                if (isUpdated) {
                                  snackBarShow();
                                  fetchData();
                                }
                              });
                            },
                            isThreeLine: false,
                            title: Text(
                              allActivities[index].activityName,
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                            subtitle: allActivities[index].isActive
                                ? Text("Aktif")
                                : Text("Değil"),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  fetchData() {
    setState(() {
      isSuccess = false;
    });
    allActivities.clear();
    databaseHelper.getAllActivities().then((mapListesi) {
      for (Map okunanMap in mapListesi) {
        allActivities.add(Activity.fromMap(okunanMap));
      }
      Future.delayed(Duration(milliseconds: 2000), () {
        isSuccess = true;
        setState(() {});
      });
    });
  }

  snackBarShow() {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Aktivite başarı ile kayıt edildi."),
      duration: Duration(seconds: 2),
    ));
  }
}
