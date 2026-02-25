import 'package:flutter/material.dart';
import 'football_screen.dart';
import 'badminton_screen.dart';
import 'cricket_screen.dart';
import 'tournaments_screen.dart';
import 'profile_screen.dart';

/// Home screen with bottom navigation bar for the app.
/// 
/// This screen manages navigation between 5 main sport categories
/// and the user profile section.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Currently selected tab index
  int _selectedIndex = 0;

  /// List of screens corresponding to each tab
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const FootballScreen(),
      const BadmintonScreen(),
      const CricketScreen(),
      const TournamentsScreen(),
      const ProfileScreen(),
    ];
  }

  /// Handles tab selection
  void _onNavigationItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF000000),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7CFC00).withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: navigationBar(context),
        ),
      ),
    );
  }

  /// Builds the bottom navigation bar with 5 destinations
  Widget navigationBar(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onNavigationItemSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.sports_soccer),
          label: 'Football',
        ),
        NavigationDestination(
          icon: Icon(Icons.sports_tennis),
          label: 'Badminton',
        ),
        NavigationDestination(
          icon: Icon(Icons.sports_cricket),
          label: 'Cricket',
        ),
        NavigationDestination(
          icon: Icon(Icons.emoji_events),
          label: 'Tournaments',
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
