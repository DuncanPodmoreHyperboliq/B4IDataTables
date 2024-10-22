import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:b4i_frontend/routes/auth_flow/login_page.dart';
import 'package:b4i_frontend/routes/dashboard/dashboard.dart';

class AuthChecker extends StatefulWidget {
  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      setState(() {}); // Refresh on auth state change
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return DashboardPage();
    } else {
      return LoginPage();
    }
  }
}
