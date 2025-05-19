import 'package:flutter/material.dart';
import '../admin/admin_upload.dart';
import '../foodmenu/food_menu.dart';
import '../foodmenudelete/food_menu_delete.dart';
import '../profile/profile.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    AdminPage(),
    FoodMenuPageDelete(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.orange[100], // Light orange for background
        selectedItemColor: Colors.orange, // Orange for selected items
        unselectedItemColor: Colors.grey[600], // Grey for unselected items
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Food Add',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Food Delete',
          ),
        ],
      ),
    );
  }
}
