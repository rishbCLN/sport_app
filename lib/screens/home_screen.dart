import 'package:flutter/material.dart';
import '../features/football/screens/football_screen.dart' as prism;
import '../features/tournaments/screens/tournaments_feed_screen.dart';
import 'badminton_screen.dart';
import 'cricket_screen.dart';
import 'profile_screen.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';

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
      const prism.FootballScreen(),
      const BadmintonScreen(),
      const CricketScreen(),
      const TournamentsFeedScreen(),
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
    return Container(
      decoration: BoxDecoration(
        color: PrismColors.pitch,
        border: const Border(
          top: BorderSide(color: PrismColors.concrete, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: PrismColors.voltGreen.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        indicatorColor: PrismColors.voltGreen.withOpacity(0.15),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavigationItemSelected,
        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          _navDest(Icons.sports_soccer, 'FOOTBALL',
              PrismColors.voltGreen),
          _navDest(Icons.sports_tennis, 'BADMINTON',
              PrismColors.cyanBlitz),
          _navDest(Icons.sports_cricket, 'CRICKET',
              PrismColors.amberShock),
          _navDest(Icons.emoji_events, 'EVENTS',
              PrismColors.magentaFlare),
          _navDest(Icons.person, 'PROFILE',
              PrismColors.steelGray),
        ],
      ),
    );
  }

  NavigationDestination _navDest(
      IconData icon, String label, Color color) {
    return NavigationDestination(
      icon: Icon(icon, color: PrismColors.dimGray, size: 20),
      selectedIcon: Icon(icon, color: color, size: 20),
      label: label,
    );
  }
}
