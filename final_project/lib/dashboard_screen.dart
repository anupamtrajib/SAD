import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dashboard_home.dart';
import 'product_page.dart';
import 'brand_page.dart';
import 'sales_history.dart';
import 'sale_terminal.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;

  String selectedPage = 'Dashboard';
  String userEmail = 'Unknown';

  @override
  void initState() {
    super.initState();
    userEmail = supabase.auth.currentUser?.email ?? 'Unknown';
  }

  // ========================= MAIN CONTENT =========================
  Widget _getMainContent() {
    switch (selectedPage) {
      case 'Sale Terminal':
        return const SaleTerminalPage();
      case 'Sales History':
        return const SalesHistoryPage();
      case 'Products':
        return const ProductPage();
      case 'Brands':
        return const BrandPage();
      case 'Dashboard':
      default:
        return const DashboardHome();
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  void _changePage(String page) {
    setState(() => selectedPage = page);
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedPage,
          style: const TextStyle(fontWeight: FontWeight.bold,color:Color.fromARGB(255, 210, 197, 197)
          
            ),
        ),
        backgroundColor: const Color.fromARGB(255, 32, 72, 165),
      ),
      drawer: Drawer(
  child: Container(
    color: Colors.blueGrey[900],
    child: Column(
      children: [
        const SizedBox(height: 60),
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.person, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          userEmail,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const Divider(color: Colors.white24, height: 40),

        ListTile(
          leading: const Icon(Icons.dashboard_outlined, color: Colors.white70),
          title: Text(
            'Dashboard',
            style: TextStyle(
              color: selectedPage == 'Dashboard' ? Colors.white : Colors.white70,
            ),
          ),
          onTap: () => _changePage('Dashboard'),
        ),

        const Padding(
          padding: EdgeInsets.only(left: 16, top: 20, bottom: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('SALES', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
        ),

        ListTile(
          leading: const Icon(Icons.shopping_cart_checkout, color: Colors.white70),
          title: Text(
            'Sale Terminal',
            style: TextStyle(
              color: selectedPage == 'Sale Terminal' ? Colors.white : Colors.white70,
            ),
          ),
          onTap: () => _changePage('Sale Terminal'),
        ),

        ListTile(
          leading: const Icon(Icons.history, color: Colors.white70),
          title: Text(
            'Sales History',
            style: TextStyle(
              color: selectedPage == 'Sales History' ? Colors.white : Colors.white70,
            ),
          ),
          onTap: () => _changePage('Sales History'),
        ),

        const Padding(
          padding: EdgeInsets.only(left: 16, top: 20, bottom: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('INVENTORY', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
        ),

        ListTile(
          leading: const Icon(Icons.inventory_2_outlined, color: Colors.white70),
          title: Text(
            'Products',
            style: TextStyle(
              color: selectedPage == 'Products' ? Colors.white : Colors.white70,
            ),
          ),
          onTap: () => _changePage('Products'),
        ),

        ListTile(
          leading: const Icon(Icons.branding_watermark_outlined, color: Colors.white70),
          title: Text(
            'Brands',
            style: TextStyle(
              color: selectedPage == 'Brands' ? Colors.white : Colors.white70,
            ),
          ),
          onTap: () => _changePage('Brands'),
        ),

        const Spacer(),
        const Divider(color: Colors.white24),

        ListTile(
          leading: const Icon(Icons.logout, color: Colors.white70),
          title: const Text('Logout', style: TextStyle(color: Colors.white70)),
          onTap: _logout,
        ),
        const SizedBox(height: 20),
      ],
    ),
  ),
),
      body: Container(
        color: const Color(0xFFF5F7F9),
        child: _getMainContent(),
      ),
    );
  }
}