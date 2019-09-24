import 'package:date_format/date_format.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:followyourselfflutter/util/database_helper.dart';
import 'package:followyourselfflutter/viewModels/activityStatusVM.dart';
import 'drawer_menu.dart';
import 'package:intl/intl.dart';

class ActivityStatusPage extends StatefulWidget {
  _ActivityStatusPageState createState() => _ActivityStatusPageState();
}

class _ActivityStatusPageState extends State<ActivityStatusPage> {
  final _formKey = GlobalKey<FormState>();
  var date = DateTime.now();
  bool isCompleted = false;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  DatabaseHelper databaseHelper;
  var _tarih = DateTime.now();
  final _format = DateFormat("dd.MM.yyyy");
  var activityStatus = List<ActivityStatusVM>();
  @override
  void initState() {
    super.initState();
    debugPrint("başladı");
    databaseHelper = DatabaseHelper();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: DrawerMenu(),
      appBar: AppBar(
        title: Text("Günlük Aktivite İlerlemelerim"),
        backgroundColor: Colors.red.shade900,
      ),
      body: Padding(
        child: Form(
          key: _formKey,
          child: Center(
            child: isCompleted
                ? ListView(children: CreateDisplay())
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.red.shade900),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Günlük Aktivite Durumları Yükleniyor...")
                      ],
                    ),
                  ),
          ),
        ),
        padding: EdgeInsets.all(10),
      ),
    );
  }

  CreateDisplay() {
    var widgetList = new List<Widget>();
    widgetList.add(
      Text(
        'Günü Seçiniz:',
        style: TextStyle(color: Colors.blue.shade700),
      ),
    );
    widgetList.add(
      DateTimeField(
        resetIcon: null,
        format: _format,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: formatDate(date, [dd, '.', mm, '.', yyyy]),
          hintStyle: TextStyle(color: Colors.black),
        ),
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? date,
              lastDate: DateTime.now());
        },
        onChanged: (selectedDate) {
          date = selectedDate;
          setState(() {
            activityStatus.clear();
            isCompleted = false;
            getData();
          });
          debugPrint("$selectedDate");
        },
      ),
    );
    widgetList.add(
      SizedBox(
        height: 10,
      ),
    );
    if (activityStatus.length == 0) {
      widgetList.add(Center(
        child: Container(
          child: Text(
            "Bugün için aktif olan aktiviteniz veya eklenme tarihi bugünün tarihinden önce olan aktiviteniz bulunamadı.",
          ),
        ),
      ));
    }
    widgetList.add(
      SizedBox(
        height: 10,
      ),
    );
    for (var i = 0; i < activityStatus.length; i++) {
      widgetList.add(
        Text(
          activityStatus[i].activityName,
          style: TextStyle(color: Colors.blue.shade700),
        ),
      );
      widgetList.add(
        TextFormField(
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: activityStatus[i].activityValue.toString() == "0.0"
                ? "0"
                : activityStatus[i].activityValue.toString(),
          ),
          onSaved: (deger) {
            activityStatus[i].activityValue =
                deger != null ? double.parse(deger) : 0;
          },
          validator: (deger) {
            if (double.tryParse(deger) == null) {
              return "Sadece sayı girilmelidir";
            }
          },
        ),
      );
      widgetList.add(
        SizedBox(
          height: 10,
        ),
      );
    }

    widgetList.add(
      ButtonTheme(
        height: 44,
        child: RaisedButton(
          onPressed: () {
            Save();
          },
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Text(
            "Kaydet",
            style: TextStyle(fontSize: 20),
          ),
          color: Colors.green.shade500,
          textColor: Colors.white,
        ),
      ),
    );
    return widgetList;
  }

  void getData() {
    databaseHelper
        .getAllActivityStatus(DateTime(date.year, date.month, date.day))
        .then((gelen) async {
      for (var item in gelen) {
        activityStatus.add(ActivityStatusVM(
            item.activityValue, item.activityName, item.activityId,
            activityStatusId: item.activityStatusId));
      }
      Future.delayed(Duration(milliseconds: 2000), () {
        setState(() {
          isCompleted = true;
        });
      });
    });
  }

  void Save() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      var result = await databaseHelper.saveActivityStatus(
          activityStatus, DateTime(date.year, date.month, date.day));
      if (result == activityStatus.length) {
        snackBarShow("Aktivite ilerlemeleri başarı ile kayıt edildi.");
      } else {
        if (result != 0) {
          snackBarShow(
              "Aktivite ilerlemelerinin bir kısmı başarılı bir şekilde kayıt edildi.");
        } else {
          snackBarShow("Aktivite ilerlemeleri kayıt edilirken hata oluştu.");
        }
      }
    }
  }

  snackBarShow(mesaj) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(mesaj),
      duration: Duration(seconds: 2),
    ));
  }
}
