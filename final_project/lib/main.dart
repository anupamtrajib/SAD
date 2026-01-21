import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fccpaaamtfmxmuovamcc.supabase.co',     // Replace with your Supabase project URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZjY3BhYWFtdGZteG11b3ZhbWNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc0NjU4NTQsImV4cCI6MjA4MzA0MTg1NH0.d19je-UTcafSoH7oFxWIBiEqQpRPxAPEvi8L23fkS8w', // Replace with your anon/public key
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopEase POS',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: AuthChecker(),
    );
  }
}

// Check if user is logged in
class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      return DashboardScreen();
    } else {
      return LoginScreen();
    }
  }
}
