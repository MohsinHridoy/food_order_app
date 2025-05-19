import 'package:flutter/material.dart';
import 'admin/admin_upload.dart';
import 'foodmenu/food_menu.dart';
import 'mainpage/mainpage.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => MainPage(), // Use MainPage with bottom navigation
      },
    );
  }
}

