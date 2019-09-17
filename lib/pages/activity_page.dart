import 'package:flutter/material.dart';
import 'drawer_menu.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMenu(),
      appBar: AppBar(
        title: Text("Tüm Aktivitelerim"),
        backgroundColor: Colors.red.shade900,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, "/activityAddOrUpdatePage");
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: Card(
                child: ListTile(
                  isThreeLine: false,
                  title: Text("Kaza Akşam Namazı"),
                  subtitle: Text("Aktif"),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
