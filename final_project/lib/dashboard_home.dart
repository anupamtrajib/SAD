import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final supabase = Supabase.instance.client;

  String formatMoney(dynamic value) {
    double amount = double.tryParse(value.toString()) ?? 0.0;
    return amount.toStringAsFixed(2);
  }

  double _calculate(dynamic data) {
    if (data == null || data is! List) return 0.0;
    double total = 0.0;
    for (var item in data) {
      double amount = double.tryParse(item['total_amount'].toString()) ?? 0.0;
      total = total + amount;
    }
    return total;
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    final now = DateTime.now().toUtc();
    final startOfToday = DateTime(now.year, now.month, now.day).toUtc().toIso8601String();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekStr = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).toUtc().toIso8601String();
    final startOfMonth = DateTime(now.year, now.month, 1).toUtc().toIso8601String();

    final results = await Future.wait([
      supabase.from('products').select('id'),
      supabase.from('sales').select('total_amount').gte('created_at', startOfToday),
      supabase.from('sales').select('total_amount').gte('created_at', startOfWeekStr),
      supabase.from('sales').select('total_amount').gte('created_at', startOfMonth),
      supabase.from('sales').select().order('created_at', ascending: false).limit(8),
    ]);

    return {
      'productCount': (results[0]).length,
      'todaySales': _calculate(results[1]),
      'weekSales': _calculate(results[2]),
      'monthSales': _calculate(results[3]),
      'recentSales': results[4] as List,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<Map<String, dynamic>>(
        future: getDashboardData(),
        builder: (context, snapshot) {
          // Loader while waiting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Error handling
          if (!snapshot.hasData) {
            return const Center(child: Text("No data found"));
          }

          final data = snapshot.data!;
          final recentSales = data['recentSales'] as List;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- STAT BLOCKS (MANUAL CODE FOR EVERY BOX) ---
              Column(
                children: [
                  // FIRST ROW: Today and Items
                  Row(
                    children: [
                      // TODAY BOX
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.today, color: Colors.white, size: 20),
                              const SizedBox(height: 5),
                              Text(
                                "৳${formatMoney(data['todaySales'])}",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Text("Today", style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // ITEMS BOX
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.inventory, color: Colors.white, size: 20),
                              const SizedBox(height: 5),
                              Text(
                                "${data['productCount']}",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Text("Items", style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // SECOND ROW: Weekly and Monthly
                  Row(
                    children: [
                      // WEEKLY BOX
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.bar_chart, color: Colors.white, size: 20),
                              const SizedBox(height: 5),
                              Text(
                                "৳${formatMoney(data['weekSales'])}",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Text("Weekly", style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // MONTHLY BOX
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                              const SizedBox(height: 5),
                              Text(
                                "৳${formatMoney(data['monthSales'])}",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Text("Monthly", style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text("Recent Sales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // --- RECENT SALES LIST ---
              if (recentSales.isEmpty)
                const Center(child: Text("No transactions yet"))
              else
                ...recentSales.map((sale) {
                  final date = DateTime.parse(sale['created_at'].toString()).toLocal();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.receipt, color: Colors.blue),
                      title: Text(
                        "৳${formatMoney(sale['total_amount'])}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(DateFormat('MMM dd, hh:mm a').format(date)),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}