import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:intl/intl.dart';
import 'package:automation_app/providers/auth_provider.dart';
import 'package:automation_app/models/product_model.dart';
import 'package:automation_app/models/order_model.dart';
import 'package:automation_app/services/order_service.dart';

class OrderSubTab extends StatefulWidget {
  const OrderSubTab({super.key});

  @override
  State<OrderSubTab> createState() => _OrderSubTabState();
}

class _OrderSubTabState extends State<OrderSubTab> {
  final OrderService _orderService = OrderService();
  bool _showGreeting = true;
  final String _selectedRoute = 'Dhaka Road';
  String _shopName = 'Rahim General Store';
  final String _shopId = 'shop_001';
  final List<OrderItem> _currentOrderItems = [];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final soName = authProvider.name ?? 'Sales Officer';

    if (_showGreeting) {
      return _buildGreetingScreen(soName);
    }
    return _buildOrderCollectionScreen(soName);
  }

  Widget _buildGreetingScreen(String soName) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Hello', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text(
            'Good Morning, $soName',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("Today's Route:", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _selectedRoute,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => setState(() => _showGreeting = false),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCollectionScreen(String soName) {
    final today = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dayFormat = DateFormat('EEEE');

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${dateFormat.format(today)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Day: ${dayFormat.format(today)}'),
                    Text('Route: $_selectedRoute'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Target C/V', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('56 / 19650', style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
                    Text('Items: ${_currentOrderItems.length}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Orders'),
              Tab(text: 'Memos'),
              Tab(text: 'Report'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrdersTab(),
                _buildMemosTab(),
                _buildReportTab(soName),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Column(
      children: [
        if (_currentOrderItems.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.green.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_currentOrderItems.length} items added'),
                ElevatedButton(
                  onPressed: _showShopSelectionDialog,
                  child: const Text('SAVE ORDER'),
                ),
              ],
            ),
          ),
        Expanded(
          child: FutureBuilder<firestore.QuerySnapshot>(
            future: firestore.FirebaseFirestore.instance.collection('products').limit(50).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) { return Center(child: Text("ERROR: ${snapshot.error}", style: TextStyle(color: Colors.red))); }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No products available.\nAdd products from Firebase Console.'),
                  ),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final product = Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Code: ${product.code} | DP: Tk ${product.dpPerPcs.toStringAsFixed(2)}/pcs'),
                      trailing: ElevatedButton(
                        onPressed: () => _showOrderEntryDialog(product),
                        child: const Text('ADD'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemosTab() {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    return FutureBuilder<List<Order>>(
      future: _orderService.getOrdersByDate(today),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No memos for today'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final order = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.receipt)),
                title: Text(order.shopName),
                subtitle: Text('${order.items.length} items | Tk ${order.totalValue.toStringAsFixed(0)}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportTab(String soName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _reportRow('Sales Officer', soName),
                  _reportRow('Route', _selectedRoute),
                  _reportRow('Target C/V', '56 / 19650'),
                  _reportRow('Items Added', '${_currentOrderItems.length}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showOrderEntryDialog(Product product) {
    final cartonsController = TextEditingController();
    final pcsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('DP: Tk ${product.dpPerPcs.toStringAsFixed(2)} / pcs'),
            const SizedBox(height: 10),
            TextField(
              controller: cartonsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cartons', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pcsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Pcs', border: OutlineInputBorder()),
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
              final cartons = int.tryParse(cartonsController.text) ?? 0;
              final pcs = int.tryParse(pcsController.text) ?? 0;
              if (cartons == 0 && pcs == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter quantity')),
                );
                return;
              }
              setState(() {
                _currentOrderItems.add(OrderItem(
                  productId: product.code,
                  productName: product.name,
                  cartons: cartons,
                  pcs: pcs,
                  dpRate: product.dpPerPcs,
                  pcsPerCarton: product.pcsPerCarton,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showShopSelectionDialog() {
    final shopController = TextEditingController(text: _shopName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Shop'),
        content: TextField(
          controller: shopController,
          decoration: const InputDecoration(labelText: 'Shop Name', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newShopName = shopController.text;
              setState(() {
                _shopName = newShopName;
              });
              await _saveCurrentOrder(newShopName);
            },
            child: const Text('Save Order'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCurrentOrder(String newShopName) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final soName = authProvider.name ?? 'Sales Officer';
    final today = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dayFormat = DateFormat('EEEE');

    double totalValue = 0;
    for (final item in _currentOrderItems) {
      totalValue += item.totalValue;
    }

    final order = Order(
      id: '',
      date: dateFormat.format(today),
      day: dayFormat.format(today),
      route: _selectedRoute,
      soName: soName,
      shopName: newShopName,
      shopId: _shopId,
      items: List.from(_currentOrderItems),
      totalValue: totalValue,
    );

    try {
      await _orderService.saveOrder(order);
      if (!mounted) return;
      setState(() {
        _currentOrderItems.clear();
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order saved successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }
}
