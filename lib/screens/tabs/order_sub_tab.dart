import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:automation_app/providers/auth_provider.dart';
import 'package:automation_app/models/product_model.dart';
import 'package:automation_app/models/order_model.dart';

class OrderSubTab extends StatefulWidget {
  const OrderSubTab({super.key});

  @override
  State<OrderSubTab> createState() => _OrderSubTabState();
}

class _OrderSubTabState extends State<OrderSubTab> {
  bool _showGreeting = true;
  String _selectedRoute = '';
  final _cartonsController = TextEditingController();
  final _pcsController = TextEditingController();
  Product? _selectedProduct;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final soName = authProvider.user?.displayName ?? 'Sales Officer';

    if (_showGreeting) {
      return _buildGreetingScreen(soName);
    }

    return _buildOrderCollectionScreen(soName);
  }

  // গ্রিটিং স্ক্রিন
  Widget _buildGreetingScreen(String soName) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.waving_hand, size: 80, color: Colors.amber),
          const SizedBox(height: 20),
          Text(
            'Good Morning, $soName',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Today's Route:",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Dhaka Road',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showGreeting = false;
              });
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              _showRouteSelectionDialog();
            },
            icon: const Icon(Icons.edit),
            label: const Text('Change Route'),
          ),
        ],
      ),
    );
  }

  // রুট পরিবর্তন ডায়ালগ
  void _showRouteSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Route'),
        content: const Text('Route selection will be added soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Order Collection Screen
  Widget _buildOrderCollectionScreen(String soName) {
    final today = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dayFormat = DateFormat('EEEE');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // হেডার
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pran Beverage Group', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const Text('Dealer: Bhai Bhai Store', style: TextStyle(fontSize: 14)),
                  const Text('Joydebpur, Gazipur', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // টার্গেট কার্ড
          Card(
            elevation: 2,
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${dateFormat.format(today)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Day: ${dayFormat.format(today)}'),
                      const Text('Route: Dhaka Road'),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Target C/V', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('56 / 19650', style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // প্রোডাক্ট লিস্ট
          const Text('Order Collection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildProductList(),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('products').limit(20).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No products available. Please set up products first.'),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final product = Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Code: ${product.code} | DP: ৳${product.dpPerPcs}/pcs'),
                trailing: ElevatedButton(
                  onPressed: () => _showOrderEntryDialog(product),
                  child: const Text('ADD'),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // অর্ডার এন্ট্রি ডায়ালগ
  void _showOrderEntryDialog(Product product) {
    _selectedProduct = product;
    _cartonsController.clear();
    _pcsController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _cartonsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cartons',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _pcsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pcs',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Save order to Firestore
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.name} added to order')),
              );
            },
            child: const Text('Add to Order'),
          ),
        ],
      ),
    );
  }
}
