import 'package:flutter/material.dart';

class ActivityAddOrUpdatePage extends StatefulWidget {
  const ActivityAddOrUpdatePage({Key key}) : super(key: key);

  @override
  _ActivityAddOrUpdatePageState createState() =>
      _ActivityAddOrUpdatePageState();
}

class _ActivityAddOrUpdatePageState extends State<ActivityAddOrUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  bool secilenDurum = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Aktivite Aktiflik Durumu:",
                style: TextStyle(color: Colors.blue.shade700),
              ),
              DropdownButtonFormField<bool>(
                hint: Text("Seçiniz"),
                value: secilenDurum,
                items: [
                  DropdownMenuItem<bool>(
                    child: Text("Aktif"),
                    value: true,
                  ),
                  DropdownMenuItem<bool>(
                    child: Text("Aktif Değil"),
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
                    onPressed: () {},
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
    );
  }
}
