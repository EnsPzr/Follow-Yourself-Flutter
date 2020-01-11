import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:followyourselfflutter/models/activity.dart';
import 'package:followyourselfflutter/models/activityStatus.dart';
import 'package:followyourselfflutter/viewModels/activityStatusVM.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:followyourselfflutter/util/database_helper.dart';
import 'package:followyourselfflutter/viewModels/reportVM.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'drawer_menu.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:path/path.dart' as p;

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
  bool _isRestoreDisabled = false;
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
            color:
                _isBackupDisabled ? Colors.red.shade900 : Colors.green.shade500,
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
            onPressed: _isRestoreDisabled
                ? () {}
                : () async {
                    var result = await authorizateControl();
                    if (result) {
                      await RecoveryBackup();
                    } else {
                      openShowDialog(_context, false);
                    }
                  },
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: _isRestoreDisabled
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
                        new Text("Geri Yükleniyor..."),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  )
                : Text(
                    "Yedekten Geri Yükle",
                    style: TextStyle(fontSize: 17),
                  ),
            color: _isRestoreDisabled
                ? Colors.red.shade900
                : Colors.green.shade500,
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
    //TODO: Dosya Uzantısı lhmcn yapilacak
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
        ".lhmcn";
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

  Future<void> RecoveryBackup() async {
    _isRestoreDisabled = true;
    var file = await FilePicker.getFile(fileExtension: '.lhmcn');
    if (file == null) {
      showDialogShow(
          "Lütfen lhmcn Uzantılı Bir Dosya Seçtiğinizden Emin Olunuz.");
    } else {
      if (p.extension(file.path) != ".lhmcn") {
        debugPrint(p.extension(file.path));
        showDialogShow(
            "Lütfen lhmcn Uzantılı Bir Dosya Seçtiğinizden Emin Olunuz.");
      } else {
        var bytes = File(file.path).readAsBytesSync();
        var decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);
        if (decoder.tables.keys.length == 2) {
          var activitiesPage = decoder.tables.values.first;
          var activityStatusPage = decoder.tables.values.last;
          if (activitiesPage.maxCols == 4 || activityStatusPage.maxCols == 6) {
            var activitiesPageFirstRow = activitiesPage.rows.first;
            var activityStatusPageFirstRow = activityStatusPage.rows.first;
            if (activitiesPageFirstRow[0] == "Id" &&
                activitiesPageFirstRow[1] == "Name" &&
                activitiesPageFirstRow[2] == "RegisterDate" &&
                activitiesPageFirstRow[3] == "Status" &&
                activityStatusPageFirstRow[0] == "ActivityStatusId" &&
                activityStatusPageFirstRow[1] == "ActivityId" &&
                activityStatusPageFirstRow[2] == "ActivityValue" &&
                activityStatusPageFirstRow[3] == "Year" &&
                activityStatusPageFirstRow[4] == "Month" &&
                activityStatusPageFirstRow[5] == "Date") {
              var activitiesList = new List<Activity>();
              var activityStatuses = new List<ActivityStatus>();
              for (var row in activitiesPage.rows) {
                if (row == activitiesPageFirstRow)
                  continue;
                else {
                  activitiesList.add(Activity.withIdAndWithDate(
                      int.parse(row[0]),
                      row[1],
                      row[3].toString().toLowerCase() == "true" ? true : false,
                      DateTime.parse(row[2])));
                }
              }
              for (var row in activityStatusPage.rows) {
                if (row == activityStatusPageFirstRow)
                  continue;
                else {
                  activityStatuses.add(ActivityStatus.withId(
                      int.parse(row[0]),
                      int.parse(row[1]),
                      double.parse(row[2]),
                      int.parse(row[3]),
                      int.parse(row[4]),
                      int.parse(row[5])));
                }
              }
              for (var activity in activitiesList) {
                if (await databaseHelper.hasActivity(activity)) {
                  var result = await showDialogShowReturnBool(
                      '${activity.activityName} aktivitesi daha önceden eklenmiş. Activitenin Durumlarını Güncellemek İster Misiniz?');
                  if (result) {
                    var activityId = await databaseHelper.getActivity(activity);
                    if (activityId == -1) {
                      snackBarShow(
                          '${activity.activityName} aktivitesinin durumları güncellenemedi.');
                    } else {
                      for (var activityStatus in activityStatuses
                          .where((a) => a.activityId == activity.activityId)
                          .toList()) {
                        await databaseHelper.saveActivityStatusSingle(
                            ActivityStatusVM(activityStatus.activityValue,
                                activity.activityName, activityId),
                            DateTime(activityStatus.year, activityStatus.month,
                                activityStatus.day));
                      }
                    }
                  }
                } else {
                  var newActivityId = await databaseHelper.addActivity(
                      Activity.withDate(activity.activityName,
                          activity.isActive, activity.activityRegisterDate));
                  if (newActivityId != 0) {
                    for (var activityStatus in activityStatuses
                        .where((a) => a.activityId == activity.activityId)
                        .toList()) {
                      await databaseHelper.addActivityStatus(
                          ActivityStatusVM(activityStatus.activityValue,
                              activity.activityName, activity.activityId),
                          DateTime(activityStatus.year, activityStatus.month,
                              activityStatus.day));
                    }
                  }
                }
              }
              isSuccess = false;
              snackBarShow("Yedekten Geri Yükleme İşlemi Tamamlandı.");
              databaseHelper.report().then((value) {
                reportList = value as List<Report>;
                Future.delayed(Duration(milliseconds: 2000), () {
                  isSuccess = true;
                  setState(() {});
                });
              });
            } else {
              showDialogShow(
                  "Yedek Dosyasının Formatında Problem Olduğundan Yedekten Geri Yükleme İşlemi Yapılamadı.");
            }
          } else {
            showDialogShow(
                "Yedek Dosyasının Formatında Problem Olduğundan Yedekten Geri Yükleme İşlemi Yapılamadı.");
          }
        } else {
          showDialogShow(
              "Yedek Dosyasının Formatında Problem Olduğundan Yedekten Geri Yükleme İşlemi Yapılamadı.");
        }
        // for (var table in decoder.tables.keys) {
        //   print(table);
        //   print(decoder.tables[table].maxCols);
        //   print(decoder.tables[table].maxRows);
        //   for (var row in decoder.tables[table].rows) {
        //     print("$row");
        //   }
        // }
      }
      _isRestoreDisabled = false;
    }
  }

  showDialogShow(String message) {
    showDialog(
      context: _context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hata"),
          content: Text(message),
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

  Future<bool> showDialogShowReturnBool(String message) async => showDialog(
        context: _context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Hata"),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text("Evet"),
                onPressed: () {
                  Navigator.pop(context, true);
                  // Navigator.of(context).pop();
                  // return true;
                },
              ),
              FlatButton(
                child: Text("Hayır"),
                onPressed: () {
                  Navigator.pop(context, false);
                  // Navigator.of(context).pop();
                  // return false;
                },
              ),
            ],
          );
        },
      );
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
