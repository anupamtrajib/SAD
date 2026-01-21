import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BrandPage extends StatefulWidget {
  const BrandPage({super.key});

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> brands = [];

  @override
  void initState() {
    super.initState();
    fetchBrands();
  }

  Future<void> fetchBrands() async {
    try {
      final data = await supabase
          .from('brands')
          .select()
          .order('created_at', ascending: false);
      setState(() => brands = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void openAddEditDialog({Map<String, dynamic>? brand}) {
    final ctrl = TextEditingController(text: brand?['name'] ?? '');
    final isEdit = brand != null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Brand' : 'Add Brand'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Brand Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                if (isEdit) {
                  await supabase.from('brands').update({
                    'name': ctrl.text.trim(),
                  }).eq('id', brand!['id']);
                } else {
                  await supabase.from('brands').insert({
                    'name': ctrl.text.trim(),
                  });
                }
                Navigator.pop(context);
                fetchBrands();
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteBrand(Map<String, dynamic> brand) async {
    try {
      await supabase.from('brands').delete().eq('id', brand['id']);
      fetchBrands();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: brands.isEmpty
          ? const Center(child: Text('No brands found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: brands.length,
              itemBuilder: (_, index) {
                final b = brands[index];
                return Card(
                  child: ListTile(
                    title: Text(b['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => openAddEditDialog(brand: b),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteBrand(b),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
