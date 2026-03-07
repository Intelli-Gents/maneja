import 'package:flutter/material.dart';
import 'package:maneja/screens/Home.dart';
import 'package:maneja/screens/Settings.dart';

class Controller extends StatefulWidget {
  const Controller({super.key});

  @override
  State<Controller> createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {

  final screens = [Home(), Settings()];
  int _screenIndex = 0;

  _onItemTapped(int index) {
    setState((){
      _screenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens.elementAt(_screenIndex),
      bottomNavigationBar: NavigationBar(
      backgroundColor: Colors.white54,
      surfaceTintColor: Colors.white54,
      indicatorColor: Colors.grey[200],
      selectedIndex: _screenIndex,
      onDestinationSelected: _onItemTapped,
      destinations: [
        NavigationDestination(
          label: "Home",
          icon: Icon(Icons.home),
        ),
        NavigationDestination(
          label: "Settings",
          icon: Icon(Icons.settings),
        ),
      ]),
    );
  }
}