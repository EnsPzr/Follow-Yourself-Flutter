import 'package:flutter/material.dart';

import 'drawer_menu.dart';

class ActivityAddOrUpdatePage extends StatelessWidget {
  const ActivityAddOrUpdatePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: DrawerMenu(),
      appBar: AppBar(
        title: Text("Aktivite Ekle"),
        backgroundColor: Colors.red.shade900,
      ),
      body: Text("ekleme sayfası"),
    );
  }
}
