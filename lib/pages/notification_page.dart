import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:followyourselfflutter/models/notification.dart';
import 'package:followyourselfflutter/pages/notification_add_or_update_page.dart';
import 'package:followyourselfflutter/util/database_helper.dart';

import 'drawer_menu.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  var isSuccess = false;
  var notifications = new List<NotificationModel>();
  DatabaseHelper databaseHelper;
  @override
  void initState() {
    super.initState();
    databaseHelper = new DatabaseHelper();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: DrawerMenu(),
        appBar: AppBar(
          title: Text("Bildirimler"),
          backgroundColor: Colors.red.shade900,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NotificationAddOrUpdatePage())).then((isAdded) {
                  if (isAdded) {}
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
          child: isSuccess
              ? notifications.length == 0
                  ? Text("Hiç bir bildirim Oluşturmamışsınız")
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: Card(
                            child: ListTile(
                              onTap: () {
                                // Navigator.push<bool>(
                                //     context,
                                //     MaterialPageRoute(builder: (context) =>
                                //         // ActivityAddOrUpdatePage(
                                //         //     activity:
                                //         //         notifications[index])
                                //         )).then((isUpdated) {
                                //   if (isUpdated) {
                                //     // snackBarShow();
                                //     fetchData();
                                //   }
                                // });
                              },
                              isThreeLine: false,
                              title: Text(
                                notifications[index].notificationBody,
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                              subtitle: notifications[index].isActive
                                  ? Text("Aktif")
                                  : Text("Değil"),
                            ),
                          ),
                        );
                      },
                    )
              : Container(
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
                      Text("Bildirimler Yükleniyor...")
                    ],
                  ),
                ),
        ));
  }

  fetchData() async {
    setState(() {
      isSuccess = false;
    });
    notifications.clear();
    notifications = await databaseHelper.getAllNotification();
    Future.delayed(Duration(milliseconds: 2000), () {
      isSuccess = true;
      setState(() {});
    });
  }
}
