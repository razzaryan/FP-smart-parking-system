import 'package:flutter/material.dart';
import '../controllers/parking_controller.dart';
import 'login_screen.dart';
import 'user_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final ParkingController _controller = ParkingController();
  String? _currentUserRole; // null = belum login, 'user' = pengendara, 'admin' = petugas

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _login(String role) {
    setState(() {
      _currentUserRole = role;
    });
  }

  void _logout() {
    setState(() {
      _currentUserRole = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserRole == 'user') {
      return UserDashboardScreen(
        controller: _controller,
        onLogout: _logout,
      );
    }

    if (_currentUserRole == 'admin') {
      return AdminDashboardScreen(
        controller: _controller,
        onLogout: _logout,
      );
    }

    return LoginScreen(
      isWifiConnected: _controller.wifiConnected,
      onToggleWifiSimulation: () => _controller.toggleWifi(_controller.sensorIp),
      onLoginSuccess: _login,
    );
  }
}
