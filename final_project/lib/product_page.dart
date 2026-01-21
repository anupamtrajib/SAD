import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:collection/collection.dart'; // Required for firstWhereOrNull

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> brands = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await fetchBrands();
    await fetchProducts();
    setState(() => isLoading = false);
  }

  // ================= FETCH PRODUCTS =================
  Future<void> fetchProducts() async {
    try {
      final data = await supabase
          .from('products')
          .select('*, brands(name)')
          .order('created_at', ascending: false);

      setState(() {
        products = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      showError(e);
    }
  }

  // ================= FETCH BRANDS =================
  Future<void> fetchBrands() async {
    try {
      final data = await supabase.from('brands').select().order('name');
      
      // Create the "No Brand" option
      final noBrand = {'id': null, 'name': 'No Brand'};
      
      setState(() {
        // Start the list with "No Brand", then add brands from DB
        brands = [noBrand, ...List<Map<String, dynamic>>.from(data)];
      });
    } catch (e) {
      showError(e);
    }
  }

  void showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
    );
  }

  // ================= DELETE PRODUCT =================
  Future<void> deleteProduct(Map<String, dynamic> product) async {
    try {
      final imageUrl = product['image_url'] as String?;
      if (imageUrl != null) {
        final uri = Uri.parse(imageUrl);
        final filePath = uri.pathSegments.skip(1).join('/');
        await supabase.storage.from('images').remove([filePath]);
      }

      await supabase.from('products').delete().eq('id', product['id']);
      fetchProducts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted')),
      );
    } catch (e) {
      showError(e);
    }
  }

  // ================= ADD PRODUCT =================
  void openAddProductDialog() {
    final nameCtrl = TextEditingController();
    final buyingCtrl = TextEditingController();
    final sellingCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    
    Map<String, dynamic>? selectedBrand = brands.isNotEmpty ? brands.first : null;
    Uint8List? imageBytes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          
          Future<void> pickImage() async {
            final picker = ImagePicker();
            final picked = await picker.pickImage(source: ImageSource.gallery);
            if (picked != null) {
              final bytes = await picked.readAsBytes();
              setDialogState(() => imageBytes = bytes);
            }
          }

          Future<void> addProduct() async {
            try {
              final user = supabase.auth.currentUser;
              if (user == null) throw Exception('Please login first');

              String? imageUrl;
              if (imageBytes != null) {
                final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                await supabase.storage.from('images').uploadBinary(fileName, imageBytes!);
                imageUrl = supabase.storage.from('images').getPublicUrl(fileName);
              }

              await supabase.from('products').insert({
                'user_id': user.id,
                'name': nameCtrl.text.trim(),
                'brand_id': selectedBrand?['id'],
                'buying_price': double.tryParse(buyingCtrl.text) ?? 0,
                'selling_price': double.tryParse(sellingCtrl.text) ?? 0,
                'stock': int.tryParse(stockCtrl.text) ?? 0,
                'image_url': imageUrl,
              });

              Navigator.pop(context);
              fetchProducts();
            } catch (e) {
              showError(e);
            }
          }

          return AlertDialog(
            title: const Text('Add Product'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imageBytes != null)
                    Image.memory(imageBytes!, height: 100, width: 100, fit: BoxFit.cover),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    initialValue: selectedBrand,
                    items: brands.map((b) => DropdownMenuItem(value: b, child: Text(b['name'] ?? ''))).toList(),
                    onChanged: (val) => setDialogState(() => selectedBrand = val),
                    decoration: const InputDecoration(labelText: 'Brand'),
                  ),
                  TextField(controller: buyingCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Buying Price')),
                  TextField(controller: sellingCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Selling Price')),
                  TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock')),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(onPressed: pickImage, icon: const Icon(Icons.image), label: const Text('Pick Image')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(onPressed: addProduct, child: const Text('Add')),
            ],
          );
        },
      ),
    );
  }

  // ================= EDIT PRODUCT =================
  void openEditProductDialog(Map<String, dynamic> product) {
    final nameCtrl = TextEditingController(text: product['name']);
    final buyingCtrl = TextEditingController(text: product['buying_price'].toString());
    final sellingCtrl = TextEditingController(text: product['selling_price'].toString());
    final stockCtrl = TextEditingController(text: product['stock'].toString());

    // Find current brand or default to "No Brand"
    Map<String, dynamic>? selectedBrand = brands.firstWhereOrNull(
      (b) => b['id'] == product['brand_id'],
    ) ?? (brands.isNotEmpty ? brands.first : null);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Product'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    initialValue: selectedBrand,
                    items: brands.map((b) => DropdownMenuItem(value: b, child: Text(b['name'] ?? ''))).toList(),
                    onChanged: (val) => setDialogState(() => selectedBrand = val),
                    decoration: const InputDecoration(labelText: 'Brand'),
                  ),
                  TextField(controller: buyingCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Buying Price')),
                  TextField(controller: sellingCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Selling Price')),
                  TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await supabase.from('products').update({
                      'name': nameCtrl.text.trim(),
                      'brand_id': selectedBrand?['id'],
                      'buying_price': double.parse(buyingCtrl.text),
                      'selling_price': double.parse(sellingCtrl.text),
                      'stock': int.parse(stockCtrl.text),
                    }).eq('id', product['id']);
                    Navigator.pop(context);
                    fetchProducts();
                  } catch (e) {
                    showError(e);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: openAddProductDialog,
        child: const Icon(Icons.add),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('No products found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final p = products[index];
                    final brandData = p['brands'] as Map<String, dynamic>?;
                    final brandName = brandData?['name'] ?? 'No Brand';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: p['image_url'] != null
                            ? Image.network(p['image_url'], width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.inventory, size: 40),
                        title: Text(p['name'] ?? 'Unknown'),
                        subtitle: Text('Brand: $brandName\nStock: ${p['stock']} | Sell: ৳${p['selling_price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => openEditProductDialog(p)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => deleteProduct(p)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}