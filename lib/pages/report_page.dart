import 'package:flutter/material.dart';
import 'drawer_menu.dart';

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 10;
    return Scaffold(
      drawer: DrawerMenu(),
      appBar: AppBar(
        title: Text("Rapor"),
        backgroundColor: Colors.red.shade900,
      ),
      body: Container(
        child: ListView(
          padding: EdgeInsets.only(top: 10, right: 5, left: 5),
          children: <Widget>[
            addRow(width / 5, "Aktivite Adı", "Toplam Yapılma", "Bu Yıl",
                "Bu Ay", "Bu Hafta"),
            addRow(width / 5, "0", "0", "0", "0", "0"),
            addRow(width / 5, "10", "0", "10", "0", "10"),
            addRow(width / 5, "100", "10", "10", "100", "10"),
            addRow(width / 5, "100", "10", "10", "100", "10"),
            addRow(width / 5, "100", "10", "10", "100", "10"),
            addRow(width / 5, "100", "10", "10", "100", "10"),
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
              child: ButtonTheme(
                height: 40,
                child: RaisedButton(
                  onPressed: () {},
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    "Yedekle",
                    style: TextStyle(fontSize: 17),
                  ),
                  color: Colors.green.shade500,
                  textColor: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 8),
              child: ButtonTheme(
                height: 40,
                child: RaisedButton(
                  onPressed: () {},
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    "Yedekten Geri Yükle",
                    style: TextStyle(fontSize: 17),
                  ),
                  color: Colors.green.shade500,
                  textColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Container addRow(double columnWidth, str1, str2, str3, str4, str5) {
  return Container(
    // color: Colors.grey,
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
