import 'package:flutter/material.dart';
import 'package:public_lookupp/pages/account_page.dart';
import 'package:public_lookupp/pages/beacon_page.dart';
import 'package:public_lookupp/pages/points_page.dart';

class StatePage extends StatefulWidget {
  const StatePage({super.key});

  @override
  State<StatePage> createState() => _StatePageState();
}

class _StatePageState extends State<StatePage> {
  static const List<Destination> allDestinations = <Destination>[
    Destination(0, 'Home', Icons.home, Colors.blue),
    Destination(1, 'Points', Icons.cake, Colors.blue),
    Destination(2, 'Account', Icons.person, Colors.blue),
  ];

  int selectedIndex = 0;

  final List<Widget> pages = [
    BeaconPage(),
    PointsPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: allDestinations.map<NavigationDestination>(
          (Destination destination) {
            return NavigationDestination(
              icon: Icon(destination.icon, color: destination.color),
              label: destination.title,
            );
          },
        ).toList(),
      ),
    );
  }
}

class Destination {
  const Destination(this.index, this.title, this.icon, this.color);
  final int index;
  final String title;
  final IconData icon;
  final MaterialColor color;
}
