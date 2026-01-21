import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaleTerminalPage extends StatefulWidget {
  const SaleTerminalPage({super.key});

  @override
  State<SaleTerminalPage> createState() => _SaleTerminalPageState();
}

class _SaleTerminalPageState extends State<SaleTerminalPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> cart = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final data = await supabase.from('products').select().order('name');
    setState(() => products = List<Map<String, dynamic>>.from(data));
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      final index = cart.indexWhere((item) => item['id'] == product['id']);
      if (index >= 0) {
        cart[index]['quantity'] += 1;
      } else {
        cart.add({...product, 'quantity': 1});
      }
    });
  }

  double get total => cart.fold(0, (sum, item) => sum + (item['selling_price'] * item['quantity']));


  // 1. The Cart Bottom Sheet
  void showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Review Order", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(child: Text("Cart is empty"))
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            final item = cart[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("৳${item['selling_price']} x ${item['quantity']}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    onPressed: () {
                                      setSheetState(() {
                                        if (item['quantity'] > 1) {
                                          item['quantity']--;
                                        } else {
                                          cart.removeAt(index);
                                        }
                                      });
                                      setState(() {}); // Sync main UI
                                    },
                                  ),
                                  Text("${item['quantity']}", style: const TextStyle(fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                    onPressed: () {
                                      setSheetState(() => item['quantity']++);
                                      setState(() {}); // Sync main UI
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Amount:", style: TextStyle(fontSize: 18)),
                    Text("৳$total", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: cart.isEmpty ? null : () async {
                      await completeSale();
                      Navigator.pop(context);
                    },
                    child: const Text("Confirm & Pay", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Future<void> completeSale() async {
    try {
      final user = supabase.auth.currentUser;
      final saleResponse = await supabase.from('sales').insert({
        'user_id': user?.id,
        'total_amount': total,
      }).select().single();

      for (var item in cart) {
        await supabase.from('sale_items').insert({
          'sale_id': saleResponse['id'],
          'product_id': item['id'],
          'quantity': item['quantity'],
          'price_at_sale': item['selling_price'],
        });

        await supabase.from('products').update({
          'stock': item['stock'] - item['quantity'],
        }).eq('id', item['id']);
      }

      setState(() => cart.clear());
      fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sale successful!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((p) => p['name'].toString().toLowerCase().contains(searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          
          // 2. Product Grid (Full Screen)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 0.75, 
                crossAxisSpacing: 12, 
                mainAxisSpacing: 12,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final p = filteredProducts[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: p['image_url'] != null 
                              ? Image.network(p['image_url'], fit: BoxFit.cover, width: double.infinity) 
                              : Container(color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text("৳${p['selling_price']}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey[50],
                                  foregroundColor: Colors.blueAccent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: p['stock'] > 0 ? () => addToCart(p) : null,
                                child: Text(p['stock'] > 0 ? "Add" : "Out of Stock"),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // 3. Floating Bottom Bar (Shows only when cart has items)
      bottomNavigationBar: cart.isEmpty 
        ? null 
        : GestureDetector(
            onTap: showCartSheet,
            child: Container(
              height: 70,
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag, color: Colors.white),
                      const SizedBox(width: 10),
                      Text("${cart.length} Items", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Text("View Cart: ৳$total", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
    );
  }
}