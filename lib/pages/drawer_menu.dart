import "package:flutter/material.dart";

class DrawerMenu extends StatefulWidget {
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                Container(
                  child: Center(
                    child: Text(
                      "Menü",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  width: double.maxFinite,
                  height: 120,
                  color: Colors.red.shade900,
                ),
                CreateMenuItem(
                    context, "AKTİVİTELERİM", 15, 6, "/activityPage"),
                CreateMenuItem(context, "GÜNLÜK TAKİP", 9, 6, "/"),
                CreateMenuItem(context, "RAPOR", 9, 6, "/reportPage"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget CreateMenuItem(BuildContext context, String name, double top,
    double rightAndLeft, String route) {
  return Padding(
    child: Container(
      child: InkWell(
        onTap: () {
          Navigator.pushReplacementNamed(context, route);
        },
        child: ListTile(
          // leading: Icon(Icons.home),
          title: Center(
            child: Text(
              name,
              style: TextStyle(color: Colors.white),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
        ),
        splashColor: Colors.blue,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade300,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
    ),
    padding: EdgeInsets.only(top: top, right: rightAndLeft, left: rightAndLeft),
  );
}
