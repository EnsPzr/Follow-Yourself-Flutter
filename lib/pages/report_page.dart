import 'dart:io';
import 'package:flutter/services.dart';
import 'package:followyourselfflutter/models/activity.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:followyourselfflutter/util/database_helper.dart';
import 'package:followyourselfflutter/viewModels/reportVM.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'drawer_menu.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DatabaseHelper databaseHelper;
  List reportList = List<Report>();
  bool isSuccess = false;
  BuildContext _context;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isBackupDisabled = false;
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
    _context = context;
    return Scaffold(
      key: scaffoldKey,
      drawer: DrawerMenu(),
      appBar: AppBar(
        title: Text("Rapor"),
        backgroundColor: Colors.red.shade900,
      ),
      body: Container(
        child: !isSuccess
            ? LoadingWidget()
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
          height: 50,
          child: RaisedButton(
            onPressed: _isBackupDisabled
                ? () {}
                : () async {
                    var result = await authorizateControl();
                    if (result) {
                      await RaporOlustur();
                    } else {
                      openShowDialog(_context, true);
                    }
                  },
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: _isBackupDisabled
                ? Container(
                    child: Row(
                      children: <Widget>[
                        new CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(Colors.green.shade500),
                        ),
                        new SizedBox(
                          width: 10,
                        ),
                        new Text("Rapor Oluşturuluyor..."),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  )
                : Text(
                    "Yedekle",
                    style: TextStyle(fontSize: 17),
                  ),
            color: _isBackupDisabled ? Colors.red.shade900 : Colors.green.shade500,
            textColor: Colors.white,
          ),
        ),
      ),
    );
    widgetList.add(SizedBox(
      height: 10,
    ));
    widgetList.add(
      Padding(
        padding: const EdgeInsets.only(right: 8, left: 8),
        child: ButtonTheme(
          height: 50,
          child: RaisedButton(
            onPressed: _isBackupDisabled
                ? () {}
                : () async {
                    var result = await authorizateControl();
                    if (result) {
                    } else {
                      openShowDialog(_context, false);
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

  void RaporOlustur() async {
    // var file = "test/";
    _isBackupDisabled = true;
    setState(() {});
    var klasor = await getApplicationDocumentsDirectory();
    var sdCard = await getExternalStorageDirectory();
    var bytes = await rootBundle.load("assets/kalip.xlsx");
    var orjinalExcel =
        await writeToFile(bytes, join(klasor.path, "kalip.xlsx"));
    var date = DateTime.now();
    var dosyaAdi = "kisiseltakip-" +
        date.day.toString() +
        "-" +
        date.month.toString() +
        "-" +
        date.year.toString() +
        "-" +
        date.hour.toString() +
        "-" +
        date.minute.toString() +
        "-" +
        date.second.toString() +
        ".xlsx";
    var kopyalanilacakYer = join(klasor.path, dosyaAdi);
    if (sdCard.path != null) {
      var klasorYol = join(sdCard.path, "Kişisel Takip");
      if (!await Directory(klasorYol).exists())
        Directory(klasorYol).createSync();
      kopyalanilacakYer = join(sdCard.path, "Kişisel Takip", dosyaAdi);
    }
    var yeniDosya = File(orjinalExcel.path).copySync(kopyalanilacakYer);
    File(orjinalExcel.path).delete();
    var veriler = yeniDosya.readAsBytesSync();
    var decoder = SpreadsheetDecoder.decodeBytes(veriler, update: true);
    var sheet = decoder.tables;
    await ActivitiesSheetCreate(decoder, sheet);
    await ActivityStatesSheetCreate(decoder, sheet);
    File(join(yeniDosya.path))
      ..createSync(recursive: true)
      ..writeAsBytesSync(decoder.encode());
    debugPrint("Bitti Hacı");

    await Future.delayed(Duration(milliseconds: 2000), () {
      _isBackupDisabled = false;
      setState(() {});
    });
    snackBarShow("Yedek Kişisel Takip Klasörüne Başarıyla Oluşturuldu.");
  }

  Future ActivityStatesSheetCreate(
      SpreadsheetDecoder decoder, Map<String, SpreadsheetTable> sheet) async {
    decoder..insertColumn(sheet.keys.last, 0);
    decoder..insertColumn(sheet.keys.last, 1);
    decoder..insertColumn(sheet.keys.last, 2);
    decoder..insertColumn(sheet.keys.last, 3);
    decoder..insertColumn(sheet.keys.last, 4);
    decoder..insertColumn(sheet.keys.last, 5);

    decoder..insertRow(sheet.keys.last, 0);
    decoder..updateCell(sheet.keys.last, 0, 0, 'ActivityStatusId');
    decoder..updateCell(sheet.keys.last, 1, 0, 'ActivityId');
    decoder..updateCell(sheet.keys.last, 2, 0, 'ActivityValue');
    decoder..updateCell(sheet.keys.last, 3, 0, 'Year');
    decoder..updateCell(sheet.keys.last, 4, 0, 'Month');
    decoder..updateCell(sheet.keys.last, 5, 0, 'Date');
    var allActivityStatus = await databaseHelper.getAllActivityStatusNoDate();
    var a = 0;
    for (var map in allActivityStatus) {
      a++;
      decoder..insertRow(sheet.keys.last, a);
      decoder..updateCell(sheet.keys.last, 0, a, '${map.activityStatusId}');
      decoder..updateCell(sheet.keys.last, 1, a, '${map.activityId}');
      decoder..updateCell(sheet.keys.last, 2, a, '${map.activityValue}');
      decoder..updateCell(sheet.keys.last, 3, a, '${map.year}');
      decoder..updateCell(sheet.keys.last, 4, a, '${map.month}');
      decoder..updateCell(sheet.keys.last, 5, a, '${map.day}');
    }
  }

  Future<void> ActivitiesSheetCreate(
      SpreadsheetDecoder decoder, Map<String, SpreadsheetTable> sheet) async {
    decoder..insertColumn(sheet.keys.first, 0);
    decoder..insertColumn(sheet.keys.first, 1);
    decoder..insertColumn(sheet.keys.first, 2);
    decoder..insertColumn(sheet.keys.first, 3);
    decoder..insertRow(sheet.keys.first, 0);
    decoder..updateCell(sheet.keys.first, 0, 0, 'Id');
    decoder..updateCell(sheet.keys.first, 1, 0, 'Name');
    decoder..updateCell(sheet.keys.first, 2, 0, 'RegisterDate');
    decoder..updateCell(sheet.keys.first, 3, 0, 'Status');
    var activities = await databaseHelper.getAllActivities();
    var a = 0;
    for (var map in activities) {
      var activity = Activity.fromMap(map);
      decoder..insertRow(sheet.keys.first, (a + 1));
      decoder
        ..updateCell(sheet.keys.first, 0, (a + 1), '${activity.activityId}');
      decoder
        ..updateCell(sheet.keys.first, 1, (a + 1), '${activity.activityName}');
      decoder
        ..updateCell(
            sheet.keys.first, 2, (a + 1), '${activity.activityRegisterDate}');
      decoder..updateCell(sheet.keys.first, 3, (a + 1), '${activity.isActive}');
      a++;
    }
  }

  snackBarShow(mesaj) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(mesaj),
      duration: Duration(seconds: 5),
    ));
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade900),
            ),
            SizedBox(
              height: 10,
            ),
            Text("Rapor Getiriliyor...")
          ],
        ),
      ),
    );
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
    if (permission == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}

void openShowDialog(BuildContext context, bool type) async {
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
Future<File> writeToFile(ByteData data, String path) {
  final buffer = data.buffer;
  return new File(path)
      .writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}
