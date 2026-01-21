import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> sales = [];
  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    fetchSales();
  }
Future<void> fetchSales() async {
  try {
    // 1. Start the query with select
    var query = supabase
        .from('sales')
        .select('*, sale_items(*, products(name))');

    // 2. Apply Filters (gte, lte, eq, etc.)
    if (selectedRange != null) {
      query = query
          .gte('created_at', selectedRange!.start.toIso8601String())
          .lte('created_at', selectedRange!.end.add(const Duration(days: 1)).toIso8601String());
    }

    // 3. Apply Transforms LAST (order, limit)
    final data = await query.order('created_at', ascending: false);

    setState(() {
      sales = List<Map<String, dynamic>>.from(data);
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error fetching sales: $e")),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // DATE FILTER HEADER
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedRange == null 
                  ? "Showing: All Sales" 
                  : "Range: ${DateFormat('dd MMM').format(selectedRange!.start)} - ${DateFormat('dd MMM').format(selectedRange!.end)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: const Text("Filter Date"),
                onPressed: () async {
                  final range = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (range != null) {
                    setState(() => selectedRange = range);
                    fetchSales();
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // SALES LIST
        Expanded(
          child: sales.isEmpty 
          ? const Center(child: Text("No sales found for this period"))
          : ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                final date = DateTime.parse(sale['created_at']).toLocal();
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTile(
                    title: Text("Sale #${sale['id'].toString().substring(0, 8)}"),
                    subtitle: Text("Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(date)}"),
                    trailing: Text("৳${sale['total_amount']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: (sale['sale_items'] as List).map((item) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${item['products']['name']} x${item['quantity']}"),
                                Text("৳${item['price_at_sale'] * item['quantity']}"),
                              ],
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
        ),
      ],
    );
  }
}