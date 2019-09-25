import 'package:flutter/material.dart';
import 'package:followyourselfflutter/util/database_helper.dart';
import 'package:followyourselfflutter/viewModels/reportVM.dart';
import 'package:permission_handler/permission_handler.dart';
import 'drawer_menu.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DatabaseHelper databaseHelper;
  List reportList = List<Report>();
  bool isSuccess = false;
  var width = 0.0;
  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    databaseHelper.report().then((value) {
      reportList = value as List<Report>;
      Future.delayed(Duration(milliseconds: 2000), () {
        isSuccess = true;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width - 10;
    return Scaffold(
      drawer: DrawerMenu(),
      appBar: AppBar(
        title: Text("Rapor"),
        backgroundColor: Colors.red.shade900,
      ),
      body: Container(
        child: !isSuccess
            ? CircularProgressIndicator()
            : ListView(
                padding: EdgeInsets.only(top: 10, right: 5, left: 5),
                children: CreateDisplay),
      ),
    );
  }

  List<Widget> get CreateDisplay {
    var widgetList = List<Widget>();
    widgetList.add(
      addRow(width / 5, "Aktivite Adı", "Toplam Yapılma", "Bu Yıl", "Bu Ay",
          "Bu Hafta"),
    );
    var i = 1;
    for (Report item in reportList) {
      widgetList.add(addRow(width / 5, item.activityName, item.sum,
          item.thisYear, item.thisMonth, item.thisWeek,
          isGrey: i % 2 == 0 ? true : false));
      i++;
    }

    widgetList.add(
      Padding(
        padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
        child: ButtonTheme(
          height: 40,
          child: RaisedButton(
            onPressed: () async {
              var result = await authorizateControl();
              if (result) {
              } else {
                openShowDialog(context, true);
              }
            },
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(
              "Yedekle",
              style: TextStyle(fontSize: 17),
            ),
            color: Colors.green.shade500,
            textColor: Colors.white,
          ),
        ),
      ),
    );
    widgetList.add(
      Padding(
        padding: const EdgeInsets.only(right: 8, left: 8),
        child: ButtonTheme(
          height: 40,
          child: RaisedButton(
            onPressed: () async {
              var result = await authorizateControl();
              if (result) {
              } else {
                openShowDialog(context, false);
              }
            },
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(
              "Yedekten Geri Yükle",
              style: TextStyle(fontSize: 17),
            ),
            color: Colors.green.shade500,
            textColor: Colors.white,
          ),
        ),
      ),
    );
    return widgetList;
  }
}

Container addRow(double columnWidth, str1, str2, str3, str4, str5,
    {bool isGrey}) {
  return Container(
    color: isGrey != null
        ? isGrey == true ? Colors.grey : Colors.white
        : Colors.white,
    child: Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          width: columnWidth,
          child: Center(
              child: Text(
            str1,
            textAlign: TextAlign.center,
          )),
        ),
        Container(
          alignment: Alignment.center,
          width: columnWidth,
          child: Text(
            str2,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: columnWidth,
          child: Center(
              child: Text(
            str3,
            textAlign: TextAlign.center,
          )),
        ),
        Container(
          alignment: Alignment.center,
          width: columnWidth,
          child: Center(
              child: Text(
            str4,
            textAlign: TextAlign.center,
          )),
        ),
        Container(
          alignment: Alignment.center,
          width: columnWidth,
          child: Center(
              child: Text(
            str5,
            textAlign: TextAlign.center,
          )),
        ),
      ],
    ),
  );
}

Future<bool> authorizateControl() async {
  PermissionStatus permission =
      await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  if (permission == PermissionStatus.granted) {
    return true;
  } else {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    PermissionStatus permission = permissions[PermissionGroup.storage];
    if (permission == PermissionStatus.denied) {
      return false;
    } else {
      return true;
    }
  }
}

void openShowDialog(context, bool type) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Hata'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              type
                  ? Text(
                      'Yedekleme işlemi için dosya erişimine izin vermeniz gerekmektedir.')
                  : Text(
                      'Geri Yükleme işlemi için dosya erişimine izin vermeniz gerekmektedir.'),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("Tamam"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
/*
GridView.count(
        crossAxisCount: 5,
        padding: EdgeInsets.only(top: 10, right: 5, left: 5),
        reverse: false,
        primary: true,
        children: <Widget>[
          Container(
            child: Text("Aktivite Adı"),
          ),
          Container(
            child: Text("Toplam Yapılma"),
          ),
          Container(
            child: Text("Bu Yıl"),
          ),
          Container(
            child: Text("Bu Ay"),
          ),
          Container(
            child: Text("Bu Hafta"),
          ),
        ],
      ),
      */
