import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/home_page.dart';
import 'package:esport_mgm/screens/login_screen.dart';
import 'package:esport_mgm/services/auth_service.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final AuthService _auth = AuthService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final user = await _auth.getCurrentUser();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  void _onAuthSuccess() {
    _checkCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user != null) {
      return HomePage(user: _user!);
    } else {
      return LoginScreen(onLoginSuccess: _onAuthSuccess);
    }
  }
}
