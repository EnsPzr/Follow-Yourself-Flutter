import 'package:date_format/date_format.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'drawer_menu.dart';
import 'package:intl/intl.dart';

class ActivityStatusPage extends StatefulWidget {
  _ActivityStatusPageState createState() => _ActivityStatusPageState();
}

class _ActivityStatusPageState extends State<ActivityStatusPage> {
  final _formKey = GlobalKey<FormState>();
  var _tarih = DateTime.now();
  final _format = DateFormat("dd.MM.yyyy");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMenu(),
      appBar: AppBar(
        title: Text("Günlük Aktivite İlerlemelerim"),
        backgroundColor: Colors.red.shade900,
      ),
      body: Padding(
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Text(
                'Günü Seçiniz:',
                style: TextStyle(color: Colors.blue.shade700),
              ),
              DateTimeField(
                resetIcon: null,
                format: _format,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: formatDate(_tarih, [dd, '.', mm, '.', yyyy]),
                  hintStyle: TextStyle(color: Colors.black),
                ),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                },
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Kaza Akşam Namazı:",
                style: TextStyle(color: Colors.blue.shade700),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "0",
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ButtonTheme(
                height: 44,
                child: RaisedButton(
                  onPressed: () {},
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    "Kaydet",
                    style: TextStyle(fontSize: 20),
                  ),
                  color: Colors.green.shade500,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        padding: EdgeInsets.all(10),
      ),
    );
  }
}
