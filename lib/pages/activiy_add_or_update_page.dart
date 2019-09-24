import 'package:flutter/material.dart';
import 'package:followyourselfflutter/models/activity.dart';
import 'package:followyourselfflutter/util/database_helper.dart';

class ActivityAddOrUpdatePage extends StatefulWidget {
  // const ActivityAddOrUpdatePage({Key key, this.activity}) : super(key: key);
  ActivityAddOrUpdatePage({this.activity});
  final Activity activity;

  @override
  _ActivityAddOrUpdatePageState createState() =>
      _ActivityAddOrUpdatePageState();
}

class _ActivityAddOrUpdatePageState extends State<ActivityAddOrUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  DatabaseHelper databaseHelper;
  String activityName;
  bool isSuccess = false;
  bool secilenDurum = true;
  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    secilenDurum = widget.activity == null ? true : widget.activity.isActive;
    activityName =
        widget.activity == null ? null : widget.activity.activityName;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, isSuccess);
        return Future.value(isSuccess);
      },
      child: Scaffold(
        // drawer: DrawerMenu(),
        appBar: AppBar(
          title: Text("Aktivite Ekle"),
          backgroundColor: Colors.red.shade900,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Text(
                  "Aktivite Adı:",
                  style: TextStyle(color: Colors.blue.shade700),
                ),
                TextFormField(
                  decoration: InputDecoration(),
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value == null) {
                      return "Aktivite adı boş bırakılamaz.";
                    } else if (value.length <= 2) {
                      return "Aktivite adı en az 3 karakter olmalıdır.";
                    }
                  },
                  onSaved: (value) {
                    activityName = value;
                  },
                  initialValue: activityName,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Aktivite Aktiflik Durumu:",
                  style: TextStyle(color: Colors.blue.shade700),
                ),
                DropdownButtonFormField<bool>(
                  hint: Center(
                    child: Text("Seçiniz"),
                  ),
                  value: secilenDurum,
                  decoration: InputDecoration(),
                  items: [
                    DropdownMenuItem<bool>(
                      child: Center(
                        child: Text("Aktif"),
                      ),
                      value: true,
                    ),
                    DropdownMenuItem<bool>(
                      child: Center(child: Text("Aktif Değil")),
                      value: false,
                    ),
                  ],
                  onChanged: (bool deger) {
                    setState(() {
                      secilenDurum = deger;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
                  child: ButtonTheme(
                    height: 43,
                    child: RaisedButton(
                      onPressed: () => Kaydet(),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        "Kaydet",
                        style: TextStyle(fontSize: 18),
                      ),
                      color: Colors.green.shade500,
                      textColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Kaydet() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (widget.activity == null) {
        var result = await databaseHelper
            .hasActivity(Activity(activityName, secilenDurum));
        // debugPrint(result.toString());
        if (result) {
          showDialogShow("Zaten bu isimde bir aktivite kayıtlarda mevcut.");
        } else {
          await databaseHelper
              .addActivity(Activity(activityName, secilenDurum))
              .then((addedId) {
            if (addedId != 0) {
              isSuccess = true;
              Navigator.pop(context, isSuccess);
              return Future.value(isSuccess);
            } else {
              isSuccess = false;
            }
            debugPrint(addedId.toString());
          });
        }
      } else {
        var result = await databaseHelper.hasActivityWithId(Activity.withId(
            widget.activity.activityId, activityName, secilenDurum));
        if (result) {
          showDialogShow("Zaten bu isimde bir aktivite kayıtlarda mevcut.");
        } else {
          await databaseHelper
              .updateActivity(Activity.withIdAndWithDate(
                  widget.activity.activityId,
                  activityName,
                  secilenDurum,
                  widget.activity.activityRegisterDate))
              .then((addedId) {
            if (addedId != 0) {
              isSuccess = true;
              Navigator.pop(context, isSuccess);
              return Future.value(isSuccess);
            } else {
              isSuccess = false;
            }
            debugPrint(addedId.toString());
          });
        }
      }
    }
  }

  showDialogShow(String message) {
    showDialog(
      context: context,
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
}
