import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:followyourselfflutter/models/notification.dart';
import 'package:followyourselfflutter/pages/drawer_menu.dart';
import 'package:intl/intl.dart';

class NotificationAddOrUpdatePage extends StatefulWidget {
  NotificationAddOrUpdatePage({Key key, this.notification}) : super(key: key);
  final NotificationModel notification;
  @override
  _NotificationAddOrUpdatePageState createState() =>
      _NotificationAddOrUpdatePageState();
}

class _NotificationAddOrUpdatePageState
    extends State<NotificationAddOrUpdatePage> {
  String notificationBody;
  bool isActive = false;
  int notificationId = 0;
  final _format = DateFormat("HH:nn");
  DateTime notificationTime;
  var today = DateTime.now();
  @override
  void initState() {
    super.initState();
    if (widget.notification != null) {
      notificationBody = widget.notification.notificationBody;
      isActive = widget.notification.isActive != null
          ? widget.notification.isActive
          : true;
      notificationId = widget.notification.notificationId != null
          ? widget.notification.notificationId
          : 0;
      notificationTime = widget.notification.notificationHour != null
          ? DateTime(
              today.year,
              today.month,
              today.day,
              widget.notification.notificationHour,
              widget.notification.notificationMinute)
          : DateTime(
              today.year, today.month, today.day, today.hour, today.minute);
    } else {
      notificationTime:
      DateTime(today.year, today.month, today.day, today.hour, today.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMenu(),
      appBar: AppBar(
          title: Text("Bildirim İşlemleri"),
          backgroundColor: Colors.red.shade900),
      body: Form(
        child: ListView(
          children: <Widget>[
            Text(
              "Bildirim Mesajı:",
              style: TextStyle(color: Colors.blue.shade700),
            ),
            TextFormField(
              decoration: InputDecoration(),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null) {
                  return "Bildirim Mesajı boş bırakılamaz.";
                } else if (value.length <= 2) {
                  return "Bildirim Mesajı en az 3 karakter olmalıdır.";
                }
              },
              onSaved: (value) {
                notificationBody = value;
              },
              initialValue: notificationBody,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Bildirim Saati:",
              style: TextStyle(color: Colors.blue.shade700),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
