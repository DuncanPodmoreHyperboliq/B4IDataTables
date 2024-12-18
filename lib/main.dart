import 'package:b4i_frontend/routes/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:b4i_frontend/data/supabase_client.dart';

import 'auth/auth_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: DashboardPage(),
      home: DashboardPage(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
