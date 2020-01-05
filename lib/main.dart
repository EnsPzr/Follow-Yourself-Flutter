import 'package:flutter/material.dart';
import 'package:followyourselfflutter/pages/activity_page.dart';
import 'package:followyourselfflutter/pages/activity_status_page.dart';
import 'package:followyourselfflutter/pages/activiy_add_or_update_page.dart';
import 'package:followyourselfflutter/pages/report_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Kişisel Takip',
        initialRoute: "/",
        debugShowCheckedModeBanner: false,
        routes: {  
          '/': (context) => ActivityStatusPage(),
          '/activityPage': (context) => ActivityPage(),
          '/reportPage': (context) => ReportPage(),
          '/activityAddOrUpdatePage': (context) => ActivityAddOrUpdatePage()
        },
        theme: ThemeData(
          primarySwatch: Colors.red,
        )
        //home: ActivityStatusPage()
    );
  }
}
