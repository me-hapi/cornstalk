import 'package:cornstalk/pages/maps_page.dart';
import 'package:cornstalk/pages/reports_page.dart';
import 'package:cornstalk/pages/scan_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // This is the index of the currently selected tab.
  int _selectedIndex = 1;

  // List of widgets representing different pages for each tab.
  static const List<Widget> _pages = <Widget>[
    MapsPage(),
    ScanPage(),
    ReportsPage(),
  ];

  // Called when a new tab is tapped.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FF90), // Light yellow background
      appBar: AppBar(
        title: const Text(
          'Cornstalk',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF059212), // Dark green background color
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              // Navigate to profile page when profile icon is tapped
              context.go('/profile'); // Replace with the actual route for your profile
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
        ],
        currentIndex: _selectedIndex, // Current tab
        selectedItemColor: Colors.yellow[800], // Yellow color for unselected tabs
        unselectedItemColor: Colors.white, // Light yellow background for the bottom navigation bar
        backgroundColor: const Color(0xFF059212), // Dark green color for the selected tab
        onTap: _onItemTapped, // Handle tab selection
      ),
    );
  }
}